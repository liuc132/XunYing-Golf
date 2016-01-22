//
//  Friend.m
//  QQ好友列表
//
//  Created by TianGe-ios on 14-8-21.
//  Copyright (c) 2014年 TianGe-ios. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "Friend.h"

@implementation Friend

+ (instancetype)friendWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    NSArray *values = [[NSArray alloc] init];
    NSArray *keys = [[NSArray alloc] init];
    //
    values = [dict allValues];
    keys   = [dict allKeys];
    
    if (self = [super init]) {
//        [self setValuesForKeysWithDictionary:dict];
        if ([[dict objectForKey:@"vip"] boolValue]) {
            [dict setValue:[NSNumber numberWithBool:YES] forKeyPath:@"vip"];
        }
        else
        {
            [dict setValue:[NSNumber numberWithBool:NO] forKeyPath:@"vip"];
        }
        [dict setValue:[NSNumber numberWithBool:YES] forKey:@"vip"];
        //
//        for (unsigned char i = 0; i < [values count]; i++) {
//            [self setValue:values[i] forKeyPath:[NSString stringWithFormat:@"%@",keys[i]]];
//        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.vip = YES;
    }
}

@end
