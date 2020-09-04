//
//  FinderSyncUtils.h
//  SVNFinderSync
//
//  Created by xujun on 2018/5/2.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FinderSync/FinderSync.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNotificationFinderSyncResultKey;
extern NSString * const kNotificationRefreshMainViewKey;
extern NSString * const kNotificationNetMoniterConfigChanged;


typedef void(^CommandResponseBlock)(BOOL complete, NSString *_Nullable output, NSError *_Nullable error);

#define kFinderSyncBundleID @"group.com.xujun.svn.data"

@interface FinderSyncUtils : NSObject

#pragma mark path utils
+ (BOOL)path:(NSString *)aPath isSubPathOfPath:(NSString *)anotherPath;
+ (BOOL)fileUrlIsInvisible:(NSURL *)fileUrl;

///监听的路径 是否是主应用
+ (NSString *)filePathForMonitor:(BOOL)isHost;

#pragma mark - sandbox NSHomeDirectory
+ (NSString *)homeDirectory;

#pragma mark command utils
///如@"cd Desktop; mkdir helloWorld" (error.code == 0为正常运行)
+ (NSError *)runSystemCommand:(NSString *)cmd;//同步执行
+ (void)runSVNCommand:(NSString *)cmd atPaths:(NSArray<NSString *> *)paths responseBlock:(CommandResponseBlock)responseBlock;//异步执行
+ (NSError *)killProcessName:(NSString *)processName;//关闭进程

#pragma mark - NSAlert
+ (void)showAlertWithText:(nullable NSString *)text;
+ (void)showAlertWithText:(nullable NSString *)text
                   target:(nullable id)target
              buttonName1:(nullable NSString *)buttonName1
            buttonAction1:(nullable SEL)buttonAction1
              buttonName2:(nullable NSString *)buttonName2
            buttonAction2:(nullable SEL)buttonAction2;
+ (NSAlert *)alertWithText:(nullable NSString *)text
                    target:(nullable id)target
               buttonName1:(nullable NSString *)buttonName1
             buttonAction1:(nullable SEL)buttonAction1
               buttonName2:(nullable NSString *)buttonName2
             buttonAction2:(nullable SEL)buttonAction2;

#pragma mark - System login
///登录项目
+ (void)addAppToSystemLoginItem;
+ (void)deleteAppFromSytemLoginItem;
+ (BOOL)isSystemLoginItemForApp;

#pragma mark - data save
+ (void)setFirstLaunchForCurretnVersion;
+ (BOOL)isFirstLaunchForCurretnVersion;

#pragma mark - data netMinitor
+ (void)setNetMoniter:(BOOL)open;
+ (BOOL)isNetMoniterOpenned;

#pragma mark - data ios打包定时任务
+ (void)setAutoBulidIOSTaskPath:(NSString *)path;
+ (NSString *)autoBulidIOSTaskPath;


#pragma mark - method
+ (void)pressSystemSettingAction;
+ (void)pressRestartFinderAction;
@end


@interface NSString (FinderSyncUtils)
- (NSString *)stringByRemoveNewLineEndChar;
@end

@interface NSMutableAttributedString (FinderSyncUtils)

///追加文字
- (void)appendString:(nullable NSString *)str;
- (void)appendString:(nullable NSString *)str color:(nullable NSColor *)color font:(nullable NSFont *)font;
+ (NSMutableAttributedString *)attributedStringWithString:(nullable NSString *)string
                                                    color:(nullable NSColor *)color
                                                     font:(nullable NSFont *)font;
@end

@interface NSArray (FinderSyncUtils)

///NSURL转NSString (NSURL-->NSString)
- (NSArray<NSString *> *)pathsForURLs;

@end


@interface NSDictionary (FinderSyncUtils)

@end

@interface NSError (FinderSyncUtils)

//domain &&  Description
+ (NSError *)errorWithErrorInf:(NSString *)errorInf;
//domain &&  Description
+ (NSError *)errorWithCode:(NSInteger)code errorInf:(NSString *)errorInf;
@end


NS_ASSUME_NONNULL_END
