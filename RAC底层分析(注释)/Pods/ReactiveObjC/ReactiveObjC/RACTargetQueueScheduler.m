//
//  RACTargetQueueScheduler.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 6/6/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "RACTargetQueueScheduler.h"
#import "RACQueueScheduler+Subclass.h"

@implementation RACTargetQueueScheduler

#pragma mark Lifecycle

- (instancetype)initWithName:(NSString *)name targetQueue:(dispatch_queue_t)targetQueue {
	NSCParameterAssert(targetQueue != NULL);

	if (name == nil) {
		name = [NSString stringWithFormat:@"org.reactivecocoa.ReactiveObjC.RACTargetQueueScheduler(%s)", dispatch_queue_get_label(targetQueue)];
	}
    // 串行队列
    // 保证 信号有序执行，所以采用 “异步串行”
	dispatch_queue_t queue = dispatch_queue_create(name.UTF8String, DISPATCH_QUEUE_SERIAL);
	if (queue == NULL) return nil;

	dispatch_set_target_queue(queue, targetQueue);

	return [super initWithName:name queue:queue];
}

@end
