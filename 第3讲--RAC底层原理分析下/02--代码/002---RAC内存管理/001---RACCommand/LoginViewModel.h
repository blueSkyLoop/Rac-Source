//
//  LoginViewModel.h
//  001---RACCommand
//
//  Created by Cooci on 2018/5/21.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>
#import <SVProgressHUD.h>

@interface LoginViewModel : NSObject

@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) RACCommand *loginCommand;
@property (nonatomic, strong) RACSignal *validLoginSignal;
@property (nonatomic, strong) RACSubject *loginViewStatusSuject;
@property (nonatomic) BOOL logining;


@end
