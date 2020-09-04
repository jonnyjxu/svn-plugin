//
//  ResultWindowController.h
//  SVN
//
//  Created by xujun on 2018/5/10.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseWindowController.h"
#import "FinderMenuModel.h"


@interface ResultWindowController : BaseWindowController

///执行命令
- (void)runModel:(FinderMenuOperationModel *)model;

@end
