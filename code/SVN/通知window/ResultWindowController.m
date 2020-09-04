//
//  ResultWindowController.m
//  SVN
//
//  Created by xujun on 2018/5/10.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "ResultWindowController.h"
#import "CommitWindowController.h"

@interface ResultWindowController () <NSTableViewDelegate, NSTableViewDataSource> {
    CommitWindowController *_commitWC;
}
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSButton *closeButton;
@property (nonatomic, strong) NSMutableArray<NSMutableAttributedString *> *dataSource;

@end

@implementation ResultWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSScreenSaverWindowLevel;
    _progressIndicator.usesThreadedAnimation = YES;
    
    _dataSource = [NSMutableArray new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    _tableView.rowHeight = 17;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (NSMutableAttributedString *)lastObjectIfNeedAtDataSource
{
    NSMutableAttributedString *attrStr = _dataSource.lastObject;
    if (!attrStr) {
        attrStr = [NSMutableAttributedString new];
        [_dataSource addObject:attrStr];
    }
    return attrStr;
}

- (IBAction)pressCloseButton:(id)sender
{
    [self.window orderOut:nil];
}

- (void)showWindowVisbaleAndClearData
{
    [self.window makeKeyAndOrderFront:nil];
    [self.window center];
    [_dataSource removeAllObjects];
    [_tableView reloadData];
    

}

///执行命令
- (void)runModel:(FinderMenuOperationModel *)model
{
    SVNCommandBlock commandBlock = ^(FinderMenuOperationModel *opModel, FinderMenuOperationRunType runType, NSAttributedString *result) {
        [self showWithModel:opModel type:runType result:result];
    };
    
//    __weak typeof(model) weakModel = model;
    if (model.type == FinderMenuTypeCommit) {//提交操作日志写日志
        
        [self showWindowVisbaleAndClearData];
        
        if (!_commitWC) {
            _commitWC = [CommitWindowController defaultWindowController];
        }
        
        [_commitWC showSheetInWindow:self.window commitBlock:^(NSString *content) {
            model.content = content;
            [model runSVNCommandWithResponseBlock:commandBlock];
        }];
    }
    else {
        [model runSVNCommandWithResponseBlock:commandBlock];
    }
}

- (void)showWithModel:(FinderMenuOperationModel *)model
                 type:(FinderMenuOperationRunType)type
               result:(NSAttributedString *)result
{
    if (type == FinderMenuOperationRunTypeStart) {
        [self showWindowVisbaleAndClearData];
        [_progressIndicator startAnimation:nil];
    }
    else if (type == FinderMenuOperationRunTypeEnd) {
        [self.window makeKeyAndOrderFront:nil];
        [_progressIndicator stopAnimation:nil];
    }
        
    if (result.length == 0)
        return;
    
    
    [result enumerateAttributesInRange:NSMakeRange(0, result.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        NSString *str = [result.string substringWithRange:range];
        if (str.length == 0) {
            return;
        }
        
        if (![str containsString:@"\n"]) {
            //追加在最后一个数据
            NSMutableAttributedString *attrStr = [self lastObjectIfNeedAtDataSource];
            [attrStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:str attributes:attrs]];
            return;
        }
        
        NSArray *array = [str componentsSeparatedByString:@"\n"];
        
        [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.length == 0 && idx == array.count -1) {
                return;
            }
            NSMutableAttributedString *attrStr = [self lastObjectIfNeedAtDataSource];
            [attrStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:obj attributes:attrs]];
            [self.dataSource addObject:[NSMutableAttributedString new]];//回车追加下一行
        }];
    }];
    


    [_tableView reloadData];
    
    NSUInteger row = _dataSource.count - 1;
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{//等待reloadData完成
        [wself.tableView scrollRowToVisible:row];
    });
    
//    [self.window]
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSAttributedString *str = _dataSource[row];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell" owner:self];
    cell.textField.attributedStringValue = str;
    return cell;
}

//- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
//{
////    if (row != 0) {
////        return 17;
////    }
//    NSAttributedString *str = _dataSource[row];
//    return [str boundingRectWithSize:NSMakeSize(_tableView.frame.size.width, CGFLOAT_MAX)
//                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading].size.height;
//}

@end
