//
//  FinderSyncUtils.m
//  SVNFinderSync
//
//  Created by xujun on 2018/5/2.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "FinderSyncUtils.h"

#define kErrorParamsTips @"参数错误\n"

#define kUserDefaults [NSUserDefaults standardUserDefaults]

NSString * const kNotificationFinderSyncResultKey = @"kNotificationFinderSyncResultKey";
NSString * const kNotificationRefreshMainViewKey = @"kNotificationRefreshMainViewKey";
NSString * const kNotificationNetMoniterConfigChanged = @"kNotificationNetMoniterConfigChanged";

@implementation FinderSyncUtils

//+ (BOOL)validateToolbarMenu
//{
//    BOOL bResult = NO;
//    NSUInteger itemCounts = [FIFinderSyncController defaultController].selectedItemURLs.count;
//    bResult = itemCounts == 1 ? YES : NO;
//
//    return bResult;
//}
//
//+ (BOOL)validateFileMenu
//{
//    BOOL bResult = NO;
//    NSUInteger itemCounts = [FIFinderSyncController defaultController].selectedItemURLs.count;
//    bResult = itemCounts == 1 ? YES : NO;
//
//    return bResult;
//}
//+ (BOOL)validateDirectoryMenu
//{
//    return YES;
//}


#pragma mark path utils
+ (BOOL)path:(NSString *)aPath isSubPathOfPath:(NSString *)anotherPath
{
    BOOL bResult = NO;
    
    bResult = [aPath hasPrefix:anotherPath];
    
    return bResult;
}

+ (BOOL)fileUrlIsInvisible:(NSURL *)fileUrl
{
    BOOL bResult = NO;
    NSNumber * numIsHidden = nil;
    
    [fileUrl getResourceValue:&numIsHidden forKey:NSURLIsHiddenKey error:NULL];
    bResult = numIsHidden.boolValue;
    
    return bResult;
}

///是否是主应用
+ (NSString *)filePathForMonitor:(BOOL)isHost
{
    NSString *basePath = NSTemporaryDirectory();
    if (isHost) {
        basePath = [basePath stringByAppendingPathComponent:@"com.xujun.svn.FinderSync"];//加上扩展的bundle id
    }
    NSString *path = [basePath stringByAppendingPathComponent:@"fileMoniter.plist"];
    return path;
}

#pragma mark - sandbox NSHomeDirectory
+ (NSString *)homeDirectory
{
    NSString *homeDirectory = NSHomeDirectory();
    NSArray *array = [homeDirectory componentsSeparatedByString:@"/"];
    
    if (array.count >= 3) {
        return [NSString stringWithFormat:@"/%@/%@",array[1],array[2]];
    }
    return @"/Users";
}


#pragma mark command utils
+ (void)asyncRunCommand:(NSString *)cmd environment:(NSDictionary *)environment responseBlock:(CommandResponseBlock)responseBlock
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.xujun.svn", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^(){
        [self _asyncRunCommand:cmd environment:environment responseBlock:^(BOOL complete, NSString * _Nullable output, NSError * _Nullable error) {
            if (responseBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    responseBlock(complete,output,error);
                });
            }
        }];
    });
}
///异步执行命令
+ (void)_asyncRunCommand:(nullable NSString *)cmd environment:(nullable NSDictionary *)environment responseBlock:(nonnull CommandResponseBlock)responseBlock
{
    if (cmd.length == 0) {
        responseBlock(YES,kErrorParamsTips,[NSError errorWithErrorInf:kErrorParamsTips]);
        return;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";
    task.arguments = [NSArray arrayWithObjects:@"-c",cmd,nil];
    
    if (environment) {
        task.environment = environment;
    }
    
//    NSPipe *inPipe = [NSPipe pipe];
    NSPipe *outPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
//    task.standardInput = inPipe;
    task.standardOutput = outPipe;
    task.standardError = errorPipe;
    
    NSFileHandle *outFile = [outPipe fileHandleForReading];
    NSFileHandle *errorFile = [errorPipe fileHandleForReading];
    [task launch];//[任务启动];
    
//    //命令从标准输入读取：
//    NSFileHandle * input = [NSFileHandle fileHandleWithStandardInput];
//    //等待标准输入...
//    [input waitForDataInBackgroundAndNotify];
//    // ...并等待shell输出。
    [[outPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
//
//    //异步等待标准输入。
//    //只要标准输入上有一些数据，该块就被执行。
//    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
//                                                      object:input queue:nil
//                                                  usingBlock:^(NSNotification * note)
//     {
//         NSData * inData = [input availableData];
//         if ([inData length] == 0) {
//             //标准输入的EOF。
//             [[inPipe fileHandleForWriting] closeFile];
//         } else {
//             //从标准输入读取并写入shell输入管道。
//             [[inPipe fileHandleForWriting] writeData:inData];
//
//             //继续等待标准输入。
//             [input waitForDataInBackgroundAndNotify];
//
//             NSString *str = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
//             NSLog(@"input---> %@",str);
//         }
//     }];

    //异步等待shell输出。
    //只要shell输出管道上有一些数据可用，块就会被执行。
    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
                                                      object:outFile queue:nil
                                                  usingBlock:^(NSNotification * note)
     {
         // Read from shell输出
         NSData *outData = [outFile availableData];
         if (outData.length == 0) {
             return;
         }
         
         NSString *outStr = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
         ///去掉最后一行的回车
//         outStr = [outStr stringByRemoveNewLineEndChar];
         //返回数据
         responseBlock(NO,outStr, nil);
         //继续等待shell输出。
         [outFile waitForDataInBackgroundAndNotify];
         
         NSLog(@"%@",outStr);
     }];

    [task waitUntilExit];
    
    
//    [[NSNotificationCenter defaultCenter] removeObserver:input];
    [[NSNotificationCenter defaultCenter] removeObserver:outFile];
    if (responseBlock) {
        NSError *error = nil;
        NSData *outData = [errorFile availableData];
        if (outData.length > 0) {
            NSString *output = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
            error = [NSError errorWithCode:-1 errorInf:output];
        }
        responseBlock(YES,nil,error);
    }
}

///同步执行命令
+ (NSError *)syncRunCommand:(NSString *)cmd environment:(NSDictionary *)environment
{
    if (cmd.length == 0) {
        return nil;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";
    task.arguments = [NSArray arrayWithObjects:@"-c",cmd,nil];
    
    if (environment) {
        task.environment = environment;
    }
    
    NSPipe *outPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    task.standardOutput = outPipe;
    task.standardError = errorPipe;
    
    NSFileHandle *outFile = [outPipe fileHandleForReading];
    NSFileHandle *errorFile = [errorPipe fileHandleForReading];
    [task launch];//[任务启动];

    NSInteger code = -1;
    NSData *data = [errorFile readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (output.length == 0) {
        code = 0;
        data = [outFile readDataToEndOfFile];
        output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
//    NSLog(@"code:%ld,output:%@",code,output);
    NSError *error = [NSError errorWithErrorInf:output];
    
    return error;
}

+ (NSError *)runSystemCommand:(NSString *)cmd
{
    return [FinderSyncUtils syncRunCommand:cmd environment:nil];
}

#pragma mark svn utils


+ (void)runSVNCommand:(NSString *)cmd atPaths:(NSArray<NSString *> *)paths responseBlock:(CommandResponseBlock)responseBlock//异步执行
{
    if (cmd.length == 0 || paths.count == 0) {
        if (responseBlock) {
            responseBlock(YES,kErrorParamsTips,[NSError errorWithErrorInf:kErrorParamsTips]);
        }
        return;
    }
    ///其实可以检查下svn命令是不是存在  没必要了 懒得写了
#if 0//app自带的svn
    NSMutableString *command = [NSMutableString stringWithFormat:@"%@/svn.app/cmd/svn %@",[[NSBundle mainBundle] resourcePath],cmd];
#else//系统自带svn
    NSMutableString *command = [NSMutableString stringWithFormat:@"svn %@",cmd];
#endif

    for (NSString *path in paths) {
        [command appendFormat:@" \"%@\"",path];
    }
    
    [FinderSyncUtils asyncRunCommand:command environment:@{@"LC_CTYPE":@"en_US.UTF-8"} responseBlock:responseBlock];
}

+ (NSError *)killProcessName:(NSString *)processName//关闭进程
{
    NSMutableString *command = [NSMutableString stringWithFormat:@"%@/svn.app/cmd/kill_process.sh %@",[[NSBundle mainBundle] resourcePath],processName];
    
    return [FinderSyncUtils syncRunCommand:command environment:nil];
}

#pragma mark - NSAlert
+ (void)showAlertWithText:(NSString *)text
{
    [self showAlertWithText:text target:nil buttonName1:nil buttonAction1:nil buttonName2:nil buttonAction2:nil];
}

+ (void)showAlertWithText:(NSString *)text
                   target:(id)target
              buttonName1:(NSString *)buttonName1
            buttonAction1:(SEL)buttonAction1
              buttonName2:(NSString *)buttonName2
            buttonAction2:(SEL)buttonAction2
{
    NSAlert *alert = [self alertWithText:text
                                  target:target
                             buttonName1:buttonName1
                           buttonAction1:buttonAction1
                             buttonName2:buttonName2
                           buttonAction2:buttonAction2];
    [alert runModal];
}

+ (NSAlert *)alertWithText:(NSString *)text
                    target:(id)target
               buttonName1:(NSString *)buttonName1
             buttonAction1:(SEL)buttonAction1
               buttonName2:(NSString *)buttonName2
             buttonAction2:(SEL)buttonAction2
{
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"温馨提示";
    alert.informativeText = text;
    
    if (buttonName1) {
        NSButton *btn = [alert addButtonWithTitle:buttonName1];
        if (target && buttonAction1) {
            [btn setTarget:target];
            [btn setAction:buttonAction1];
        }
        
    }
    
    if (buttonName2) {
        NSButton *btn = [alert addButtonWithTitle:buttonName2];
        if (target && buttonAction2) {
            [btn setTarget:target];
            [btn setAction:buttonAction2];
        }
    }
    
    if (!buttonName1 && !buttonName2) {
        [alert addButtonWithTitle:@"确定"];
    }
    
    
    
    alert.alertStyle = NSAlertStyleInformational;
    
    return alert;
}


#pragma mark - System login

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (void)addAppToSystemLoginItem
{
    
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    //获取程序的路径
    // 比如, /Applications/test.app
    
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // 创建路径的引用
    
    // 我们只为当前用户添加启动项,所以我们用kLSSharedFileListSessionLoginItems
    
    // 如果要为全部用户添加,则替换为kLSSharedFileListGlobalLoginItems
    
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
    
    
    if (loginItems) {
        
        //将项目插入启动表中.
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     
                                                                     url, NULL, NULL);
        
        if (item){
            CFRelease(item);
        }
        
    }
    
    
    CFRelease(loginItems);
    
}




+ (void)deleteAppFromSytemLoginItem
{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    //获取程序的路径
    
    // 比如, /Applications/test.app
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // 创建引用.
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
        UInt32 seedValue;
        //获取启动项列表并转换为NSArray,这样方便取其中的项
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
        for(int i = 0; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
            //用URL来解析项
            if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                
                NSString * urlPath = [(__bridge NSURL*)url path];
                
                if ([urlPath compare:appPath] == NSOrderedSame){
                    
                    LSSharedFileListItemRemove(loginItems,itemRef);
                    
                }
                
            }
            
        }
    }
    
}

+ (BOOL)isSystemLoginItemForApp
{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    //获取程序的路径
    
    // 比如, /Applications/test.app
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // 创建引用.
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
        UInt32 seedValue;
        //获取启动项列表并转换为NSArray,这样方便取其中的项
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
        for(int i = 0; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
            //用URL来解析项
            if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                
                NSString * urlPath = [(__bridge NSURL*)url path];
                
                if ([urlPath compare:appPath] == NSOrderedSame){
                    
                    return YES;
                    
                }
                
            }
            
        }
    }
    
    return NO;
}
#pragma clang diagnostic pop

#pragma mark - data save
+ (void)setFirstLaunchForCurretnVersion
{
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if (![kUserDefaults objectForKey:key]) {
        [kUserDefaults setBool:NO forKey:key];
        [kUserDefaults synchronize];
    }
}

+ (BOOL)isFirstLaunchForCurretnVersion
{
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSNumber *value = [kUserDefaults objectForKey:key];
    if (value) {
        return value.boolValue;
    }
    return YES;
}

+ (void)setNetMoniter:(BOOL)open
{
    [kUserDefaults setBool:open forKey:@"kNetMoniterOpen"];
    [kUserDefaults synchronize];
}

+ (BOOL)isNetMoniterOpenned
{
    NSNumber *value = [kUserDefaults objectForKey:@"kNetMoniterOpen"];
    return value.boolValue;
}

+ (void)setAutoBulidIOSTaskPath:(NSString *)path
{
    [kUserDefaults setObject:path forKey:@"kAutoBulidIOSTaskPath"];
    [kUserDefaults synchronize];
}

+ (NSString *)autoBulidIOSTaskPath
{
    NSString *path = [kUserDefaults objectForKey:@"kAutoBulidIOSTaskPath"];
    return path;
}


#pragma mark - method
+ (void)pressSystemSettingAction
{
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Extensions.prefPane"];
    //    [[NSWorkspace sharedWorkspace] openFile:NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).firstObject];
    
//    NSURL *url = [NSURL fileURLWithPath:NSTemporaryDirectory()];
//    [[NSWorkspace sharedWorkspace] openURL:url];
}



+ (void)pressRestartFinderAction
{
    //    NSString *str = [FinderSyncUtils runSVNCommand:@"up" atPaths:@[@"/Users/martin.ren/Documents/Project/iOS/高保真全集/切图/A01 登录"]];
    [FinderSyncUtils runSystemCommand:@"killall Finder"];
}
@end

@implementation NSString (FinderSyncUtils)

- (NSString *)stringByRemoveNewLineEndChar
{
    NSString *text = self;
    for (NSUInteger index = 0; index < text.length; ++index) {
        NSString *subText = [text substringFromIndex:text.length - 1];
        
        if ([subText isEqualToString:@"\r"] || [subText isEqualToString:@"\n"]) {
            text = [text stringByReplacingCharactersInRange:NSMakeRange(text.length-1, 1) withString:@""];
        }
        else {
            break;
        }
    }
    return text;
}

@end

@implementation NSMutableAttributedString (FinderSyncUtils)

- (void)appendString:(NSString *)str
{
    [self appendString:str color:nil font:nil];
}

///追加文字
- (void)appendString:(NSString *)str color:(NSColor *)color font:(NSFont *)font
{
    
    NSMutableAttributedString *tmpStr = [NSMutableAttributedString attributedStringWithString:str color:color font:font];
    
    if (tmpStr) {
        [self appendAttributedString:tmpStr];
    }
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                    color:(NSColor *)color
                                                     font:(NSFont *)font
{
    return [self attributedStringWithString:string color:color font:font range:NSMakeRange(0, string.length)];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string color:(NSColor *)color font:(NSFont *)font range:(NSRange)range{
    if (string.length == 0) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    if (color) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    
    if (font) {
        [attributedString addAttribute:NSFontAttributeName value:font range:range];
    }
    
    return attributedString;
}


@end

@implementation NSArray (FinderSyncUtils)



///NSURL转NSString (NSURL-->NSString)
- (NSArray<NSString *> *)pathsForURLs
{
    NSMutableArray *paths = [NSMutableArray new];
    
    [self enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSURL class]]) {
            [paths addObject:obj.path];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            [paths addObject:obj];
        }
    }];
    
    return paths;
}

@end

@implementation NSDictionary (FinderSyncUtils)

@end


@implementation NSError (FinderSyncUtils)
+ (id)errorWithErrorInf:(NSString *)errorInf
{
    return [NSError errorWithCode:-1 errorInf:errorInf];
}

+ (id)errorWithCode:(NSInteger)code errorInf:(NSString *)errorInf
{
    errorInf = errorInf ? : @"";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorInf};
    return [NSError errorWithDomain:errorInf code:code userInfo:userInfo];
}
@end
