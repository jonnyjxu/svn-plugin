//
//  AppDelegate.m
//  SVN
//
//  Created by xujun on 2018/5/2.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "FinderSyncUtils.h"
#import "FinderMenuModel.h"
#import "SSPopManager.h"
#import "MainWindowController.h"
#import "ResultWindowController.h"
#import "AFNetworking.h"
#import "NSDate+CategoryKit.h"

static NSUInteger gNetworkRestartCount = 0;

///监听
void eventStreamCallback(ConstFSEventStreamRef streamRef,
                         void *clientCallBackInfo,
                         size_t numEvents,
                         void *eventPaths,
                         const FSEventStreamEventFlags eventFlags[],
                         const FSEventStreamEventId eventIds[])

{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFinderSyncResultKey object:nil userInfo:nil];
}

@interface AppDelegate () {
    NSStatusItem *_statusItem;
    ResultWindowController *_resultWC;
    MainWindowController *_mainWindowController;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self checkValidApp];
    
#if 1
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFinderSyncResult:) name:kNotificationFinderSyncResultKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartWifi) name:kNotificationNetMoniterConfigChanged object:nil];

    [self setupStatusBarItem];
    [self setupFileMoniter];
    [self setupAppOtherSetting];
    [self startNetMoniter];
    [self startClock];
#else
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFinderSyncResult:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFinderSyncResult:) name:kNotificationFinderSyncResultKey object:nil];
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kFinderSyncBundleID];
    
    NSString *str = [userDefault objectForKey:@"test"];
    NSLog(@"%@",str);
    
    NSString *str1 = [userDefault objectForKey:@"test1"];
    NSLog(@"%@",str1);
    
    NSArray *array = [NSArray readFinderSyncSelectedPaths];
    NSLog(@"%@",array.description);
    
    //    NSObject *object = [userDefault objectForKey:@"test3"];
    //    NSLog(@"%@",object.description);
    //    [[FinderMenuDataSource defaultDataSource] menuForMenuKind:FIMenuKindToolbarItemMenu];
#endif
}


- (void)startNetMoniter
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self restartWifi];
    }];
    [mgr startMonitoring];
}


- (void)restartWifi
{
    if (![FinderSyncUtils isNetMoniterOpenned]) {
        return;
    }
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
        [FinderSyncUtils runSystemCommand:@"networksetup -setairportpower en0 off"];//关闭wifi
        [FinderSyncUtils runSystemCommand:@"networksetup -setairportpower en0 on"];//开启wifi
        //10分钟 检测一次, 直至成功
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10*60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self restartWifi];
        });
        
        if (gNetworkRestartCount > 10) {
            [FinderSyncUtils killProcessName:@"Droid4X"];//关闭Droid4X
        }
        gNetworkRestartCount++;
        
    }
    else {
        //TeamViewer  断网后,不会自动连接
        [self restartTeamViewer];

        gNetworkRestartCount = 0;
    }
}

- (void)restartTeamViewer
{
    //进程个数
    NSError *error = [FinderSyncUtils runSystemCommand:@"ps -ef | grep -c TeamViewer"];
    if (error.domain.intValue <= 3) {
        return;
    }
    
    [FinderSyncUtils killProcessName:@"TeamViewer"];//关闭TeamViewer
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [FinderSyncUtils runSystemCommand:@"open /Applications/TeamViewer.app"];//启动TeamViewer
    });
}

//23点闹钟
- (void)startClock
{
    NSInteger hour = 23;
    NSDate *date = [NSDate date];
    NSDate *newDate = (date.hour >= hour ? [date dateByAddingDays:1] : date);
    newDate = [NSString stringWithFormat:@"%@ %02ld:00",newDate.dateString_yyyyMMdd,hour].toDate;
    
    NSTimeInterval seconds = newDate.timeIntervalSince1970 - date.timeIntervalSince1970;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        NSInteger weekDay = newDate.weekday;
        if (weekDay > 1 && weekDay < 7) {//周六周日 不执行
            NSString *path = [FinderSyncUtils autoBulidIOSTaskPath];
            
            if (path.length > 0) {
                
                path = [path stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];//先简单处理下吧
                path = [path stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
                path = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
                
                NSString *cmd = [NSString stringWithFormat:@"open %@",path];
                NSError *error = [FinderSyncUtils runSystemCommand:cmd];//启动脚本
                NSLog(@"%@",error.domain);
                
            }
        }

         //30分钟后再执行吧,  dispatch时间不一定会准,  误差值修正
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30*60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self restartTeamViewer];
            [self startClock];
        });
    });
}

//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
//{
//    return YES;
//}

- (void)checkValidApp
{
    if (![[[NSBundle mainBundle] executablePath] hasPrefix:@"/Applications"]) {
        return;
    }
    
    NSAlert *alert = [FinderSyncUtils alertWithText:@"别把App放在\"应用程序/Applications\"目录\n(很穷 没签名, 所以Apple不让在里面正常运行)" target:self buttonName1:@"退出" buttonAction1:@selector(actionExit) buttonName2:nil buttonAction2:nil];
    
    [alert runModal];
}

- (void)setupAppOtherSetting
{
    if ([FinderSyncUtils isFirstLaunchForCurretnVersion]) {
        [FinderSyncUtils addAppToSystemLoginItem];
        [FinderSyncUtils setFirstLaunchForCurretnVersion];
        [self pressSettingAppButton:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshMainViewKey object:nil];
    }
    else {
#ifndef DEBUG
       [self pressRestartFinderAction:nil];
#endif
    }
    
}

#pragma mark - FileMoniter
///增加文件修改监控
- (void)setupFileMoniter
{
    NSString *path = [FinderSyncUtils filePathForMonitor:YES];
    
    if (path.length == 0) {
        return;
    }
    
    ///文件夹可能不存在
    NSString *dir = [path stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    ///不管文件是否存在 启动必须重置
    [@{} writeToFile:path atomically:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ///增加监控
        FSEventStreamRef stream = FSEventStreamCreate(kCFAllocatorDefault,
                                                      &eventStreamCallback,
                                                      NULL,
                                                      (__bridge CFArrayRef)@[path],
                                                      kFSEventStreamEventIdSinceNow,
                                                      0, // 事件发生后延迟多少秒调用回调，如果时间设长则有更高的效率，会一次性通知多个事件
                                                      kFSEventStreamCreateFlagFileEvents);
        
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(stream);
        CFRunLoopRun();
    });

    
    NSLog(@"%@",[FinderSyncUtils homeDirectory]);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
//{
//    return YES;
//}

- (void)notificationFinderSyncResult:(NSNotification *)nc
{
    FinderMenuOperationModel *model = [FinderMenuOperationModel readFinderMenuOperationModel];

    if (model.type == FinderMenuTypeCreateFile) {
        [FinderMenuOperationModel runCreateFileCommandAtPaths:model.paths];
        return;
    }
    
    if (_resultWC == nil) {
        _resultWC = [ResultWindowController defaultWindowController];
    }
    
    ///执行命令
    [_resultWC runModel:model];
}


#pragma mark - StatusBarItem
- (void)setupStatusBarItem
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [_statusItem setImage:[NSImage imageNamed:@"menu_20"]];
    [_statusItem setHighlightMode:YES];
    //    [_statusItem.button setTarget:self];
    //    [_statusItem.button setAction:@selector(pressMainMenuStatus:)];
    
    NSMenu *menu = [NSMenu new];
    
    
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"App偏好设置" action:@selector(pressSettingAppButton:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"menu_20"];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"App路径" action:@selector(pressAppDirAction:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"dir"];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"系统偏好设置" action:@selector(pressSystemSettingAction:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"setting"];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"重启Finder" action:@selector(pressRestartFinderAction:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"restart"];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"帮助中心" action:@selector(pressHelpItemButton:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"help"];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"关于我们" action:@selector(pressAboutItemButton:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"info"];
    [menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"退出APP" action:@selector(pressExistItemButton:) keyEquivalent:@""];
    item.image = [NSImage imageNamed:@"exit"];
    [menu addItem:item];
    
    
    _statusItem.menu = menu;
    
    
}

- (void)pressSystemSettingAction:(id)sender
{
    [FinderSyncUtils pressSystemSettingAction];
}


- (void)pressAppDirAction:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
}



- (void)pressRestartFinderAction:(id)sender
{
    [FinderSyncUtils pressRestartFinderAction];
}

- (void)pressSettingAppButton:(id)sender
{
//    [NSApp unhide:nil];
    if (_mainWindowController == nil) {
        _mainWindowController = [MainWindowController defaultWindowVC];
    }
    [_mainWindowController.window makeKeyAndOrderFront:nil];
}

- (void)pressHelpItemButton:(id)sender
{
    [SSPopManager showQuestionPopWindowAtView:_statusItem.button];
}

- (void)pressAboutItemButton:(id)sender
{
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (void)pressExistItemButton:(id)sender
{
    NSAlert *alert = [FinderSyncUtils alertWithText:@"退出APP后, svn菜单将失效, 你确定要退出吗?"
                                             target:self
                                        buttonName1:@"我再想想"
                                      buttonAction1:nil
                                        buttonName2:@"退出"
                                      buttonAction2:@selector(actionExit)];
    
    NSWindow *window = NSApp.keyWindow;
    if (window.isVisible) {
        [alert beginSheetModalForWindow:window completionHandler:nil];
    }
    else {
        [alert runModal];
    }
}


- (void)actionExit
{
    [FinderSyncUtils killProcessName:@"SVNFinderSync"];
    exit(0);
}


@end
