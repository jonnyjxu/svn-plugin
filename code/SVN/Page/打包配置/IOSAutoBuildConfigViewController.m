//
//  IOSAutoBuildConfigViewController.m
//  SVN
//
//  Created by xujun on 2020/5/22.
//  Copyright © 2020 xujun. All rights reserved.
//

#import "IOSAutoBuildConfigViewController.h"
#import "FinderSyncUtils.h"

@interface IOSAutoBuildConfigViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *textField;

@end

@implementation IOSAutoBuildConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _textField.stringValue = [FinderSyncUtils autoBulidIOSTaskPath];
}

- (IBAction)pressSelectPathButton:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setMessage:@"请选择需要执行的脚本文件"];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
        NSString *path = [openPanel URL].path;
        self.textField.stringValue = path;
        }
    }];
}

- (IBAction)pressSaveButton:(NSButton *)sender
{
    [self.view.window.sheetParent endSheet:sender.window];
    [FinderSyncUtils setAutoBulidIOSTaskPath:_textField.stringValue ? : @""];
}

@end
