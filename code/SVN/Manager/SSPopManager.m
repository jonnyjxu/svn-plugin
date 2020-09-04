//
//  SSPopManager.m
//  ScreenSaverApp
//
//  Created by xujun on 2016/12/21.
//  Copyright © 2016年 xujun. All rights reserved.
//

#import "SSPopManager.h"
#import "QuestionViewController.h"


@interface SSPopManager ()
@property (nonatomic,strong) NSPopover *questionPopover;
@end

@implementation SSPopManager


+ (instancetype)shareManger
{
    static SSPopManager *gManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gManager = [SSPopManager new];
    });
    
    return gManager;
}

+ (void)showQuestionPopWindowAtView:(NSView *)view
{
    SSPopManager *popManager = [SSPopManager shareManger];
    
    if (popManager.questionPopover == nil) {
        NSPopover *popover = [NSPopover new];
        popover.behavior = NSPopoverBehaviorTransient;
//        popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        popover.contentViewController = [[QuestionViewController alloc] initWithNibName:@"" bundle:nil];
        popManager.questionPopover = popover;
    }

    [popManager.questionPopover showRelativeToRect:view.bounds ofView:view preferredEdge:NSRectEdgeMaxY];
    
    
    
}

@end
