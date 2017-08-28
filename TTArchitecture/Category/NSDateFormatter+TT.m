//
//  NSDateFormatter+TT.m
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import "NSDateFormatter+TT.h"

@implementation NSDateFormatter (TT)

+ (NSDateFormatter *)ymdhmsDashFormatter {
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return dayFormatter;
}

+ (NSDateFormatter *)chineseYmd {
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"yyyy年MM月dd日"];
    return dayFormatter;
}

+ (NSDateFormatter *)slashDateFormatter {
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"yyyy/MM/dd"];
    return dayFormatter;
}

+ (NSDateFormatter *)YMDPointDateFormatter {
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"yyyy.MM.dd"];
    [dayFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return dayFormatter;
}

+ (NSDateFormatter *)HMSDateFormatter {
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"HH:mm:ss"];
    return dayFormatter;
}

@end
