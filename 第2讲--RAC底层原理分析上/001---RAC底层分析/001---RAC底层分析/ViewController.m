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
@property (nonatomic, strong) RACDisposable *dispos;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) id<RACSubscriber> kcSubscriber;
@property (nonatomic, strong) RACSignal *signal;
@property (nonatomic, strong) RACMulticastConnection *connect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // auto ---
    // 大量临时变量
    // 自定义线程 -- 管理
    // 执行非UI操作
    // 活跃度 : 学习 写博客
    // RAC 流程分析
    // 1:创建信号
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        @weakify(self)
        RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            self.kcSubscriber  = subscriber;
            NSLog(@"来了,请求网络");
            // 3:发送信号
            [subscriber sendNext:@"Cooci"];
            // 4:销毁
            // return self.dis; 销毁回调
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"我们销毁了");
            }];
        }];
        self.signal = signal;
        // 2: 订阅信号
        RACDisposable *disp = [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"0:订阅到了:%@",x);
        }];
        
    });
}

- (IBAction)didClickBtnClickOne:(id)sender {
    
    [self.kcSubscriber sendNext:@"RAC"];
    
}
- (IBAction)didClickBtnClickTwo:(id)sender {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:10088 userInfo:@{@"LGError":@"hhaha "}];
    [self.kcSubscriber sendError:error];
}
- (IBAction)didClickBtnClickThree:(id)sender {
   
    [self.kcSubscriber sendCompleted];
}

- (void)dealloc{
    NSLog(@"走了");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
