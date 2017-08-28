//
//  NSDateFormatter+TT.h
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (TT)

/**
 yyyy-MM-dd HH:mm:ss
 */
+ (NSDateFormatter *)ymdhmsDashFormatter;

/**
 yyyy年MM月dd日
 */
+ (NSDateFormatter *)chineseYmd;

/**
 yyyy/MM/dd
 */
+ (NSDateFormatter *)slashDateFormatter;

/**
 yyyy.MM.dd
 */
+ (NSDateFormatter *)YMDPointDateFormatter;

/**
 HH:mm:ss
 */
+ (NSDateFormatter *)HMSDateFormatter;

@end
