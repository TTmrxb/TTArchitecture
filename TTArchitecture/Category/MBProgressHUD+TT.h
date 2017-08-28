//
//  MBProgressHUD+TT.h
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (TT)

+ (void)showMessage:(NSString *)message inView:(UIView *)view;

+ (void)showMessage:(NSString *)message inView:(UIView *)view duration:(CGFloat)duration;

/**
 hud 3秒后消失，执行动作
 */
+ (void)showMessage:(NSString *)message toView:(UIView *)view completionBlock:(void(^)())completion;

@end
