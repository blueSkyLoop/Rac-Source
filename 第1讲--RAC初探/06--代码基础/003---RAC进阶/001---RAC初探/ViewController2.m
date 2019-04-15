//
//  ViewController2.m
//  001---RAC初探
//
//  Created by Lucas on 2019/1/9.
//  Copyright © 2019年 Cooci. All rights reserved.
//

#import "ViewController2.h"
#import <ReactiveObjC.h>
@interface ViewController2 ()
@property (weak, nonatomic) IBOutlet UITextField *textF;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"ViewController2-----%@\nTF:%@",self,self.textF);
    }];
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textF resignFirstResponder];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    NSLog(@"ViewController2-----%@",self);
}
@end
