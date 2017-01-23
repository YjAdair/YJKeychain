//
//  UserInfo.h
//  YJKeyChain
//
//  Created by yankezhi on 2017/1/19.
//  Copyright © 2017年 caohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *adress;
@property (nonatomic, copy) NSString *age;
@end
