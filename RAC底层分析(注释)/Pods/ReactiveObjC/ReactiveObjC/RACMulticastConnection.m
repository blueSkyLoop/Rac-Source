//
//  RACMulticastConnection.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 4/11/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACMulticastConnection.h"
#import "RACMulticastConnection+Private.h"
#import "RACDisposable.h"
#import "RACSerialDisposable.h"
#import "RACSubject.h"
#import <libkern/OSAtomic.h>

@interface RACMulticastConnection () {
	RACSubject *_signal;

	// When connecting, a caller should attempt to atomically swap the value of this
	// from `0` to `1`.
	//
	// If the swap is successful the caller is resposible for subscribing `_signal`
	// to `sourceSignal` and storing the returned disposable in `serialDisposable`.
	//
	// If the swap is unsuccessful it means that `_sourceSignal` has already been
	// connected and the caller has no action to take.
	int32_t volatile _hasConnected;
}

@property (nonatomic, readonly, strong) RACSignal *sourceSignal;
@property (strong) RACSerialDisposable *serialDisposable;
@end

@implementation RACMulticastConnection

#pragma mark Lifecycle

- (instancetype)initWithSourceSignal:(RACSignal *)source subject:(RACSubject *)subject {
	NSCParameterAssert(source != nil);
	NSCParameterAssert(subject != nil);

	self = [super init];

	_sourceSignal = source;
	_serialDisposable = [[RACSerialDisposable alloc] init];
	_signal = subject;
	
	return self;
}

#pragma mark Connecting

- (RACDisposable *)connect {
    
//   注意 ： OSAtomicCompareAndSwap32Barrier(对比值a, 匹配成功的赋值, 对比值b)
    // 对比函数
    // 0 VS _hasConnected ---> YES  _hasConnected ---> 1
    // 因为第一次进来的时候，_hasConnected == 0 ，进行一次赋值之后 _hasConnected 赋值等于 1
    // 第二次进来时，  _hasConnected == 1 与 0 匹配不上，
	BOOL shouldConnect = OSAtomicCompareAndSwap32Barrier(0, 1, &_hasConnected);
    
    // 以下的代码，只执行一次
	if (shouldConnect) {
        //  self.sourceSignal 是 dynamicSignal
        //  所以确保了  signal  的  didSubscribe Block 只执行了一次
		self.serialDisposable.disposable = [self.sourceSignal subscribe:_signal];
	}

	return self.serialDisposable;
}

- (RACSignal *)autoconnect {
	__block volatile int32_t subscriberCount = 0;

	return [[RACSignal
		createSignal:^(id<RACSubscriber> subscriber) {
			OSAtomicIncrement32Barrier(&subscriberCount);

			RACDisposable *subscriptionDisposable = [self.signal subscribe:subscriber];
			RACDisposable *connectionDisposable = [self connect];

			return [RACDisposable disposableWithBlock:^{
				[subscriptionDisposable dispose];

				if (OSAtomicDecrement32Barrier(&subscriberCount) == 0) {
					[connectionDisposable dispose];
				}
			}];
		}]
		setNameWithFormat:@"[%@] -autoconnect", self.signal.name];
}

@end
