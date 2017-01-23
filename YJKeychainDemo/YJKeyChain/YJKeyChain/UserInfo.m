//
//  UserInfo.m
//  YJKeyChain
//
//  Created by yankezhi on 2017/1/19.
//  Copyright © 2017年 caohua. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.adress = [aDecoder decodeObjectForKey:@"adress"];
        self.age = [aDecoder decodeObjectForKey:@"age"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.adress forKey:@"adress"];
    [aCoder encodeObject:self.age forKey:@"age"];
}
@end
