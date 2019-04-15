//
//  RACKVOProxy.m
//  ReactiveObjC
//
//  Created by Richard Speyer on 4/10/14.
//  Copyright (c) 2014 GitHub, Inc. All rights reserved.
//

#import "RACKVOProxy.h"

@interface RACKVOProxy()

@property (strong, nonatomic, readonly) NSMapTable *trampolines;
@property (strong, nonatomic, readonly) dispatch_queue_t queue;

@end

@implementation RACKVOProxy

+ (instancetype)sharedProxy {
	static RACKVOProxy *proxy;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		proxy = [[self alloc] init];
	});

	return proxy;
}

- (instancetype)init {
	self = [super init];
    // 串行，线性安全：确保每次数值改变是有序的
	_queue = dispatch_queue_create("org.reactivecocoa.ReactiveObjC.RACKVOProxy", DISPATCH_QUEUE_SERIAL);
	_trampolines = [NSMapTable strongToWeakObjectsMapTable];

	return self;
}

// 添加 trampoline 对象
- (void)addObserver:(__weak NSObject *)observer forContext:(void *)context {
	NSValue *valueContext = [NSValue valueWithPointer:context];
    // 把被观察的对象 放到 trampolines（表） 里去
	dispatch_sync(self.queue, ^{
		[self.trampolines setObject:observer forKey:valueContext];
	});
}


// 移除 trampoline 对象
- (void)removeObserver:(NSObject *)observer forContext:(void *)context {
	NSValue *valueContext = [NSValue valueWithPointer:context];

	dispatch_sync(self.queue, ^{
		[self.trampolines removeObjectForKey:valueContext];
	});
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSValue *valueContext = [NSValue valueWithPointer:context];
	__block NSObject *trueObserver;

	dispatch_sync(self.queue, ^{
        // 取出被改变值的 trampolines 对象
		trueObserver = [self.trampolines objectForKey:valueContext];
	});

	if (trueObserver != nil) {
        /*
         使用对应的 RACKVOTrampoline 对象返回出去给 “RACKVOTrampoline” 这个类中的
          - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
         */
		[trueObserver observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
