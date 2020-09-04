//
//  CommitWindowController.m
//  SVN
//
//  Created by xujun on 2018/8/15.
//  Copyright © 2018年 xujun. All rights reserved.
//

#import "CommitWindowController.h"

@interface CommitWindowController ()
@property (weak) IBOutlet NSTextField *commitTextField;

@property (nonatomic, copy) CommitContentBlock commitBlock;
@end

@implementation CommitWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    
}

- (void)showSheetInWindow:(NSWindow *)window commitBlock:(CommitContentBlock)commitBlock
{
    _commitBlock = commitBlock;
    
    ///无解 beginSheet....未加载的NSWindow加不上去
    [window addChildWindow:self.window ordered:NSWindowAbove];
    [self.window center];

    
    [_commitTextField becomeFirstResponder];
}

- (IBAction)clickCancelButton:(NSButton *)sender
{
    NSWindow *parentWindow = self.window.parentWindow;
    [parentWindow removeChildWindow:self.window];
    
    [self.window orderOut:nil];
    
    if (sender) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [parentWindow orderOut:nil];
        });
    }
}

- (IBAction)clickCommitButton:(NSButton *)sender
{
    if (_commitBlock) {
        _commitBlock(_commitTextField.stringValue);
    }
    [self clickCancelButton:nil];
}

@end
