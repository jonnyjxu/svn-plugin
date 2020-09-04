//
//  FinderSync.m
//  SVNFinderSync
//
//  Created by xujun on 2018/5/2.
//  Copyright © 2018年 Apple Inc. All rights reserved.
//

#import "FinderSync.h"
#import "FinderMenuModel.h"
#import "FinderSyncUtils.h"



@interface FinderSync ()

@property NSURL *myFolderURL;

@property (nonatomic, strong) FinderMenuDataSource *dataSource;

@end

@implementation FinderSync

- (instancetype)init {
    self = [super init];
    
    _dataSource = [FinderMenuDataSource defaultDataSource];
    
    
    //[NSURL fileURLWithPath:@"/Volumes/Unity"],
    _myFolderURL = [NSURL fileURLWithPath:[FinderSyncUtils homeDirectory]?:@""];
    [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObjects:_myFolderURL,nil];

    return self;
}

//- (FinderMenuDataSource *)dataSource
//{
//    if (!_dataSource) {
//        _dataSource = [FinderMenuDataSource defaultDataSource];
//    }
//    return _dataSource;
//}

#pragma mark - Primary Finder Sync protocol methods
- (void)beginObservingDirectoryAtURL:(NSURL *)url {
    
}


- (void)endObservingDirectoryAtURL:(NSURL *)url {
    
}

//- (void)requestBadgeIdentifierForURL:(NSURL *)url {
////    NSInteger whichBadge = [url.path length] % 3;
////    NSString* badgeIdentifier = @[@"User", @"Color", @"Caution"][whichBadge];
//    [[FIFinderSyncController defaultController] setBadgeIdentifier:@"kKeyupdate" forURL:url];
//}

#pragma mark - Menu and toolbar item support
- (NSString *)toolbarItemName {
    return _dataSource.rootMenuModel.name;
}

- (NSString *)toolbarItemToolTip {
    return @"create 2018 @xujun";
}

- (NSImage *)toolbarItemImage {
    return _dataSource.rootMenuModel.image;
}

- (NSMenu *)menuForMenuKind:(FIMenuKind)menu
{
    return [_dataSource menuForMenuKind:menu];
}

- (void)pressMenuItem:(NSMenuItem *)menuItem
{
    [_dataSource pressMenuItem:menuItem];
}


@end

