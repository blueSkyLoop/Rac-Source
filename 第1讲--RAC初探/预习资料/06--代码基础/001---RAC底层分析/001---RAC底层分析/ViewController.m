//
//  ViewController.m
//  001---RAC底层分析
//
//  Created by Cooci on 2018/8/2.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // RAC 流程分析
    // 1: 信号产生
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        // 3:发送信号
        [subscriber sendNext:@"Cooci"];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"我们销毁了");
        }];
    }];
    // 2: 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅到了:%@",x);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
