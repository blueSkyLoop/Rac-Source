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
        //绑定头像和账号
        RAC(self,iconUrl) = [[[RACObserve(self, account) skip:1] map:^id _Nullable(id  _Nullable value) {
            return [NSString stringWithFormat:@"www:%@",value];
        }] distinctUntilChanged];
        
        //登录按钮能否点击效果
        self.validLoginSignal = [[RACSignal combineLatest:@[RACObserve(self, account),RACObserve(self, password)] reduce:^(NSString *account,NSString *password){
            return @(account.length>0 && password.length>0);
        }] distinctUntilChanged];
        
        //登录状态
        self.logining = NO;
        self.loginViewStatusSuject = [RACSubject subject];
        //按钮事件
        [self setupLoginCommand];
        
    }
    return self;
}


- (void)setupLoginCommand{
    @weakify(self);
    //按钮点击command
    self.loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input == %@",input);
        @strongify(self);
        return [self loginAccountLoadData];
    }];
    
    [[self.loginCommand.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        //成功的时候执行
        @strongify(self);
        NSLog(@"executionSignals == %@",x);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loginViewStatusSuject sendNext:@"登陆成功"];
        });
        self.logining = NO;
    }];
    
    [[self.loginCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        NSLog(@"executing == %@",x);
//        [SVProgressHUD showWithStatus:@"登录中,请稍后..."];
        if ([x boolValue]) {
            [self statusLableAnimation];
        }
    }];
    
    [self.loginCommand.errors subscribeNext:^(NSError * _Nullable x) {
        @strongify(self);
        NSLog(@"errors:subscribeNext == %@",x);
        [self.loginViewStatusSuject sendNext:@"登陆失败"];
        self.logining = NO;
    }];
    
}

- (RACSignal *)loginAccountLoadData{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [NSThread sleepForTimeInterval:3];
            if ([self.account isEqualToString:@"123"]&&[self.password isEqualToString:@"123"]) {
                [subscriber sendNext:@"登陆成功"];
                [subscriber sendCompleted];
            }else{
                NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:522 userInfo:@{@"NSErrorUserInfoKey":@"Today is 522"}];
                [subscriber sendError:error];
            }
        });

        return nil;
    }];
}

- (void)statusLableAnimation{
    __block int num = 0;
    self.logining = YES;
    
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
        
        if (num >= 20 || !self.logining) {
            return YES;
        }
        return NO;
    }];
    
    [timerSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext == %@",x);
        if (self.logining) {
            [self.loginViewStatusSuject sendNext:x];
        }
    }];
    
    
}

@end
