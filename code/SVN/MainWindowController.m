//
//  MainWindowController.m
//  SVN
//
//  Created by xujun on 2018/5/10.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()



@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSScreenSaverWindowLevel;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//    [self setupWindowCloseButton];
    
//    [self.window makeKeyWindow];
}


+ (MainWindowController *)defaultWindowVC
{
    MainWindowController *vc = [[NSStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateControllerWithIdentifier:@"MainWindowController"];
    
    return vc;
}


- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
    item.target = self;
    return YES;
}


- (BOOL)resignFirstResponder
{    
    return NO;
}


@end
