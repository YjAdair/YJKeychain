//
//  YJKeyChain.h
//  YJKeyChain
//
//  Created by yankezhi on 2017/1/14.
//  Copyright © 2017年 caohua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YJSynStrategies){
    
    YJSynStrategiesAfterFirstUnlock,
    YJSynStrategiesWhenUnlocked,
    YJSynStrategiesAlways,
    YJSynStrategiesWhenPasscodeSetThisDeviceOnly,
    YJSynStrategiesWhenUnlockedThisDeviceOnly,
    YJSynStrategiesAfterFirstUnlockThisDeviceOnly,
    YJSynStrategiesAlwaysThisDeviceOnly,
    YJSynStrategiesNull = -1000
};

#pragma mark - YJKeyChainResult
@interface YJKeyChainResult : NSObject

/** 账号 **/
@property (nonatomic, copy) NSString *account;
/** 保存的数据类型一： NSString 密码 **/
@property (nonatomic, copy) NSString *password;
/** 保存的数据类型二： id<NSCoding> **/
@property (nonatomic, strong) id<NSCoding> codingData;
/** 保存的数据类型三:   NSData **/
@property (nonatomic, strong) NSData *data;
/** 目标数据库 **/
@property (nonatomic, copy) NSString *serviceName;
/** 创建时间 **/
@property (nonatomic, copy) NSString *creatDate;
/** 最后修改时间 **/
@property (nonatomic, copy) NSString *finalModificationDate;
@end

#pragma mark - YJKeyChain
@interface YJKeyChain : NSObject

/** KeyChain访问策略 在保存数据前设置才会生效**/
+ (void)setSynStrategies:(YJSynStrategies)synStrategies;

/********************** 保存数据 **************************/
/**
 保存方式一
 @param password 密码
 @param account 账号，作为主键
 @param serviceName 目标数据库
 */
+ (BOOL)setPassword:(NSString *)password account:(NSString *)account forService:(NSString *)serviceName;

/**
 保存方式二
 @param data 保存的数据，需要遵循<NSCoding>协议的类
 @param account 账号，作为主键
 @param serviceName 目标数据库
 */
+ (BOOL)setComplexData:(id<NSCoding>)data account:(NSString *)account forService:(NSString *)serviceName;

/**
 保存方式三
 @param data 保存的数据
 @param account 账号，作为主键
 @param serviceName 目标数据库
 */
+ (BOOL)setNormalData:(NSData *)data account:(NSString *)account forService:(NSString *)serviceName;

/********************** 获取数据 **************************/
//获取数据时，确保存储数据的类型与我们returnType设置的数据类型相同
/**
 获取目标数据库中的所有数据
 @param serviceName 目标数据库
 @param returnType 返回类型-> 0:NSString 1:遵循<NSCoding>协议的Class 2:Data
 */
+ (NSArray<YJKeyChainResult *> *)loadAllInfoForService:(NSString *)serviceName resultType:(int)returnType;

/**
 获取目标数据库中某条数据
 @param serviceName 目标数据库
 @param account 账号
 @param returnType 返回类型-> 0:NSString 1:遵循<NSCoding>协议的Class 2:Data
 */
+ (NSArray<YJKeyChainResult *> *)loadInfoForService:(NSString *)serviceName account:(NSString *)account resultType:(int)returnType;

/********************** 删除数据 **************************/
/**
 删除目标数据库中所有数据
 @param serviceName 目标数据库
 */
+ (BOOL)deleteAllInfoForService:(NSString *)serviceName;

/**
 删除目标数据库中的某条数据
 @param serviceName 目标数据库
 @param account 账号
 */
+ (BOOL)deleteInfoForService:(NSString *)serviceName account:(NSString *)account;
@end
