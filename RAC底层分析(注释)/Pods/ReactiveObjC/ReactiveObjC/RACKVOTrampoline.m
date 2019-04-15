//
//  RACKVOTrampoline.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 1/15/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "RACKVOTrampoline.h"
#import "NSObject+RACDeallocating.h"
#import "RACCompoundDisposable.h"
#import "RACKVOProxy.h"

@interface RACKVOTrampoline ()

// The keypath which the trampoline is observing.
@property (nonatomic, readonly, copy) NSString *keyPath;

// These properties should only be manipulated while synchronized on the
// receiver.
@property (nonatomic, readonly, copy) RACKVOBlock block;
@property (nonatomic, readonly, unsafe_unretained) NSObject *unsafeTarget;
@property (nonatomic, readonly, weak) NSObject *weakTarget;
@property (nonatomic, readonly, weak) NSObject *observer;

@end

@implementation RACKVOTrampoline

#pragma mark Lifecycle

- (instancetype)initWithTarget:(__weak NSObject *)target observer:(__weak NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(RACKVOBlock)block {
	NSCParameterAssert(keyPath != nil);
	NSCParameterAssert(block != nil);

	NSObject *strongTarget = target;
	if (strongTarget == nil) return nil;

	self = [super init];

	_keyPath = [keyPath copy];
	_block = [block copy];
	_weakTarget = target;
	_unsafeTarget = strongTarget;
	_observer = observer;

    /*
     移交代理 --- 观察对象
    VC 有可能需要观察多个对象或其他属性（如：name,Dog ,Person 等等）,可理解为：每一个被监听的对象封装成一个 RACKVOTrampoline 对象，并把这些被已封装的 trampoline 对象全部添加到 sharedProxy 单例里面统一监听，如下一行代码：
     */
	[RACKVOProxy.sharedProxy addObserver:self forContext:(__bridge void *)self];
    
    
    // 然而 strongTarget（VC） 只需要观察 RACKVOProxy.sharedProxy 就可以了 ，并把相应的 keyPath 传给此单例即可 ，统一用 shareProxy 处理，如下一行代码：
	[strongTarget addObserver:RACKVOProxy.sharedProxy forKeyPath:self.keyPath options:options context:(__bridge void *)self];

    // 添加销毁者
	[strongTarget.rac_deallocDisposable addDisposable:self];
	[self.observer.rac_deallocDisposable addDisposable:self];

	return self;
}

- (void)dealloc {
	[self dispose];
}

#pragma mark Observation

- (void)dispose {
	NSObject *target;
	NSObject *observer;

	@synchronized (self) {
		_block = nil;

		// The target should still exist at this point, because we still need to
		// tear down its KVO observation. Therefore, we can use the unsafe
		// reference (and need to, because the weak one will have been zeroed by
		// now).
		target = self.unsafeTarget;
		observer = self.observer;

		_unsafeTarget = nil;
		_observer = nil;
	}
    // 销毁操作
	[target.rac_deallocDisposable removeDisposable:self];
	[observer.rac_deallocDisposable removeDisposable:self];

    // 移除监听
	[target removeObserver:RACKVOProxy.sharedProxy forKeyPath:self.keyPath context:(__bridge void *)self];
	[RACKVOProxy.sharedProxy removeObserver:self forContext:(__bridge void *)self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context != (__bridge void *)self) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}

	RACKVOBlock block;
	id observer;
	id target;
// 面向对象的 化整为零
	@synchronized (self) {
		block = self.block;
		observer = self.observer;
		target = self.weakTarget;
	}

	if (block == nil || target == nil) return;
    /*
      数值发生改变，然后调用 block 返回到 NSObject + RACKVOWrapper.m  这个类里面
      即： RACKVOTrampoline *trampoline 实例化的 block 里面
     */
	block(target, observer, change);
}

@end
