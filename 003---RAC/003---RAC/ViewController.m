//
//  ViewController.m
//  003---RAC
//
//  Created by Cooci on 2018/4/16.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, copy) NSString *name;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // RAC --- 信号
    // 1:创建信号
    // 函数式  y = f(x) --> y = f(f(x)) 定义域 值域
    // f(x) --> 表达式 (代码块)
    // RACDynamicSignal
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        // 3: 发送信号
        [subscriber sendNext:@"cooci"];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
    }];
    
    // 2: 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅来了:%@",x);
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
