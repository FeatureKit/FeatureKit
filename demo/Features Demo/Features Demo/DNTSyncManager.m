//
//  DNTSyncManager.m
//  Features Demo
//
//  Created by Daniel Thorpe on 21/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSyncManager.h"
#import <YapDatabase/YapDatabase.h>

@implementation DNTSyncManager

#pragma mark - DNTFeatureSource

+ (NSString *)settingKey {
    return @"feature.sync";
}

+ (id <DNTSetting>)settingWithTransaction:(YapDatabaseReadWriteTransaction *)transaction collection:(NSString *)collection {

    NSString *key = [self settingKey];
    DNTFeature *feature = [transaction objectForKey:key inCollection:collection];

    if (!feature) {
        feature = [[DNTFeature alloc] initWithKey:key title:@"New Sync" group:@"In Development"];
    }
    feature.title = @"New sync";
    feature.onByDefault = @NO;
    feature.debugOptionsAvailable = YES;

    [feature debugSettingWithKey:@"feature.sync.debug.verbose-logging" update:^id<DNTSetting>(DNTToggleSetting *toggle, YapDatabaseReadWriteTransaction *transaction) {

        if ( !toggle ) {
            toggle = [[DNTToggleSetting alloc] initWithKey:@"feature.sync.debug.verbose-logging" title:@"Verbose Logging" group:nil];
        }
        toggle.title = @"Verbose Logging";
        toggle.onByDefault = @NO;
        return toggle;

    } transaction:transaction];

    [feature debugSettingWithKey:@"feature.sync.debug.mode" update:^id<DNTSetting>(DNTSelectOptionSetting *select, YapDatabaseReadWriteTransaction *transaction) {

        if ( !select ) {
            select = [[DNTSelectOptionSetting alloc] initWithKey:@"feature.sync.debug.mode" title:@"Sync Mode" group:nil];
        }
        select.title = @"Sync Mode";
        select.optionKeys = @[ @"standard", @"advanced", @"magic" ];
        select.optionTitles = @[ @"Standard", @"Advanced", @"Magic" ];
        select.selectedIndexes = [NSMutableIndexSet indexSetWithIndex:0];
        select.multipleSelectionAllowed = NO;
        return select;

    } transaction:transaction];

    [feature debugSettingWithKey:@"feature.sync.debug.clear-cache" update:^id<DNTSetting>(DNTDebugSetting *debug, YapDatabaseReadWriteTransaction *transaction) {

        if ( !debug ) {
            debug = [[DNTDebugSetting alloc] initWithKey:@"feature.sync.debug.clear-cache" title:@"Clear Cache" group:nil];
        }
        debug.title = @"Clear Cache";
        debug.userInfo[@"special key"] = @"special value";
        debug.notificationName = @"ClearCacheNotification";
        return debug;

    } transaction:transaction];

    return feature;
}

@end
