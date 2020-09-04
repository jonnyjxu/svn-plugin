//
//  FinderMenuModel.m
//  SVNFinderSync
//
//  Created by xujun on 2018/5/2.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "FinderMenuModel.h"
#import "FinderSyncUtils.h"

typedef void (^URLActionBlock)(NSURL * obj, NSUInteger idx, BOOL *stop);

@implementation FinderMenuModel


///svn命令
+ (NSArray<NSString *> *)svnCommandArrayWithType:(FinderMenuType)type content:(NSString *)content
{
#warning add new cmd step
    NSArray *ret = nil;
    switch (type) {
        case FinderMenuTypeUpdate:
            ret = @[@"up",@"更新代码中..."];
            break;
        case FinderMenuTypeCommit:
            ret = @[[NSString stringWithFormat:@"ci -m \"%@\"",content?:@""],@"提交代码中..."];
            break;
        case FinderMenuTypeClean:
            ret = @[@"cleanup",@"清理代码中..."];
            break;
        case FinderMenuTypeCleanDeep:
            ret = @[@"cleanup --vacuum-pristines",@"深度清理代码中..."];
            break;
        case FinderMenuTypeAdd:
            ret = @[@"add",@"添加文件到svn..."];
            break;
        case FinderMenuTypeDelete:
            ret = @[@"delete",@"删除svn文件..."];
            break;
        case FinderMenuTypeLock:
            ret = @[@"lock",@"锁定svn文件..."];
            break;
        case FinderMenuTypeUnLock:
            ret = @[@"unlock",@"解锁svn文件..."];
            break;
        case FinderMenuTypeDiscard:
            ret = @[@"revert",@"还原文件中..."];
            break;
        case FinderMenuTypeLog:
            ret = @[@"log",@"获取svn日志中..."];
            break;
        case FinderMenuTypeInfo:
            ret = @[@"info",@"获取svn信息中..."];
            break;
        case FinderMenuTypeUpgrade:
            ret = @[@"upgrade",@"更新svn版本信息中..."];
            break;
        default:
            break;
    }
    return ret;
}

+ (instancetype)dataWithType:(FinderMenuType)type
{
#warning add new cmd step
    FinderMenuModel *model = [FinderMenuModel new];
    model.type = type;
    switch (type) {
        case FinderMenuTypeRoot:
            model.name = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ? : @"svn";
            model.image = [NSImage imageNamed:@"menu"];
            model.image.template = YES;
            break;
        case FinderMenuTypeUpdate:
            model.name = @"更新代码";
            model.image = [NSImage imageNamed:@"update"];
            break;
        case FinderMenuTypeCommit:
            model.name = @"提交代码";
            model.image = [NSImage imageNamed:@"commit"];
            break;
        case FinderMenuTypeClean:
            model.name = @"清理";
            model.image = [NSImage imageNamed:@"trash"];
            break;
        case FinderMenuTypeCleanDeep:
            model.name = @"深度清理";
            model.image = [NSImage imageNamed:@"trash"];
            break;
        case FinderMenuTypeAdd:
            model.name = @"添加";
            model.image = [NSImage imageNamed:@"add"];//[NSImage imageNamed:NSImageNameApplicationIcon];
            break;
        case FinderMenuTypeDelete:
            model.name = @"删除";
            model.image = [NSImage imageNamed:@"delete"];
            break;
        case FinderMenuTypeLock:
            model.name = @"锁定";
            model.image = [NSImage imageNamed:@"lock"];
            break;
        case FinderMenuTypeUnLock:
            model.name = @"解锁";
            model.image = [NSImage imageNamed:@"unlock"];
            break;
        case FinderMenuTypeDiscard:
            model.name = @"还原文件";
            model.image = [NSImage imageNamed:@"discard"];
            break;
        case FinderMenuTypeLog:
            model.name = @"日志";
            model.image = [NSImage imageNamed:@"log"];
            break;
        case FinderMenuTypeInfo:
            model.name = @"信息";
            model.image = [NSImage imageNamed:@"info"];
            break;
        case FinderMenuTypeUpgrade:
            model.name = @"upgrade";
            model.image = [NSImage imageNamed:@"update"];
            break;
        case FinderMenuTypeCreateFile:
            model.name = @"新建文本文档";
            model.image = [NSImage imageNamed:@"newFile"];
            break;
        case FinderMenuTypeSeparator:
            model.name = @"-----------";
            break;
        case FinderMenuTypeGroup:
            model.name = @"svn其他功能";
            model.image = [NSImage imageNamed:@"menu"];
            break;
        default:
            model.type = FinderMenuTypeUndefined;
            model.name = @"未定义";
            model.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
            break;
    }

    model.identifier = [NSString stringWithFormat:@"kKey%@",model.name];
    
    return model;
}

- (NSMenuItem *)menuItem
{
    NSMenuItem *menuItem;
    if (_type == FinderMenuTypeUndefined ||
        _type == FinderMenuTypeRoot ||
        _type == FinderMenuTypeGroup ) {
        menuItem = [[NSMenuItem alloc] initWithTitle:_name action:nil keyEquivalent:@""];
        
        if (_type != FinderMenuTypeUndefined) {
            menuItem.submenu = [[NSMenu alloc] initWithTitle:@""];
        }
    }
    else if (_type == FinderMenuTypeSeparator) {
        menuItem = [NSMenuItem separatorItem];
        menuItem.title = _name;
    }
    else {
        menuItem = [[NSMenuItem alloc] initWithTitle:_name action:@selector(pressMenuItem:) keyEquivalent:@""];
    }
    
    menuItem.image = _image;
    menuItem.tag = _type;
    
    return menuItem;
}

- (NSMutableArray<FinderMenuModel *> *)childrens
{
    if (!_childrens) {
        _childrens = [NSMutableArray new];
    }
    return _childrens;
}

@end

@interface FinderMenuDataSource ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, FinderMenuModel *> *menuModelDictionary;
@property (nonatomic, strong) FinderMenuModel *rootMenuModel;

@end

@implementation FinderMenuDataSource

+ (instancetype)defaultDataSource
{
    FinderMenuDataSource *dataSource = [FinderMenuDataSource new];
    [dataSource setupDataSource];
    return dataSource;
}

- (void)setupDataSource
{
#warning add new cmd step
    _menuModelDictionary = [NSMutableDictionary new];
    
    _rootMenuModel = [self addFinderMenuModelWithType:FinderMenuTypeRoot parent:nil];//must first step
    
    
    [_rootMenuModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeUpdate parent:_rootMenuModel]];
    [_rootMenuModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeCommit parent:_rootMenuModel]];
    
    
    FinderMenuModel *groupModel = [self addFinderMenuModelWithType:FinderMenuTypeGroup parent:_rootMenuModel];
    [_rootMenuModel.childrens addObject:groupModel];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeAdd parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeDelete parent:groupModel]];
    
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeSeparator parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeLock parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeUnLock parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeClean parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeCleanDeep parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeUpgrade parent:groupModel]];

    
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeSeparator parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeDiscard parent:groupModel]];
    
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeSeparator parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeLog parent:groupModel]];
    [groupModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeInfo parent:groupModel]];

    ///增加一个新建文件菜单
    [_rootMenuModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeSeparator parent:_rootMenuModel]];
    [_rootMenuModel.childrens addObject:[self addFinderMenuModelWithType:FinderMenuTypeCreateFile parent:_rootMenuModel]];
}


- (FinderMenuModel *)addFinderMenuModelWithType:(FinderMenuType)type parent:(FinderMenuModel *)parent
{
    FinderMenuModel *model = [FinderMenuModel dataWithType:type];
    model.parent = parent;
    
    [_menuModelDictionary setObject:model forKey:@(type)];

    ///文件图标
    [[FIFinderSyncController defaultController] setBadgeImage:model.image label:model.name forBadgeIdentifier:model.identifier];
    
//    if (type == FinderMenuTypeRoot) {
//        _menuItem = [[NSMenuItem alloc] initWithTitle:model.name action:nil keyEquivalent:@""];
//        _menuItem.submenu = [[NSMenu alloc] initWithTitle:@""];
//        _menuItem.image = model.image;
//
//        _toolbarMenu = [[NSMenu alloc] initWithTitle:@""];
//    }
//    else {
//        NSMenuItem *submenu = [[NSMenuItem alloc] initWithTitle:model.name action:@selector(pressMenuItem:) keyEquivalent:@""];
//        submenu.image = model.image;
//        submenu.tag = type;
//        [_menuItem.submenu addItem:submenu];
//
//        [_toolbarMenu addItem:submenu.copy];
//
//
//    }
    
    return model;
}

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu
{
    NSMenu *menu = nil;
    
    switch (whichMenu) {
        case FIMenuKindToolbarItemMenu:
            menu = [self menuWithRootMenu:NO];
            break;
//        case FIMenuKindContextualMenuForContainer:
//        case FIMenuKindContextualMenuForItems:
//            break;
        case FIMenuKindContextualMenuForSidebar:
            break;
        default:
            menu = [self menuWithRootMenu:NO];
            break;
    }
    
    return menu;
}



///是否需要合并到一个root 目录下面
- (NSMenu *)menuWithRootMenu:(BOOL)needRootMenu
{
    NSMenuItem *menuItem = nil;
    
    [self model:_rootMenuModel toMenuItem:&menuItem];

    if (!menuItem) {
        return nil;
    }
    
    NSMenu *menu;
    if (needRootMenu) {
        menu = [[NSMenu alloc] initWithTitle:@""];
        [menu addItem:menuItem];
    }
    else {
        menu = menuItem.submenu;
    }
    
    
    return menu;
}

- (void)model:(FinderMenuModel *)model toMenuItem:(NSMenuItem **)menuItem
{
    if (!model) {
        return;
    }
    
    if (!(*menuItem)) {
        *menuItem = [model menuItem];
    }
    
    for (FinderMenuModel *sub in model.childrens) {
        if (!(*menuItem).submenu) {
            (*menuItem).submenu = [[NSMenu alloc] initWithTitle:@""];
        }
        
        NSMenuItem *subMenuItem = [sub menuItem];
        
        [(*menuItem).submenu addItem:subMenuItem];
        
        [self model:sub toMenuItem:&subMenuItem];
    }

}

- (FinderMenuModel *)modelForType:(FinderMenuType)type
{
    return _menuModelDictionary[@(type)];
}


#pragma mark - Actions
- (void)pressMenuItem:(NSMenuItem *)menuItem
{

#if 1
    [FinderMenuOperationModel writeFinderMenuOperationModelWithType:menuItem.tag];
    
#else
    NSString *identifier = [self modelForType:menuItem.tag].identifier;
    
    [self actionToSelectedURLs:^(NSURL * obj, NSUInteger idx, BOOL *stop) {
        
        NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:kFinderSyncBundleID];
        
        [userDefault setObject:obj.path forKey:@"test"];
        [userDefault synchronize];
        
        ///以下方式都不能 传递消息 坑爹啊
//        NSString *str = [FinderSyncUtils runSVNCommand:@"up" atPaths:@[obj.path]];
        NSString *str = [FinderSyncUtils runSVNCommand:@"up" atPaths:@[obj.path]];
        [userDefault setObject:str?:@"" forKey:@"test1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFinderSyncResultKey object:nil userInfo:@{kNotificationFinderSyncResultKey:str?:@""}];
        
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationFinderSyncResultKey object:nil userInfo:@{kNotificationFinderSyncResultKey:str?:@""} deliverImmediately:YES];
//        NSAlert *alert = [NSAlert new];
//        [alert addButtonWithTitle:@"确定"];
//        alert.informativeText = str;
//        [alert runModal];
        
        [[FIFinderSyncController defaultController] setBadgeIdentifier:identifier forURL:obj];//把文件加个图标(唯一有用的东西)
    }];
#endif
    
    
//    system("pluginkit -e ignore -i com.mycompany.finderExt");
    
}


- (void)actionToSelectedURLs:(URLActionBlock)action
{
    NSArray* items = [FIFinderSyncController defaultController].selectedItemURLs;
    if (items.count) {
        [items enumerateObjectsUsingBlock:^(NSURL * obj, NSUInteger idx, BOOL * stop) {
            if (![FinderSyncUtils fileUrlIsInvisible:obj]) {
                action(obj, idx, stop);
            }
        }];
    }
    else {
        action([FIFinderSyncController defaultController].targetedURL, 0, nil);
    }
    
}

@end


@interface FinderMenuOperationModel ()
@property (nonatomic, assign) FinderMenuType type;
@property (nonatomic, strong) NSArray<NSString *> *paths;
@end

@implementation FinderMenuOperationModel

+ (instancetype)dataWithType:(FinderMenuType)type paths:(NSArray<NSString *> *)paths
{
    FinderMenuOperationModel *model = [self new];
    model.type = type;
    model.paths = paths;
    return model;
}

+ (instancetype)dataWithFinderSyncType:(FinderMenuType)type
{
    FinderMenuOperationModel *model = [self new];
    model.type = type;

    NSArray* items = [FIFinderSyncController defaultController].selectedItemURLs;
    if (items.count == 0) {
        items = @[[FIFinderSyncController defaultController].targetedURL];
    }
    model.paths = [items pathsForURLs];
    return model;
}

+ (NSArray<NSString *> *)selectedFinderSyncPaths
{
    NSArray* items = [FIFinderSyncController defaultController].selectedItemURLs;
    if (items.count == 0) {
        items = @[[FIFinderSyncController defaultController].targetedURL];
    }
    return [items pathsForURLs];
}

+ (void)runCreateFileCommandAtPaths:(NSArray<NSString *> *)paths
{
    if (paths.count == 0) {
        return;
    }
    
    NSString *filePath;
    if (paths.count > 1) {
        filePath = [paths.firstObject stringByDeletingLastPathComponent];
    }
    else {
        filePath = paths.firstObject;
    }
    
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        return;
    }
    
    
    if (!isDirectory) {
        filePath = [filePath stringByDeletingLastPathComponent];
    }
    
    NSString *fileName = @"新建文本文档";
    
    NSString *path = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",fileName]];
    
    int index = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.txt",fileName,index]];
        ++index;
        
        if (index == 1000) {
            break;
        }
    }
    
    NSString *command = [NSString stringWithFormat:@"touch %@",path];
    [FinderSyncUtils runSystemCommand:command];
    
}

//运行命令
- (void)runSVNCommandWithResponseBlock:(SVNCommandBlock)responseBlock
{
    NSString *errorString = nil;
    NSArray *paths = _paths;
    if (paths.count == 0) {
        errorString = @"error:路径不能为空\n";
    }
    
    NSArray *array = [FinderMenuModel svnCommandArrayWithType:_type content:_content];
    if (!errorString && array.count == 0) {
        errorString = @"error:执行的svn命令不正确\n";
    }

    NSColor *errColor = [NSColor redColor];
    if (errorString) {
        if (responseBlock) {
            NSMutableAttributedString *result = [NSMutableAttributedString attributedStringWithString:errorString color:errColor font:nil];
            responseBlock(self, FinderMenuOperationRunTypeEnd, result);
        }
        return;
    }
    
    NSString *separatorLine = @"---------------------------------------------------------------------\n";
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    [result appendString:separatorLine];
    [result appendString:[NSString stringWithFormat:@"%@\n",array.lastObject?:@""] color:[NSColor blueColor] font:nil];
    [result appendString:[paths componentsJoinedByString:@"\n"] color:[NSColor magentaColor] font:nil];
    [result appendString:[NSString stringWithFormat:@"\n%@",separatorLine]];
    
    [result appendString:@"[开始执行...BEGIN]\n" color:[NSColor blueColor] font:nil];
    
    if (responseBlock) {
        responseBlock(self, FinderMenuOperationRunTypeStart, result);
    }
    
    [FinderSyncUtils runSVNCommand:array.firstObject atPaths:paths responseBlock:^(BOOL complete, NSString * _Nullable output, NSError * _Nullable error) {
        
        FinderMenuOperationRunType runType = FinderMenuOperationRunTypeLoading;
        NSMutableAttributedString *result = [NSMutableAttributedString new];
        
        if (output) {
            [result appendString:output color:[NSColor systemBlueColor] font:nil];
        }
        
        if (error) {
            [result appendString:error.domain color:errColor font:nil];
        }
        
        if (complete) {
            runType = FinderMenuOperationRunTypeEnd;
            [result appendString:@"[执行完成...END]\n" color:[NSColor blueColor] font:nil];
        }
        
        if (responseBlock) {
            responseBlock(self, runType, result);
        }
    }];

    
}

///写入缓存的路径 (FinderMenuType)
+ (void)writeFinderMenuOperationModelWithType:(FinderMenuType)type
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSArray *paths = [self selectedFinderSyncPaths];
    [dic setObject:@(type) forKey:@"type"];
    [dic setObject:paths?:@[] forKey:@"paths"];
    [dic writeToFile:[FinderSyncUtils filePathForMonitor:NO] atomically:YES];
}

///读取缓存的路径
+ (FinderMenuOperationModel *)readFinderMenuOperationModel
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[FinderSyncUtils filePathForMonitor:YES]];
    FinderMenuOperationModel *model = [FinderMenuOperationModel dataWithType:[dic[@"type"] integerValue] paths:dic[@"paths"]];
    return model;
    
}

@end


