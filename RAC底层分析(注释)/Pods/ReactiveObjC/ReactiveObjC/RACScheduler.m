//
//  RACScheduler.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 4/16/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACScheduler.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACImmediateScheduler.h"
#import "RACScheduler+Private.h"
#import "RACSubscriptionScheduler.h"
#import "RACTargetQueueScheduler.h"

// The key for the thread-specific current scheduler.
NSString * const RACSchedulerCurrentSchedulerKey = @"RACSchedulerCurrentSchedulerKey";

@interface RACScheduler ()
@property (nonatomic, readonly, copy) NSString *name;
@end

@implementation RACScheduler

#pragma mark NSObject

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, self.name];
}

#pragma mark Initializers

- (instancetype)initWithName:(NSString *)name {
	self = [super init];

	if (name == nil) {
		_name = [NSString stringWithFormat:@"org.reactivecocoa.ReactiveObjC.%@.anonymousScheduler", self.class];
	} else {
		_name = [name copy];
	}

	return self;
}

#pragma mark Schedulers

+ (RACScheduler *)immediateScheduler {
	static dispatch_once_t onceToken;
	static RACScheduler *immediateScheduler;
	dispatch_once(&onceToken, ^{
		immediateScheduler = [[RACImmediateScheduler alloc] init];
	});
	
	return immediateScheduler;
}

+ (RACScheduler *)mainThreadScheduler {
	static dispatch_once_t onceToken;
	static RACScheduler *mainThreadScheduler;
	dispatch_once(&onceToken, ^{
		mainThreadScheduler = [[RACTargetQueueScheduler alloc] initWithName:@"org.reactivecocoa.ReactiveObjC.RACScheduler.mainThreadScheduler" targetQueue:dispatch_get_main_queue()];
	});
	
	return mainThreadScheduler;
}

+ (RACScheduler *)schedulerWithPriority:(RACSchedulerPriority)priority name:(NSString *)name {
    // 开启一条指定的 全局子线程
	return [[RACTargetQueueScheduler alloc] initWithName:name targetQueue:dispatch_get_global_queue(priority, 0)];
}

+ (RACScheduler *)schedulerWithPriority:(RACSchedulerPriority)priority {
	return [self schedulerWithPriority:priority name:@"org.reactivecocoa.ReactiveObjC.RACScheduler.backgroundScheduler"];
}

+ (RACScheduler *)scheduler {
    //  RACSchedulerPriorityDefault 对 GCD 的 优先级封装了一次
	return [self schedulerWithPriority:RACSchedulerPriorityDefault];
}

+ (RACScheduler *)subscriptionScheduler {
	static dispatch_once_t onceToken;
	static RACScheduler *subscriptionScheduler;
	dispatch_once(&onceToken, ^{
		subscriptionScheduler = [[RACSubscriptionScheduler alloc] init];
	});

	return subscriptionScheduler;
}

+ (BOOL)isOnMainThread {
	return [NSOperationQueue.currentQueue isEqual:NSOperationQueue.mainQueue] || [NSThread isMainThread];
}

+ (RACScheduler *)currentScheduler {
    // 开始装逼了！ 取了一个当前线程的一个字典，并取了一个键值
    // 第一次默认没有值  scheduler 为空
	RACScheduler *scheduler = NSThread.currentThread.threadDictionary[RACSchedulerCurrentSchedulerKey];
    // 会跳过此判断
	if (scheduler != nil) return scheduler;
    // 如果当前调度器是在主线程执行， 就会给出一个自定义线程的 “调度器”
	if ([self.class isOnMainThread]) return RACScheduler.mainThreadScheduler;
    
    // 如果是在 子线程调用 就直接返回了 nil
	return nil;
}

#pragma mark Scheduling

- (RACDisposable *)schedule:(void (^)(void))block {
	NSCAssert(NO, @"%@ must be implemented by subclasses.", NSStringFromSelector(_cmd));
	return nil;
}

- (RACDisposable *)after:(NSDate *)date schedule:(void (^)(void))block {
	NSCAssert(NO, @"%@ must be implemented by subclasses.", NSStringFromSelector(_cmd));
	return nil;
}

- (RACDisposable *)afterDelay:(NSTimeInterval)delay schedule:(void (^)(void))block {
	return [self after:[NSDate dateWithTimeIntervalSinceNow:delay] schedule:block];
}

- (RACDisposable *)after:(NSDate *)date repeatingEvery:(NSTimeInterval)interval withLeeway:(NSTimeInterval)leeway schedule:(void (^)(void))block {
	NSCAssert(NO, @"%@ must be implemented by subclasses.", NSStringFromSelector(_cmd));
	return nil;
}

- (RACDisposable *)scheduleRecursiveBlock:(RACSchedulerRecursiveBlock)recursiveBlock {
	RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];

	[self scheduleRecursiveBlock:[recursiveBlock copy] addingToDisposable:disposable];
	return disposable;
}

- (void)scheduleRecursiveBlock:(RACSchedulerRecursiveBlock)recursiveBlock addingToDisposable:(RACCompoundDisposable *)disposable {
	@autoreleasepool {
		RACCompoundDisposable *selfDisposable = [RACCompoundDisposable compoundDisposable];
		[disposable addDisposable:selfDisposable];

		__weak RACDisposable *weakSelfDisposable = selfDisposable;

		RACDisposable *schedulingDisposable = [self schedule:^{
			@autoreleasepool {
				// At this point, we've been invoked, so our disposable is now useless.
				[disposable removeDisposable:weakSelfDisposable];
			}

			if (disposable.disposed) return;

			void (^reallyReschedule)(void) = ^{
				if (disposable.disposed) return;
				[self scheduleRecursiveBlock:recursiveBlock addingToDisposable:disposable];
			};

			// Protects the variables below.
			//
			// This doesn't actually need to be __block qualified, but Clang
			// complains otherwise. :C
			__block NSLock *lock = [[NSLock alloc] init];
			lock.name = [NSString stringWithFormat:@"%@ %s", self, sel_getName(_cmd)];

			__block NSUInteger rescheduleCount = 0;

			// Set to YES once synchronous execution has finished. Further
			// rescheduling should occur immediately (rather than being
			// flattened).
			__block BOOL rescheduleImmediately = NO;

			@autoreleasepool {
				recursiveBlock(^{
					[lock lock];
					BOOL immediate = rescheduleImmediately;
					if (!immediate) ++rescheduleCount;
					[lock unlock];

					if (immediate) reallyReschedule();
				});
			}

			[lock lock];
			NSUInteger synchronousCount = rescheduleCount;
			rescheduleImmediately = YES;
			[lock unlock];

			for (NSUInteger i = 0; i < synchronousCount; i++) {
				reallyReschedule();
			}
		}];

		[selfDisposable addDisposable:schedulingDisposable];
	}
}

- (void)performAsCurrentScheduler:(void (^)(void))block {
	NSCParameterAssert(block != NULL);

	// If we're using a concurrent queue, we could end up in here concurrently,
	// in which case we *don't* want to clear the current scheduler immediately
	// after our block is done executing, but only *after* all our concurrent
	// invocations are done.

    // 取出当前的调度器
	RACScheduler *previousScheduler = RACScheduler.currentScheduler;
    // 先把 backgroundScheduler 的子线程 进行 KVC 赋值
	NSThread.currentThread.threadDictionary[RACSchedulerCurrentSchedulerKey] = self;

	@autoreleasepool {
		block();
	}

    // 如果点前的 previousScheduler 不为空，往下走
	if (previousScheduler != nil) {
        // 使用当前的 RACScheduler 持续更新到  Key
		NSThread.currentThread.threadDictionary[RACSchedulerCurrentSchedulerKey] = previousScheduler;
	} else {
        // 移除
		[NSThread.currentThread.threadDictionary removeObjectForKey:RACSchedulerCurrentSchedulerKey];
	}
}

@end
