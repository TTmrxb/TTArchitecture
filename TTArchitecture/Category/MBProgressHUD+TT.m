//
//  MBProgressHUD+TT.m
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import "MBProgressHUD+TT.h"

static CGFloat kSleepTime = 3.0;

@implementation MBProgressHUD (TT)

+ (void)showMessage:(NSString *)message inView:(UIView *)view {
    
    [self showMessage:message inView:view duration:kSleepTime];
}

+ (void)showMessage:(NSString *)message inView:(UIView *)view duration:(CGFloat)duration {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.label.numberOfLines = 0;
    
    [hud hideAnimated:YES afterDelay:duration];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view completionBlock:(void(^)())completion {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.label.numberOfLines = 0;
    
    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, kSleepTime * NSEC_PER_SEC);
    dispatch_after(timer, dispatch_get_main_queue(), ^{
        
        [hud hideAnimated:YES];
        
        if (completion) completion();
    });
}

@end
