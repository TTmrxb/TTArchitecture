//
//  TTNetworkInstance.h
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTNetworkInstance : NSObject

+ (instancetype)sharedInstance;

/**
 禁止使用init初始化
 */
- (instancetype)init __attribute__((unavailable("请使用sharedInstance初始化网络工具单例")));

/**取消所有网络请求*/
+ (void)cancelAllOperations;

/**
 *   监听网络状态的变化
 */
+ (void)startNetworkStatusMonitor;

/**
 在主线程实时获取是否有网络
 */
+ (BOOL)isNetReachable;

+ (BOOL)isWWANNetwork;

+ (BOOL)isWiFiNetwork;

/**
 GET请求

 @param url 请求接口
 @param parameters 请求参数
 @param success 请求成功block
 @param failure 请求失败block
 */
- (void)GET:(NSString *)url
 Parameters:(NSDictionary *)parameters
    Success:(void (^)(id responseObj))success
    Failure:(void (^)(NSError *error))failure;

/**
 *  GET请求,添加laoding hud
 */
- (void)hudGET:(NSString *)url
    Parameters:(NSDictionary *)parameters
       Success:(void(^)(id responseObj))success
       Failure:(void (^)(NSError *error))failure;


/**
 POST 请求

 @param url 请求接口
 @param parameters 请求参数
 @param success 请求成功block
 @param failure 请求失败block
 */
- (void)POST:(NSString *)url
  Parameters:(NSDictionary *)parameters
     Success:(void (^)(id responseObj))success
     Failure:(void (^)(NSError *error))failure;

/**
 *  POST请求，添加laoding hud
 */
- (void)hudPOST:(NSString *)url
     Parameters:(NSDictionary *)parameters
        Success:(void(^)(id responseObj))success
        Failure:(void(^)(NSError *error))failure;


/**
 POST JSON字符串请求

 @param url 请求接口
 @param body 请求json
 @param success 请求成功block
 @param failure 请求失败block
 */
- (void)postJsonStringUrl:(NSString *)url
                     body:(NSDictionary *)body
                  Success:(void(^)(NSURLResponse *response, id responseObj))success
                  Failure:(void(^)(NSError *error))failure;

/**
 *  POST JSON字符串请求,添加laoding hud
 */
- (void)hudPostJsonStringUrl:(NSString *)url
                        body:(NSDictionary *)body
                     Success:(void(^)(NSURLResponse *response, id responseObject))success
                     Failure:(void(^)(NSError *error))failure;


/**
 下载文件

 @param downloadUrl 下载地址
 @param filePath 下载成功后文件存储路径
 @param completion 下载完成block
 @param failure 下载失败blcok
 */
- (void)hudDownloadFileWithUrl:(NSString *)downloadUrl
                      filePath:(NSString *)filePath
                    completion:(void(^)(NSString *filePath))completion
                       Failure:(void(^)(NSError *error))failure;

/**
 下载JSON数据

 @param downloadUrl 下载地址
 @param success 下载成功block
 @param failure 下载失败blcok
 */
- (void)downloadDataFromUrl:(NSString *)downloadUrl
                    Success:(void (^)(id responseObj))success
                    Failure:(void (^)(NSError *error))failure;

@end
