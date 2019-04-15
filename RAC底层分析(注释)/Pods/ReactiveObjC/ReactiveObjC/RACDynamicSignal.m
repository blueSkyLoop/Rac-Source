//
//  RACDynamicSignal.m
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2013-10-10.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "RACDynamicSignal.h"
#import <ReactiveObjC/RACEXTScope.h>
#import "RACCompoundDisposable.h"
#import "RACPassthroughSubscriber.h"
#import "RACScheduler+Private.h"
#import "RACSubscriber.h"
#import <libkern/OSAtomic.h>

@interface RACDynamicSignal ()

// The block to invoke for each subscriber.
@property (nonatomic, copy, readonly) RACDisposable * (^didSubscribe)(id<RACSubscriber> subscriber);

@end

@implementation RACDynamicSignal

#pragma mark Lifecycle

+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
	RACDynamicSignal *signal = [[self alloc] init];
	signal->_didSubscribe = [didSubscribe copy];
	return [signal setNameWithFormat:@"+createSignal:"];
}

#pragma mark Managing Subscribers
// 重点： RAC 精髓
- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	NSCParameterAssert(subscriber != nil);

    // 传入 subscribe 并创建 disposable，
    // 复合销毁者
	RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
    
    // 多态 --- 厉害
    /**
     *  subscriber --- RACSubscriber
     *  signal
     *  disposable
     */

    //  新的（RACPassthroughSubscriber*）subscriber 拥有：disposable、signal、subscribe 三者合成
	subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];

    // signal 有执行 didsubscribe Block 往下走
	if (self.didSubscribe != NULL) {
        // 多线程 --- CPU --- 自己跑了
        
        //  这里需要注意！！！！  如果开启了异步操作，RACScheduler.subscriptionScheduler 的类型是 “RACTargetQueueScheduler” 并在子线程执行 【RACTargetQueueScheduler schedule:】
        
		RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
            
//             使用 signal.didSubscribe(subscribe)传出到
//     createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) 这个代码块
            
			RACDisposable *innerDisposable = self.didSubscribe(subscriber);
            // 添加销毁
			[disposable addDisposable:innerDisposable];
		}];

		[disposable addDisposable:schedulingDisposable];
	}
	
	return disposable;
}

@end
