//
//  BaseWindowController.m
//  SVN
//
//  Created by xujun on 2018/8/15.
//  Copyright © 2018年 xujun. All rights reserved.
//

#import "BaseWindowController.h"

@interface BaseWindowController ()

@end

@implementation BaseWindowController

///默认初始化
+ (instancetype)defaultWindowController
{
    return [[self alloc] initWithWindowNibName:NSStringFromClass(self.class)];
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}



@end
