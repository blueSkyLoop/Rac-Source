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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //绑定 视图 和 viewModel
    [self bindViewModelAndView];
}

- (void)bindViewModelAndView{
   
    @weakify(self);
    // vm  <-- UI 传递
    RAC(self.loginVM,account) = self.accountTF.rac_textSignal;
    RAC(self.loginVM,password) = self.passwordTF.rac_textSignal;
    // 按钮的点击能动性 --- account
    RAC(self.loginButton,enabled) = self.loginVM.loginEnableSignal;
    // 响应的发送 -- 响应的接受 --- vm -- > UI
    RAC(self.statuslabel,text) = self.loginVM.statusSubject;
    
    // vm ---> UI
    // RACObserve --> signal
    [RACObserve(self.loginVM, iconUrl) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.iconImageView.image = [UIImage imageNamed:x];
    }];
    
    // vm ---> signal
    [self.loginVM.loginEnableSignal subscribeNext:^(NSNumber *x) {
        @strongify(self);
        UIColor *color = (x.intValue == 0) ? [UIColor lightGrayColor] : [UIColor blueColor];
        [self.loginButton setBackgroundColor:color];
    }];
    
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
       // ----> vm  ---> 迁移
        // 涉及 ---> 网络 ---> 状态 -- 响应 ---- 命令 ---vm ---> 请求网络
        [self.loginVM.loginCommand execute:@"登录"];
        NSLog(@"按钮来了");
    }];
    
    

}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"%@",self.loginVM);
//}
//
#pragma mark - LAZY
- (LoginViewModel *)loginVM{
    if (!_loginVM) {
        _loginVM = [[LoginViewModel alloc] init];
    }
    return _loginVM;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
