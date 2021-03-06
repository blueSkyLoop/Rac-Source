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

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, copy) NSString *name;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)retry{
    //retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
    //    __block int i = 0;
    //    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    //        if (i == 10) {
    //            [subscriber sendNext:@1];
    //        }else{
    //            NSLog(@"接收到错误");
    //            [subscriber sendError:nil];
    //        }
    //        i++;
    //        return nil;
    //
    //    }] retry] subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //    } error:^(NSError *error) {
    //
    //    }];
    // `replay`重放：当一个信号被多次订阅,反复播放内容
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        return nil;
    }] replay];
    [signal subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    
    
    
    
}

- (void)timeOut{
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
        
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    
    
    [signal subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
        
    } error:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
        
    }];
    
}

- (void)testSwitchToLatest {
    
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    // 获取信号中信号最近发出信号，订阅最近发出的信号。
    // 注意switchToLatest：只能用于信号中的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) { NSLog(@"%@",x);
    }];
    [signalOfSignals sendNext:signal];
    [signal sendNext:@1];
    
    
}

// takeUntil:---给takeUntil传的是哪个信号，那么当这个信号发送信号或sendCompleted，就不能再接受源信号的内容了。
- (void)takeUntil {
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject takeUntil:subject2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    //    [subject2 sendNext:@3];  // 1
    //    [subject2 sendCompleted]; // 或2
    [subject sendNext:@4];
}



//takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
//注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
- (void)takeLast {
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
}



// take:可以屏蔽一些值,去前面几个值---这里take为2 则只拿到前两个值
- (void)take {
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

- (void)testSkip{
    
    // 表示输入第一次，不会被监听到，跳过第一次发出的信号
    [[self.textField.rac_textSignal skip:1] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
}

- (void)testDistinctUntilChanged{
    
    // 当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
    //在开发中，刷新UI经常使用，只有两次数据不一样才需要刷新
    
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2];
}



- (void)testIgnore{
    
    // 内部调用filter过滤，忽略掉ignore的值
    
    [[self.textField.rac_textSignal ignore:@"c"] subscribeNext:^(NSString * _Nullable x) {
        
        NSLog(@"%@",x);
    }];
    
}

- (void)testFilter{
    //filter:过滤信号，使用它可以获取满足条件的信号.
    
    // 过滤:
    // 每次信号发出，会先执行过滤条件判断.
    RACSignal *signal = [self.textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        
        if (self.textField.text.length>6) {
            self.textField.text = [self.textField.text substringToIndex:6];
        }
        
        NSLog(@"value == %@",value);
        return value.length<6;
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        self.textField.text = x;
        
        NSLog(@"x== %@",x);
    }];
    
}



- (void)testReduce{
    //reduce`聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
    
    //其中Aggregation(聚合关系)、Composition(合成关系)属于Association(关联关系)，是特殊的Association关联关系。
    //可以延伸组合关系,聚合关系
    //组合关系 A-B组合成了C C包含所有的A和B
    //聚合关系 聚合关系是整体和个体的关系(是强的关联关系) 公司与个人,但是个人不完全属于公司
    
    // 聚合 // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    RACSignal *signalA = self.textField.rac_textSignal;
    RACSignal *signalB = [self.button  rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,signalB] reduce:^(id value1, id value2){
        
        return [NSString stringWithFormat:@"reduce == %@ %@",value1,value2];
    }];
    
    [reduceSignal subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"subscribeNext == %@",x);
    }];
    // 1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值。
    
}


- (void)testCombineLatest{
    //将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
    
    RACSignal *signalA = self.textField.rac_textSignal;
    RACSignal *signalB = [self.button  rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *comSignal = [signalA combineLatestWith:signalB];
    
    [comSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // 底层实现：
    // 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
    // 2.并且把两个信号组合成元组发出。
    
    //区别于zipWith  zipWith两个信号都要有记录,如果记录的信号触发过了 就不在触发
    //zipWith 记录每一次信号  combineLatestWith记录最后一次的信号
    
}

- (void)testZip{
    
    // 底层实现:
    // 1.定义压缩信号，内部就会自动订阅signalA，signalB
    // 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出。
    
    RACSignal *signalA = self.textField.rac_textSignal;
    RACSignal *signalB = [self.button  rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}

- (void)testMerge{
    
    // merge:把多个信号合并成一个信号
    //创建多个信号
    RACSignal *signalA = self.textField.rac_textSignal;
    RACSignal *signalB = [self.button  rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    
    
}

- (void)testThen{
    
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"Cooci"];
        
        [subscriber sendCompleted];
        
        return nil;
    }] then:^RACSignal * _Nonnull{
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendNext:@"Gavin"];
            [subscriber sendCompleted];
            return nil;
        }];
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
    }];
    
}


- (void)testContact{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"Cooci"];
        
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"Gavin"];
        
        [subscriber sendCompleted];
        
        return nil;
        
    }];
    
    RACSignal *contactSignal = [signalA concat:signalB];
    
    [contactSignal subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
    }];
    
    
    
}


- (void)testBind{
    
    // 方式二:在返回结果前，拼接，使用RAC中bind方法做处理。
    // bind方法参数:需要传入一个返回值是RACStreamBindBlock的block参数
    // RACStreamBindBlock是一个block的类型，返回值是信号，参数（value,stop），因此参数的block返回值也是一个block。
    // RACStreamBindBlock:
    // 参数一(value):表示接收到信号的原始值，还没做处理
    // 参数二(*stop):用来控制绑定Block，如果*stop = yes,那么就会结束绑定。
    // 返回值：信号，做好处理，在通过这个信号返回出去，一般使用RACReturnSignal,需要手动导入头文件RACReturnSignal.h。
    
    // bind方法使用步骤:
    // 1.传入一个返回值RACStreamBindBlock的block。
    // 2.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
    // 3.描述一个返回结果的信号，作为bindBlock的返回值。
    
    // 注意：在bindBlock中做信号结果的处理。
    // 底层实现:
    // 1.源信号调用bind,会重新创建一个绑定信号。
    // 2.当绑定信号被订阅，就会调用绑定信号中的didSubscribe，生成一个bindingBlock。
    // 3.当源信号有内容发出，就会把内容传递到bindingBlock处理，调用bindingBlock(value,stop)
    // 4.调用bindingBlock(value,stop)，会返回一个内容处理完成的信号（RACReturnSignal）。
    // 5.订阅RACReturnSignal，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
    
    // 注意:不同订阅者，保存不同的nextBlock，看源码的时候，一定要看清楚订阅者是哪个。
    // 这里需要手动导入#import <ReactiveCocoa/RACReturnSignal.h>，才能使用RACReturnSignal。
    
    
    [[self.textField.rac_textSignal bind:^RACSignalBindBlock _Nonnull{
        
        return ^RACSignal * (id _Nullable value, BOOL *stop) {
            
            return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
        };
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"subscribeNext == %@",x);
    }];
}


- (void)testMapFlattenMap{
    
    [[self.textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        
        return YES;
        
    }] subscribeNext:^(NSString * _Nullable x) {
        
        NSLog(@"filter == %@",x);
        
    }];
    
    
    [[self.textField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        
        return nil;
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"map == %@",x);
    }];
    
    // flattenMap作用:把源信号的内容映射成一个新的信号，信号可以是任意类型。
    
    // flattenMap使用步骤:
    // 1.传入一个block，block类型是返回值RACStream，参数value
    // 2.参数value就是源信号的内容，拿到源信号的内容做处理
    // 3.包装成RACReturnSignal信号，返回出去。
    
    // flattenMap底层实现:
    // 0.flattenMap内部调用bind方法实现的,flattenMap中block的返回值，会作为bind中bindBlock的返回值。
    // 1.当订阅绑定信号，就会生成bindBlock。
    // 2.当源信号发送内容，就会调用bindBlock(value, *stop)
    // 3.调用bindBlock，内部就会调用flattenMap的block，flattenMap的block作用：就是把处理好的数据包装成信号。
    // 4.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
    // 5.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
    
    [[self.textField.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        
        NSLog(@"%@",value);
        
        return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"flattenMap == %@",x);
        
    }];
}

- (void)racBase{
    
    // 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        [subscriber sendNext:@"Cooci"];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        //        [subscriber sendCompleted];
        
        NSLog(@"subscriber == %@",subscriber);
        
        RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            // 销毁信号
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"开始销毁");
        }];
        
        return disposable;
        
    }];
    
    // 订阅信号,才会激活信号.
    [signal subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"x == %@",x);
    }];
}


- (void)testTimer{
    
    [[RACSignal interval:1 onScheduler:[RACScheduler scheduler]] subscribeNext:^(NSDate * _Nullable x) {
        
        NSLog(@"%@",[NSThread currentThread]);
        
    }];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.name = [NSString stringWithFormat:@"%@+",self.name];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
