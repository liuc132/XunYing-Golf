//
//  HttpTools.m
//  Common
//
//  Created by 周杨 on 14/12/21.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import "HttpTools.h"
#import "AFHTTPRequestOperationManager.h"

@implementation HttpTools

/**
 *  Description 得到HTTP协议返回 NSData对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSData对象
 */
+(NSData *) getNSDataHttp:(NSString *) url forParams:(NSMutableDictionary *) params{
    NSError *error = nil;
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    //快速枚举遍历所有KEY的值  构造参数字符串
    NSEnumerator * enumeratorKey =[params keyEnumerator];
    NSMutableArray * paramArr = [[NSMutableArray alloc] init];
    
    for (NSString * key in enumeratorKey) {
        [paramArr addObject:[key stringByAppendingFormat:@"=%@",params[key]]];
    }
    
    //参数为utf8
    NSData *bodyData = [[[paramArr componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:bodyData];
    
    //发送同步请求 并返回结果
    NSData * returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error != nil) {
        NSLog(@"%@",error);
    }
    
    return returnData;
}

/**
 *  Description 得到HTTP协议返回 NSData对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSData对象
 */
+(NSString *) getStringHttp:(NSString *) url forParams:(NSMutableDictionary *) params{
    NSError *error = nil;
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    //快速枚举遍历所有KEY的值  构造参数字符串
    NSEnumerator * enumeratorKey =[params keyEnumerator];
    NSMutableArray * paramArr = [[NSMutableArray alloc] init];
    
    for (NSString * key in enumeratorKey) {
        [paramArr addObject:[key stringByAppendingFormat:@"=%@",params[key]]];
    }
    
    //参数为utf8
    NSData *bodyData = [[[paramArr componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:bodyData];
    
    //发送同步请求 并返回结果
    NSData * returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error != nil) {
        NSLog(@"%@",error);
    }
    
    return [[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
}

/**
 *  Description 得到HTTP协议返回 Json对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSDictionary对象
 */
+(NSDictionary *) getJsonHttp:(NSString *) url forParams:(NSMutableDictionary *) params{
    NSError *error = nil;
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    //快速枚举遍历所有KEY的值  构造参数字符串
    NSEnumerator * enumeratorKey =[params keyEnumerator];
    NSMutableArray * paramArr = [[NSMutableArray alloc] init];
    
    for (NSString * key in enumeratorKey) {
        [paramArr addObject:[key stringByAppendingFormat:@"=%@",params[key]]];
    }
    
    //参数为utf8
    NSData *bodyData = [[[paramArr componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:bodyData];
    
    //发送同步请求 并返回结果
    NSData * returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    NSDictionary *reDic =[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        return nil;
    }
    
    
    return reDic;
}

/**
 *  Description 得到HTTP协议返回 Plist对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSDictionary对象
 */
+(NSDictionary *) getPlistHttp:(NSString *) url forParams:(NSMutableDictionary *) params{
    NSError *error = nil;
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    //快速枚举遍历所有KEY的值  构造参数字符串
    NSEnumerator * enumeratorKey =[params keyEnumerator];
    NSMutableArray * paramArr = [[NSMutableArray alloc] init];
    
    for (NSString * key in enumeratorKey) {
        [paramArr addObject:[key stringByAppendingFormat:@"=%@",params[key]]];
    }
    
    //参数为utf8
    NSData *bodyData = [[[paramArr componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:bodyData];
    
    //发送同步请求 并返回结果
    NSData * returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    NSDictionary *dic =[NSPropertyListSerialization propertyListWithData:returnData options:NSPropertyListXMLFormat_v1_0 format:nil error:&error];
    
    if (error != nil) {
        NSLog(@"%@",error);
        return nil;
    }
    
    return dic;
}

/**
 *  <#Description#> 得到HTTP协议返回 NSData对象 (异步方法)
 *
 *  @param url     http地址
 *  @param params  参数键值,可以为nil
 *  @param success 成功事件回调
 *  @param failure 失败事件回调
 *
 */
+(void ) getHttp:(NSString *) url forParams:(NSMutableDictionary *) params success:(void (^)(NSData * nsData)) success failure:(void (^)(NSError * err)) failure{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//设置相应内容类型
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    request.timeoutInterval = 120;
    //快速枚举遍历所有KEY的值  构造参数字符串
    NSEnumerator * enumeratorKey =[params keyEnumerator];
    NSMutableArray * paramArr = [[NSMutableArray alloc] init];
    //
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    
    for (NSString * key in enumeratorKey) {
        [paramArr addObject:[key stringByAppendingFormat:@"=%@",params[key]]];
//        NSDictionary *eachDic = [[NSDictionary alloc] initWithObjectsAndKeys:[key stringByAppendingFormat:@"=%@",params[key]],key, nil];
        //
        [paramDic setObject:[key stringByAppendingFormat:@"=%@",params[key]] forKey:key];
        
//        paramDic = [paramDic dictionaryWithValuesForKeys:eachDic];
        
//        paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:params[key],key, nil];
    }
    
    //参数为utf8
//    NSData *bodyData = [[[paramArr componentsJoinedByString:@"&"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:bodyData];
    
//    NSLog(@"re:%@", [bodyData ]); HTTPRequestOperationWithRequest
    
    
//    [requestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject){
//            NSLog(@"JSON: %@", responseObject);
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//        
//            NSLog(@"recDic:%@",recDic);
//                
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//        
//        
//            }];
    
    [requestManager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
//        NSLog(@"responseObject:%@",responseObject);
        if (success) {
            //使用GCD  在主线程运行
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"err:%@",error);
        failure(error);
    }];
    
    //发送同步请求 并返回结果
    //创建线程队列
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
//    [requestManager GET:downFieldURLStr parameters:self.checkCreatGroupState success:^(AFHTTPRequestOperation *operation, id responseObject){
//        NSLog(@"JSON: %@", responseObject);
//        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//        
//        NSLog(@"recDic:%@",recDic);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        
//        
//    }];
    
    
//    NSLog(@"123");
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response,NSData * data,NSError * err){
//            if (err&&failure) {
//                failure(err);
//            }
//            else {
//                if (success) {
//                    //使用GCD  在主线程运行
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        success(data);
//                    });
//                }
//            }
//            //
//            if (error != nil) {
//                NSLog(@"%@",error);
//            }
//        }];
//    });
    
    
}

@end
