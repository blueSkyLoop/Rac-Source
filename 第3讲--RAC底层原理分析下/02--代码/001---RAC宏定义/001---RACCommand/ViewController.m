//
//  ViewController.m
//  001---RACCommand
//
//  Created by Cooci on 2018/5/20.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import "LoginViewModel.h"
#import <SVProgressHUD.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statuslabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) LoginViewModel *loginVM;
@property (nonatomic, copy) NSString *name;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    weakify(...)
    strongify(<#...#>)
    RAC
    RACTuple
    RAC(<#TARGET, ...#>)
    RAC

    // 宏 :
    // # 红参数代替参数值为内容的自负常量
    // A##B---->AB
    // ... 参数 ---  __VA_ARGS -- LOG
    // 封装流程 --- 装逼
    // ... self name
    metamacro_foreach_cxt(rac_weakify_,, __weak, __VA_ARGS__)
#define metamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \

    MACRO = rac_weakify_
    SEP   =
    CONTEXT = __weak
    
metamacro_concat(metamacro_foreach_cxt, metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)
    
    // 什么意思: argcount 参数个数
    metamacro_argcount()
    metamacro_at(20, self,name, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
    metamacro_concat(metamacro_at, N)(__VA_ARGS__)  --->  2
    
    metamacro_at20(...)
    
    // 20个元素
    // __VA_ARGS__ = 2,1
    // ... ---> 容那  ---> 2, 1
    
    #define metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...)
    
    #define metamacro_at20(self,name, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, ) metamacro_head(__VA_ARGS__)  ---> first
    
    // c 静态语言
    metamacro_foreach_cxt2(MACRO, SEP, CONTEXT, __VA_ARGS__)
    // 下面
    metamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
    metamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) \

    MACRO(1, CONTEXT, _1)
    
    rac_weakify_(1,context,_1)
    CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);

    __weak __typeof__(self) self_weak_ = self;
    
    王巍 -- rac_weakify_
    
    
}



- (void)subject{
    
    @weakify(self);
    // 1:创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"信号产生了");
        
        [NSThread sleepForTimeInterval:1];  // 带宽
        // 3:信号发送
        [subscriber sendNext:@"cooci"];
        // 4:销毁信号
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
    }];
    
    RACMulticastConnection *connect = [signal publish];
    
    // connect.signal ---> subject  add subcriber ---> subject.subcribers
    // 2:信号订阅 ---> 信号订阅的产生 ---- signal
    // 循环 --- 遍历 sendNext --- 都能来
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"1:订阅到了%@",x);
    }];
    
    // 2:信号订阅 ---> 信号订阅的产生 ---- signal
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"2:订阅到了%@",x);
    }];
    
    // 2:信号订阅 ---> 信号订阅的产生 ---- signal
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"3:订阅到了%@",x);
    }];
    
    // 函数 ---> signal 产生只执行一次
    [connect connect];
}

- (void)demoSubject{
    // 子类 --- 发送信号还能订阅
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"三文鱼"];
    // 应用场景 --- 发送信号 --- 响应信号 --- UI --- UI
}

- (void)demo{
    // 1:创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"信号产生了");
        // 3:信号发送
        [subscriber sendNext:@"cooci"];
        // 4:销毁信号
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
    }];
    
    // 2:信号订阅 ---> 信号订阅的产生 ---- signal
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅到了%@",x);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
