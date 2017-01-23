//
//  ViewController.m
//  YJKeyChain
//
//  Created by yankezhi on 2017/1/14.
//  Copyright © 2017年 caohua. All rights reserved.
//

#import "ViewController.h"
#import "YJKeyChain.h"
#import "UserInfo.h"
static NSString * const typeOne = @"TypeOne";
static NSString * const typeTwo = @"TypeTwo";
static NSString * const typeThird = @"TypeThird";
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *field1;
@property (weak, nonatomic) IBOutlet UITextField *field2;
@property (weak, nonatomic) IBOutlet UITextField *field3;
@property (weak, nonatomic) IBOutlet UITextField *field4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)saveTypeOne {
    
    NSLog(@"保存结果 %d", [YJKeyChain setPassword:self.field2.text account:self.field1.text forService:typeOne]);
}

- (void)saveTypeTwo {
    
    NSString *str = self.field2.text;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"保存结果 %d", [YJKeyChain setNormalData:data account:self.field1.text forService:typeOne]);
}

- (void)saveTypeThird {
    
    UserInfo *info = [[UserInfo alloc] init];
    info.name = self.field1.text;
    info.password = self.field2.text;
    info.adress = self.field3.text;
    info.age = self.field4.text;
    NSLog(@"保存结果 %d", [YJKeyChain setComplexData:info account:info.name forService:typeOne]);
}

- (void)loadTypeOne {
    
    NSArray *arr = [YJKeyChain loadAllInfoForService:typeOne resultType:1];
    for (YJKeyChainResult *result in arr) {
        NSLog(@"account %@",result.account);
        NSLog(@"serviceName %@",result.serviceName);
        NSLog(@"creatDate %@",result.creatDate);
        NSLog(@"finalModificationDate %@",result.finalModificationDate);
        //        NSLog(@"password %@",result.password);
        //        NSLog(@"data %@ password %@",result.data ,[[NSString alloc] initWithData:result.data encoding:NSUTF8StringEncoding]);
        UserInfo *info = (UserInfo *)result.codingData;
        NSLog(@"info.name %@", info.name);
        NSLog(@"info.password %@", info.password);
        NSLog(@"info.adress %@", info.adress);
        NSLog(@"info.age %@", info.age);
    }
}

- (void)loadTypeTwo {
    
    NSArray *arr = [YJKeyChain loadAllInfoForService:typeOne resultType:1];
    for (YJKeyChainResult *result in arr) {
        NSLog(@"account %@",result.account);
        NSLog(@"serviceName %@",result.serviceName);
        NSLog(@"creatDate %@",result.creatDate);
        NSLog(@"finalModificationDate %@",result.finalModificationDate);
        //        NSLog(@"password %@",result.password);
        //        NSLog(@"data %@ password %@",result.data ,[[NSString alloc] initWithData:result.data encoding:NSUTF8StringEncoding]);
        UserInfo *info = (UserInfo *)result.codingData;
        NSLog(@"info.name %@", info.name);
        NSLog(@"info.password %@", info.password);
        NSLog(@"info.adress %@", info.adress);
        NSLog(@"info.age %@", info.age);
    }
}

- (void)deleteTypeOne {
    
    NSLog(@"删除结果 %d", [YJKeyChain deleteAllInfoForService:typeOne]);
}

- (void)deleteTypeTwo {
    
    NSLog(@"删除结果 %d", [YJKeyChain deleteInfoForService:typeOne account:self.field1.text]);
}

- (IBAction)saveOperation:(id)sender {
    
    [self saveTypeThird];
}

- (IBAction)loadOperation:(id)sender {

    [self loadTypeTwo];
}
- (IBAction)deleteOperation:(id)sender {

    [self deleteTypeOne];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
