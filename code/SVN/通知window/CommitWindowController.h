//
//  CommitWindowController.h
//  SVN
//
//  Created by xujun on 2018/8/15.
//  Copyright © 2018年 xujun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseWindowController.h"

typedef void(^CommitContentBlock)(NSString *content);

@interface CommitWindowController : BaseWindowController

- (void)showSheetInWindow:(NSWindow *)window commitBlock:(CommitContentBlock)commitBlock;

@end
