//
//  TTConfiguration.h
//  TTArchitecture
//
//  Created by jyzx101 on 2017/8/28.
//  Copyright © 2017年 elliot. All rights reserved.
//

#ifndef TTConfiguration_h
#define TTConfiguration_h

#pragma mark - UI

#define TT_SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define TT_SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define TT_ROOT_WINDOW [UIApplication sharedApplication].delegate.window

#pragma mark - Log

#ifdef DEBUG

#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define DLog( s, ... )

#endif

#endif /* TTConfiguration_h */
