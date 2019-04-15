//
//  LoginViewModel.m
//  001---RACCommand
//
//  Created by Cooci on 2018/5/21.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "LoginViewModel.h"

@implementation LoginViewModel

- (instancetype)init{
    if (self = [super init]) {
        
        // 123 --> host ---
        RAC(self,iconUrl) = [[[RACObserve(self, account) skip:1] map:^id _Nullable(id  _Nullable value) {
            return [NSString stringWithFormat:@"www:%@",value];
        }] distinctUntilChanged];
        
        // 按钮点击能够 --- account + password  --- 函数 组合+聚合
        self.loginEnableSignal = [RACSignal combineLatest:@[RACObserve(self, account),RACObserve(self, password)] reduce:^id (NSString *account,NSString *password){
            return @(account.length>0&&password.length>0);
        }];
        
        self.islogining = NO;
        self.statusSubject = [RACSubject subject];
        [self setupLoginCommand];
    }
    return self;
}

- (void)setupLoginCommand{

    @weakify(self);
    // 初始commadn
    self.loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
       // 网络信号  --- 成功 -- 失败 -- 状态
        NSLog(@"input === %@",input);
        @strongify(self);
        return [self loginRequest];
    }];
    
    // 成功
    [[self.loginCommand.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchToLatest == %@",x);
        @strongify(self);
        self.islogining = NO;
        [self.statusSubject sendNext:@"登录成功"];
    }];
    // 失败
    [self.loginCommand.errors subscribeNext:^(NSError * _Nullable x) {
        NSLog(@"errors == %@",x);
        
        self.islogining = NO;
        [self.statusSubject sendNext:@"登录失败"];

    }];
    // 状态
    [[self.loginCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"executing == %@",x);
        if ([x boolValue]) {
            [self statusLableAnimation];
        }
    }];

}

#pragma mark - 网络请求
- (RACSignal *)loginRequest{
    // 抽取 -- 网络
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            [NSThread sleepForTimeInterval:2];
            if ([self.account isEqualToString:@"123"] && [self.password isEqualToString:@"123"]) {
                [subscriber sendNext:@"登录成功"]; // 序列化 --- [model class] -- @[model,model]
                [subscriber sendCompleted];
            }else{
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:100868 userInfo:@{@"LGError":@"fail"}];
                [subscriber sendError:error];
            }
        });
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
    }];
}

- (void)statusLableAnimation{
    self.islogining = YES;
    __block int num = 0;
    RACSignal *timerSignal = [[[RACSignal interval:0.5 onScheduler:[RACScheduler mainThreadScheduler]] map:^id _Nullable(NSDate * _Nullable value) {
        NSLog(@"登录时间:%@",value);
        NSString *statusStr = @"登录中,请稍后";
        num += 1;
        int count = num % 3;
        switch (count) {
            case 0:
                statusStr = @"登录中,请稍后.";
                break;
            case 1:
                statusStr = @"登录中,请稍后..";
                break;
            case 2:
                statusStr = @"登录中,请稍后...";
                break;
            default:
                break;
        }

        return statusStr;
    }] takeUntilBlock:^BOOL(id  _Nullable x) {
        if (num  > 10 || !self.islogining) {
            return YES;
        }
        return NO;
    }];
    
    [timerSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext == %@",x);
        [self.statusSubject sendNext:x];
    }];
    
}


- (NSString *)description{
    return [NSString stringWithFormat:@"%@-%@",self.account,self.password];
}

@end
