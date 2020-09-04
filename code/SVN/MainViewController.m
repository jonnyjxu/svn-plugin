//
//  MainViewController.m
//  SVN
//
//  Created by xujun on 2018/5/10.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "MainViewController.h"
#import "FinderSyncUtils.h"
#import "SSPopManager.h"

@interface MainViewController ()

@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSButton *netMoniterButton;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshUI];
    //    [self pressCloseWindowButton:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:kNotificationRefreshMainViewKey object:nil];
}

#pragma mark - actions

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)refreshUI
{
    //开机启动
    if ([FinderSyncUtils isSystemLoginItemForApp]) {
        _loginButton.title = @"关闭开机启动";
        _loginButton.tag = 0;
    }
    else {
        _loginButton.title = @"开启开机启动";
        _loginButton.tag = 1;
    }
    
    //网络监控
    if ([FinderSyncUtils isNetMoniterOpenned]) {
        _netMoniterButton.title = @"关闭网络监控";
        _netMoniterButton.tag = 0;
    }
    else {
        _netMoniterButton.title = @"开启网络监控";
        _netMoniterButton.tag = 1;
    }
}




#pragma mark - CloseButton

#pragma mark - actions
- (IBAction)pressSettingLoginItemAction:(NSButton *)sender
{
    if (sender.tag == 0) {
        
        NSAlert *alert = [FinderSyncUtils alertWithText:@"关闭开机启动后, 下次系统启动, svn菜单将失效, 你确定要关闭吗?"
                                                 target:self
                                            buttonName1:@"我再想想"
                                          buttonAction1:nil
                                            buttonName2:@"关闭"
                                          buttonAction2:@selector(pressDeleteSystemLoginItem:)];
        
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
    else {
        [FinderSyncUtils addAppToSystemLoginItem];
        [self refreshUI];
        
    }
}


- (void)pressDeleteSystemLoginItem:(NSButton *)btn
{
    [FinderSyncUtils deleteAppFromSytemLoginItem];
    [self refreshUI];
    
    [self.view.window endSheet:btn.window];
}


- (IBAction)pressSystemSettingAction:(id)sender
{
    [FinderSyncUtils pressSystemSettingAction];
}

- (IBAction)pressRestartFinderAction:(id)sender
{
    [FinderSyncUtils pressRestartFinderAction];
}

- (IBAction)pressNetMoniterAction:(NSButton *)sender
{
    [FinderSyncUtils setNetMoniter:sender.tag == 1];
    [self refreshUI];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetMoniterConfigChanged object:nil];
}

- (IBAction)pressHelpItemButton:(NSButton *)sender
{
    [SSPopManager showQuestionPopWindowAtView:sender];
}



@end
