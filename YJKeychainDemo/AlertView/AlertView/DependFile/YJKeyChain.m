//
//  YJKeyChain.m
//  YJKeyChain
//
//  Created by yankezhi on 2017/1/14.
//  Copyright © 2017年 caohua. All rights reserved.
//

#import "YJKeyChain.h"

static YJSynStrategies synStrategiesType = YJSynStrategiesWhenUnlocked;
#pragma mark - YJKeyChainResult
@implementation YJKeyChainResult
@end

#pragma mark - YJKeyChainService
@interface YJKeyChainService : NSObject

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, strong) NSData *saveData;
@property (nonatomic, strong) id<NSCoding> codingData;
@property (nonatomic, assign) YJSynStrategies synStrategies;
@end

@implementation YJKeyChainService

#pragma mark - 保存操作
- (BOOL)normalSaveFunc {
    
    synStrategiesType = YJSynStrategiesWhenUnlocked;
    if (!self.serviceName || !self.account || !self.saveData) {
        NSLog(@"参数不能为nil");
        return NO;
    }
    return [self saveOperation];
}

- (BOOL)codingSaveFunc {
    
    synStrategiesType = YJSynStrategiesWhenUnlocked;
    if (![(id)self.codingData conformsToProtocol:@protocol(NSCoding)]) {
        NSLog(@"当前保存数据不符合<NSCoding>协议");
        return NO;
    }
    if (!self.serviceName || !self.account || !self.codingData) {
        NSLog(@"参数不能为nil");
        return NO;
    }
    self.saveData = [NSKeyedArchiver archivedDataWithRootObject:self.codingData];
    return [self saveOperation];
}

- (BOOL)saveOperation {
    
    NSMutableDictionary *updateQuery = nil;
    NSMutableDictionary *searchQuery = [self keyChainItemQuery];
    //查看是否存储过
    OSStatus status =  SecItemCopyMatching((__bridge CFDictionaryRef) searchQuery, nil);
    if (status == errSecSuccess) { //存储过，更新
        //设置需要更新的内容
        updateQuery = [NSMutableDictionary dictionary];
        [updateQuery setObject:self.saveData forKey:(__bridge id)kSecValueData];
#if TARGET_OS_IPHONE
            //设置访问策略
        [updateQuery setObject:(__bridge id)[self synStr] forKey:(__bridge id)kSecAttrAccessible];
#endif
        //更新
        status = SecItemUpdate((__bridge CFDictionaryRef)searchQuery, (__bridge CFDictionaryRef)updateQuery);
    }else if (status == errSecItemNotFound) { //为存储过，添加
        updateQuery = [self keyChainItemQuery];
        [updateQuery setObject:self.saveData forKey:(__bridge id)kSecValueData];
        status = SecItemAdd((__bridge CFDictionaryRef)updateQuery, NULL);
        
    }
    return status == errSecSuccess;
}

#pragma mark - 抓取数据
/** saveType -> 0:保存字符串形式的数据 1:保存遵循<NSCoding>协议的Data 2:保存普通的Data **/
- (nullable NSArray *)fetchAllInfo:(int)saveType {
 
    NSArray *importantArr = [self fetchImportantData];
    NSArray *otherArr = [self fetchAttachedInformation];
    NSMutableArray *finalResult = [NSMutableArray arrayWithCapacity:importantArr.count];
    
    if (importantArr.count == 0|| otherArr.count == 0) {
        NSLog(@"无数据");
        return nil;
    }
    if (importantArr.count != otherArr.count) {
        NSLog(@"主要信息与附属信息数量不对等");
        return nil;
    }
    for (int i = 0; i < importantArr.count; i++) {
        
        NSDictionary *dict = otherArr[i];
        
        YJKeyChainResult *resultModel = [[YJKeyChainResult alloc] init];
        resultModel.account = [dict objectForKey:@"acct"];
        resultModel.serviceName = [dict objectForKey:@"svce"];
        resultModel.creatDate = [dict objectForKey:@"cdat"];
        resultModel.finalModificationDate = [dict objectForKey:@"mdat"];
        
        if (saveType == 0) {
            NSString *passwordData = [[NSString alloc] initWithData:importantArr[i] encoding:NSUTF8StringEncoding];
            resultModel.password = passwordData;
        }else if (saveType == 1) {
            resultModel.codingData = [NSKeyedUnarchiver unarchiveObjectWithData:importantArr[i]];
        }else {
            resultModel.data = importantArr[i];
        }
        
        [finalResult addObject:resultModel];
    }
    return [finalResult copy];
}

- (NSArray *)fetchImportantData {
    
    NSMutableDictionary *fetchQuery = [self keyChainItemQuery];
    //规定返回的数据类型
    [fetchQuery setObject:@YES forKey:(id)kSecReturnData];
    //限制返回结果的数量
    [fetchQuery setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge_retained CFDictionaryRef)fetchQuery, (CFTypeRef *)&result);
    if (status != errSecSuccess) {
        NSLog(@"获取数据失败");
        return nil;
    }
    return (__bridge_transfer NSArray *)result;
}

- (NSArray *)fetchAttachedInformation {
    
    NSMutableDictionary *fetchQuery = [self keyChainItemQuery];
    //规定返回的数据类型
    [fetchQuery setObject:@YES forKey:(id)kSecReturnAttributes];
    //限制返回结果的数量
    [fetchQuery setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge_retained CFDictionaryRef)fetchQuery, (CFTypeRef *)&result);
    if (status != errSecSuccess) {
        NSLog(@"获取数据失败");
        return nil;
    }
    return (__bridge_transfer NSArray *)result;
}

#pragma mark - 删除操作

- (BOOL)deleteAllInfo {
    
    if (!self.serviceName) {
        NSLog(@"参数不能为nil");
        return NO;
    }
    return [self deleteInfo];
}

- (BOOL)deleteSpecialInfo {
    
    if (!self.serviceName || !self.account) {
        NSLog(@"参数不能为nil");
        return NO;
    }
    return [self deleteInfo];
}

- (BOOL)deleteInfo {
    
    NSMutableDictionary *dict = [self keyChainItemQuery];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) dict);
    
    return (status == errSecSuccess);
}

#pragma mark - NSDictionaty
- (NSMutableDictionary *)keyChainItemQuery {
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    //存储一般密码类型的数据库
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    //设置数据存储的表
    if (self.serviceName) {
        [query setObject:self.serviceName forKey:(__bridge id)kSecAttrService];
    }
    //设置数据值对应的主键
    if (self.account) {
        [query setObject:self.account forKey:(__bridge id)kSecAttrAccount];
    }
#if TARGET_OS_IPHONE
        //设置访问策略
    [query setObject:(__bridge id)[self synStr] forKey:(__bridge id)kSecAttrAccessible];
#endif
    return query;
}

- (void)setPassword:(NSString *)password {
    _password = password;
    self.saveData = [password dataUsingEncoding:NSUTF8StringEncoding];
}

- (CFStringRef)synStr {
    
    switch (self.synStrategies) {
        case YJSynStrategiesAlwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly;
            break;
        case YJSynStrategiesAlways:
            return kSecAttrAccessibleAlways;
            break;
        case YJSynStrategiesWhenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
            break;
        case YJSynStrategiesAfterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            break;
        case YJSynStrategiesWhenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
            break;
        case YJSynStrategiesAfterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock;
            break;
        default:
            return kSecAttrAccessibleWhenUnlocked;
            break;
    }
}


@end

#pragma mark - YJKeyChain
@interface YJKeyChain ()

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *serviceName;
@end

@implementation YJKeyChain

#pragma mark - 保存数据
+ (BOOL)setPassword:(NSString *)password account:(NSString *)account forService:(NSString *)serviceName {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.password = password;
    service.account = account;
    service.serviceName = serviceName;
    service.synStrategies = synStrategiesType;
    return [service normalSaveFunc];
}

+ (BOOL)setComplexData:(id<NSCoding>)data account:(NSString *)account forService:(NSString *)serviceName {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.codingData = data;
    service.account = account;
    service.serviceName = serviceName;
    service.synStrategies = synStrategiesType;
    return [service codingSaveFunc];
}

+ (BOOL)setNormalData:(NSData *)data account:(NSString *)account forService:(NSString *)serviceName {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.saveData = data;
    service.account = account;
    service.serviceName = serviceName;
    service.synStrategies = synStrategiesType;
    return [service normalSaveFunc];
}

#pragma mark - 获取数据
+ (NSArray<YJKeyChainResult *> *)loadAllInfoForService:(NSString *)serviceName resultType:(int)returnType {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.serviceName = serviceName;
    return [service fetchAllInfo:returnType];
}

+ (NSArray<YJKeyChainResult *> *)loadInfoForService:(NSString *)serviceName account:(NSString *)account resultType:(int)returnType {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.serviceName = serviceName;
    service.account = account;
    return [service fetchAllInfo:returnType];
}

#pragma mark - 删除数据
+ (BOOL)deleteAllInfoForService:(NSString *)serviceName {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.serviceName = serviceName;
    return [service deleteAllInfo];
}

+ (BOOL)deleteInfoForService:(NSString *)serviceName account:(NSString *)account {
    
    YJKeyChainService *service = [[YJKeyChainService alloc] init];
    service.serviceName = serviceName;
    service.account = account;
    return [service deleteSpecialInfo];
}

+ (void)setSynStrategies:(YJSynStrategies)synStrategies {
    
    synStrategiesType = synStrategies;
}
@end


