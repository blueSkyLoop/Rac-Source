//
//  ViewController.m
//  001---RAC初探
//
//  Created by Cooci on 2018/4/17.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import <RACReturnSignal.h>
#import "RACPassthroughSubscriber.h"
#import "Dog.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, strong) RACPassthroughSubscriber *subsrcribe;
@property (nonatomic, strong) RACSignal  *signal;
/** dog */
@property (nonatomic, strong) Dog *dog;
@property (nonatomic, copy) NSString *name;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self lo_Observe];
    
    [self lo_signal];
}


- (void)lo_command {
//    RACCommand 继承于 object
}


- (void)lo_Macro { // 宏定义
     // 宏 ：
    // # 宏参数代替参数值为内容的字符常量
    // A##B ---> AB

}


- (void)lo_signal {
    // 1 创建信号
    // 产生 signal 与 didSubscribe Block
    @weakify(self)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        self.subsrcribe = subscriber;
        
        NSLog(@"创建了信号");
        
        // 3 发送信号
        [subscriber sendNext:@"hahah"];
        
        
        
        
//        [subscriber sendError:nil];
        
        [subscriber sendCompleted];
        
        // 4 销毁信号
        // return self.dis; 销毁回调
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"我们销毁了");
        }];
    }];
    
    self.signal = signal;
    
    
    // 2 订阅信号
    // 订阅者 包含有 subscriber、signal、disposable
    // a.创建 subscribe 对象 并保存 Next Error、Completed 三个Block
    // b.传入 subscribe 并创建 disposable，
    // c. disposable、signal、subscribe 三者合成 （RACPassthroughSubscriber*）subscribe
    // 把 signal.didSubscribe(subscribe)传出
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext:%@",x);
    }];
    //  signal subscriber 销毁 --- RAC
    /*
     注意：以下两个方法，要是被调用一次后，订阅者（subscriber）subscribeNext 函数不会再被响应
             [subscriber sendError:nil];
             [subscriber sendCompleted];
        以上两个方法，内部分别都调用了  [self.disposable dispose]; 使得 subscribeNext 失效
     */
    [signal subscribeError:^(NSError * _Nullable error) {
        NSLog(@"subscribeError");
    }];
    
    
    [signal subscribeCompleted:^{
        NSLog(@"subscribeCompleted");
    }];
}


- (void)lo_Observe {
    [RACObserve(self, name) subscribeNext:^(id  _Nullable x) {
        
    }];
    
    [RACObserve(self, dog) subscribeNext:^(id  _Nullable x) {
        
    }];
}


- (void)lo_subject {
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"subject:%@",x);
    }];
    
    [subject sendNext:@"haha"];
}

- (void)lo_MulticastConnection {
    // 1.创建信号
    RACSignal *signal  = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"信号产生了");
        
        [NSThread sleepForTimeInterval:1];
        // 3 信号发送
        [subscriber sendNext:@"cooci"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
    }];
    
    
    // 2. 信号订阅 ----> 信号订阅产生 ----> signal
    
    /*
     // 当需要多次订阅时，若直接使用此方法多次订阅，会使得产生多个信号量，  signal 的 didSubscribe block 会进行多次回调从而导致 “带宽问题”
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅1");
    }];
     [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅2");
     }];
     [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅3");
     }];
    */
    
    //  所以我们一下方法避免此类情况
    RACMulticastConnection *connect = [signal publish];
    //  connect.signal --->  subject (connect内部新建的变量) --> add subcriber --> subject.subcribers
    //  所以 connect.signal subscribeNext: 执行的是  RACSubject subscribe:
    //  循环 ---- 遍历 sendNext --- 都能来
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅1");
    }];
    
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅2");
    }];
    
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅3");
    }];
    // 函数 ---> signal 只产生了一次, 以下是核心方法
    [connect connect];
}


- (IBAction)Action:(id)sender {
    // subsrcribe 是 RACPassthroughSubscriber 类型
//    [self.subsrcribe sendNext:@"发送"];
    self.name = @"hahaha";
}

- (IBAction)errorAction:(id)sender {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:100 userInfo:@{@"LG":@"HHHH"}];
    
    [self.subsrcribe sendError:error];
    
}
- (IBAction)comAction:(id)sender {
    [self.subsrcribe sendCompleted];
}

@end
