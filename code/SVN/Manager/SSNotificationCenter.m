//
//  SSNotificationCenter.m
//  ScreenSaverApp
//
//  Created by xujun on 2016/12/21.
//  Copyright © 2016年 xujun. All rights reserved.
//

#import "SSNotificationCenter.h"

NSString *const kNotificationWillScreenshot = @"kNotificationWillScreenshot";
NSString *const kNotificationDidScreenshot = @"kNotificationDidScreenshot";

NSString *const kNotificationDoActionQQScreenshot = @"kNotificationDoActionQQScreenshot";

NSString *const kNotificationNeedUpdateLockWindowImage = @"kNotificationNeedUpdateLockWindowImage";

@implementation SSNotificationCenter

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:nil];
}

+ (void)postNotificationWithName:(NSNotificationName)aName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:nil];
}

@end
