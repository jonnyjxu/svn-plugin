//
//  FinderMenuModel.h
//  SVNFinderSync
//
//  Created by xujun on 2018/5/2.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <FinderSync/FinderSync.h>

//NS_ENUM(NSInteger, FinderMenuType) {//mac os也是牛逼了
//    FinderMenuTypeUndefined, //未定义
//    
//    FinderMenuTypeUpdate,   //更新
//    FinderMenuTypeCommit,   //提交
//    FinderMenuTypeClean,    //清理
//};



typedef enum : NSUInteger {
    FinderMenuTypeUndefined, //未定义
    
    FinderMenuTypeRoot, //根目录
    
    FinderMenuTypeUpdate,   //更新
    FinderMenuTypeCommit,   //提交
    FinderMenuTypeClean,    //清理
    FinderMenuTypeCleanDeep, //深度清理
    FinderMenuTypeAdd,    //添加
    FinderMenuTypeDelete,    //删除
    FinderMenuTypeLock,    //锁定
    FinderMenuTypeUnLock,    //解锁
    FinderMenuTypeDiscard,    //还原
    FinderMenuTypeLog,    //日志
    FinderMenuTypeInfo,    //信息
    FinderMenuTypeUpgrade,//更新svn版本
    
    FinderMenuTypeCreateFile,//新建文本文档
    
    
    FinderMenuTypeSeparator,  //分割线
    FinderMenuTypeGroup,    //其他分组
} FinderMenuType;



typedef enum : NSUInteger {
    FinderMenuOperationRunTypeStart,//开始
    FinderMenuOperationRunTypeLoading,//加载中
    FinderMenuOperationRunTypeEnd,//结束
} FinderMenuOperationRunType;

@interface FinderMenuModel : NSObject
+ (instancetype)dataWithType:(FinderMenuType)type;
@property (nonatomic, assign) FinderMenuType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSImage *image;
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, weak) FinderMenuModel *parent;
@property (nonatomic, strong) NSMutableArray<FinderMenuModel *> *childrens;
@end




@interface FinderMenuDataSource : NSObject

+ (instancetype)defaultDataSource;

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu;

@property (nonatomic, strong, readonly) FinderMenuModel *rootMenuModel;

- (void)pressMenuItem:(NSMenuItem *)menuItem;

@end

@class FinderMenuOperationModel;
typedef void(^SVNCommandBlock)(FinderMenuOperationModel *opModel, FinderMenuOperationRunType runType, NSAttributedString *result);
///菜单操作的数据
@interface FinderMenuOperationModel : NSObject

@property (nonatomic, assign, readonly) FinderMenuType type;//操作类型
@property (nonatomic, strong, readonly) NSArray<NSString *> *paths;//写入路径
@property (nonatomic, copy) NSString *content;//内容 也许是提交日志 之类的


///运行创建文件命令
+ (void)runCreateFileCommandAtPaths:(NSArray<NSString *> *)paths;
//运行svn命令
- (void)runSVNCommandWithResponseBlock:(SVNCommandBlock)responseBlock;

///写入缓存的路径
+ (void)writeFinderMenuOperationModelWithType:(FinderMenuType)type;
///读取缓存的路径
+ (FinderMenuOperationModel *)readFinderMenuOperationModel;
@end
