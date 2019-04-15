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

typedef void(^KCBlock)(id para);
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statuslabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) LoginViewModel *loginVM;
@property (nonatomic, copy)   KCBlock block;

@property (nonatomic, strong) RACDisposable *dis;
@property (nonatomic, strong) RACSignal *signal;
@property (nonatomic, strong) id<RACSubscriber> subscriber;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // onbject
    // 状态 是否正在执行 --- error -- 成功
    
    self.loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@",input);
        return [RACSignal empty];
    }];
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input === %@",input);
        // 登录 ---> 注册 --- ?????
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"cooci"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"销毁");
            }];
        }];
    }];
    
    // addedExecutionSignalsSubject  --> signal  ---
    // 班长 --- 小兵  -- 拉练
    // 排长 -- addedExecutionSignalsSubject
    [command.executionSignals subscribeNext:^(id  _Nullable x) {
        NSLog(@"executionSignals == %@",x);
    }];
    
    [[command.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchToLatest == %@",x);
    }];
    
    [command.executing subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"executing == %@",x);
    }];
    
    [command.errors subscribeError:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
        
    }];
    
    [command execute:@"命令"];

}



- (void)dealloc{
    NSLog(@"dealloc:来了");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
