//
//  ViewController.m
//  AlertView
//
//  Created by yankezhi on 2017/1/5.
//  Copyright © 2017年 caohua. All rights reserved.
//

#import "ViewController.h"
#import "YJKeyChain.h"
#import "UserInfo.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self load];
}

- (void)load {
    
    NSArray *arr = [YJKeyChain loadAllInfoForService:@"TypeOne" resultType:1];
    for (YJKeyChainResult *result in arr) {
        NSLog(@"account %@",result.account);
        NSLog(@"serviceName %@",result.serviceName);
        NSLog(@"creatDate %@",result.creatDate);
        NSLog(@"finalModificationDate %@",result.finalModificationDate);
        UserInfo *info = (UserInfo *)result.codingData;
        NSLog(@"info.name %@", info.name);
        NSLog(@"info.password %@", info.password);
        NSLog(@"info.adress %@", info.adress);
        NSLog(@"info.age %@", info.age);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
