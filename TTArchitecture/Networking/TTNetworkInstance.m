//
//  TTNetworkInstance.m
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import "TTNetworkInstance.h"

#import "TTConfiguration.h"
#import "MBProgressHUD+TT.h"
#import <AFNetworking.h>
#import <Reachability.h>

typedef NS_ENUM(NSUInteger, TTNetworkStatus) {
    
    TTNetWorkStatusUnknown = 0,         //未知状态
    TTNetWorkStatusNotReachable,        //无网状态
    TTNetWorkStatusReachableViaWWAN,    //手机网络
    TTNetWorkStatusReachableViaWiFi     //Wifi网络
};

static double const kRequestTimeout = 20.0;

@interface TTNetworkInstance ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionMgr;
@property (nonatomic, strong) AFURLSessionManager *urlSessionMgr;

@end

@implementation TTNetworkInstance

+ (instancetype)sharedInstance {
    
    static TTNetworkInstance *networkInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        networkInstance = [[self alloc] init];
        networkInstance.httpSessionMgr = [self AFHttpSessionManager];
        networkInstance.urlSessionMgr = [self AFUrlSessionManager];
    });
    
    return networkInstance;
}

+ (AFHTTPSessionManager *)AFHttpSessionManager {
    
    AFHTTPSessionManager *sessionMgr = [AFHTTPSessionManager manager];
    sessionMgr.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    sessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    sessionMgr.responseSerializer.acceptableContentTypes =
    [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    sessionMgr.requestSerializer.timeoutInterval = kRequestTimeout;
    
    return sessionMgr;
}

+ (AFURLSessionManager *)AFUrlSessionManager {
    
    return [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration
                                                                      defaultSessionConfiguration]];
}

+ (void)cancelAllOperations {
    
    AFHTTPSessionManager *sessionMgr = [AFHTTPSessionManager manager];
    [sessionMgr.operationQueue cancelAllOperations];
}

+ (void)startNetworkStatusMonitor {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [[Reachability reachabilityForInternetConnection] startNotifier];
}

+ (void)networkStatusChanged {
    
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    switch (netStatus) {
            
        case ReachableViaWWAN:{
            
            [MBProgressHUD showMessage:@"当前使用2G//3G//4G...网络" inView:TT_ROOT_WINDOW];
        }
            break;
            
        case ReachableViaWiFi:{
            
            [MBProgressHUD showMessage:@"当前使用WiFi网络" inView:TT_ROOT_WINDOW];
        }
            break;
            
        case NotReachable:{
            
            [MBProgressHUD showMessage:@"当前无网络连接" inView:TT_ROOT_WINDOW];
        }
            break;
            
        default:
            break;
    }
}

+ (BOOL)isNetReachable {
    
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

+ (BOOL)isWWANNetwork {
    
    return [[Reachability reachabilityForInternetConnection] isReachableViaWWAN];
}

+ (BOOL)isWiFiNetwork {
    
    return [[Reachability reachabilityForInternetConnection] isReachableViaWiFi];
}

+ (void)showFailReachNetworkTips {
    
    [MBProgressHUD showMessage:@"网络不给力" inView:TT_ROOT_WINDOW];
}

- (void)GET:(NSString *)url
 Parameters:(NSDictionary *)parameters
    Success:(void (^)(id responseObj))success
    Failure:(void (^)(NSError *error))failure {
    
    NSAssert(url != nil, @"url不能为空");
    
    self.httpSessionMgr.requestSerializer.timeoutInterval = kRequestTimeout;
    [self.httpSessionMgr GET:url
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         
         NSDictionary *result
         = [NSJSONSerialization JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                             error:nil];
         
         if (success) success(result);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         if (failure) failure(error);
     }];
}

- (void)hudGET:(NSString *)url
    Parameters:(NSDictionary *)parameters
       Success:(void(^)(id responseObj))success
       Failure:(void (^)(NSError *error))failure {
    
    NSAssert(url != nil, @"url不能为空");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:TT_ROOT_WINDOW animated:YES];
    hud.removeFromSuperViewOnHide = YES;

    self.httpSessionMgr.requestSerializer.timeoutInterval = kRequestTimeout;
    [self.httpSessionMgr GET:url
                 parameters:parameters
                   progress:nil
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [hud hideAnimated:YES];
         
         NSDictionary *result
         = [NSJSONSerialization JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                             error:nil];
         
         if (success) success(result);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         [hud hideAnimated:YES];
     }];
}

- (void)POST:(NSString *)url
  Parameters:(NSDictionary *)parameters
     Success:(void (^)(id responseObj))success
     Failure:(void (^)(NSError *error))failure {
    
    NSAssert(url != nil, @"url不能为空");
    
    self.httpSessionMgr.requestSerializer.timeoutInterval = kRequestTimeout;
    [self.httpSessionMgr POST:url
                   parameters:parameters
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSDictionary *result
         = [NSJSONSerialization JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                             error:nil];

         if (success) success(result);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         if (failure) failure(error);
     }];
    
}

- (void)hudPOST:(NSString *)url
     Parameters:(NSDictionary *)parameters
        Success:(void(^)(id responseObj))success
        Failure:(void(^)(NSError *error))failure {
    
    NSAssert(url != nil, @"url不能为空");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:TT_ROOT_WINDOW animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    
    self.httpSessionMgr.requestSerializer.timeoutInterval = kRequestTimeout;
    [self.httpSessionMgr POST:url
                   parameters:parameters
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [hud hideAnimated:YES];
         
         NSDictionary *result
         = [NSJSONSerialization JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                             error:nil];

         if (success) success(result);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         [hud hideAnimated:YES];
         if (failure) failure(error);
     }];
}

- (void)postJsonStringUrl:(NSString *)url
                     body:(NSDictionary *)body
                  Success:(void(^)(NSURLResponse *response, id responseObj))success
                  Failure:(void(^)(NSError *error))failure {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:url
                                                                                parameters:nil
                                                                                     error:nil];
    
    request.timeoutInterval = kRequestTimeout;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[self.urlSessionMgr dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            
            if(success) success(response, responseObject);
        } else {
            
            if(failure) failure(error);
        }
    }] resume];
}

- (void)hudPostJsonStringUrl:(NSString *)url
                        body:(NSDictionary *)body
                     Success:(void(^)(NSURLResponse *response, id responseObject))success
                     Failure:(void(^)(NSError *error))failure {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:TT_ROOT_WINDOW animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:url
                                                                                parameters:nil
                                                                                     error:nil];
    
    request.timeoutInterval = kRequestTimeout;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[self.urlSessionMgr dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
        if (!error) {
            
            if(success) success(response, responseObject);
        } else {
            
            if(failure) failure(error);
        }
    }] resume];
}

- (void)hudDownloadFileWithUrl:(NSString *)downloadUrl
                      filePath:(NSString *)filePath
                    completion:(void(^)(NSString *filePath))completion
                       Failure:(void(^)(NSError *error))failure {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:TT_ROOT_WINDOW animated:YES];
    hud.removeFromSuperViewOnHide = YES;

    self.httpSessionMgr.requestSerializer.timeoutInterval = 60.0;
    
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task
    = [self.httpSessionMgr downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        DLog(@"当前下载进度为:%lf",
             1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
        if(error) {
            
            if(failure) failure(error);
        }else {
            
            if (completion) completion(filePath.absoluteString);
        }
    }];
    
    [task resume];
}

- (void)downloadDataFromUrl:(NSString *)downloadUrl
                    Success:(void (^)(id responseObj))success
                    Failure:(void (^)(NSError *error))failure {
    
    NSURL *URL = [NSURL URLWithString:downloadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    self.httpSessionMgr.requestSerializer.timeoutInterval = kRequestTimeout;
    NSURLSessionDataTask *dataTask = [self.httpSessionMgr dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            
            if(failure) failure(error);
        } else {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                   options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                                     error:nil];
            
            if(success) success(result);
        }
    }];
    
    [dataTask resume];
}

@end
