//
//  SSNotificationCenter.h
//  ScreenSaverApp
//
//  Created by xujun on 2016/12/21.
//  Copyright © 2016年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
///全屏截图(will)
extern NSString *const kNotificationWillScreenshot;
///全屏截图(did)
extern NSString *const kNotificationDidScreenshot;
///需要更新锁屏图片
extern NSString *const kNotificationNeedUpdateLockWindowImage;
///开启QQ截图
extern NSString *const kNotificationDoActionQQScreenshot;

@interface SSNotificationCenter : NSNotificationCenter

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName;

+ (void)postNotificationWithName:(NSNotificationName)aName;


@end
