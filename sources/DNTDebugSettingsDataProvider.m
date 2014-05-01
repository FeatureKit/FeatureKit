//
//  DNTDebugSettingsDataProvider.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingsDataProvider.h"

#import <YapDatabase/YapDatabaseView.h>
#import <YapDatabase/YapDatabaseViewMappings.h>

#import "DNTFeatures.h"

#define VIEW_NAME @"debug-settings.view"

@interface DNTDebugSettingsDataProvider ( /* Private */ )

@property (nonatomic, strong) YapDatabaseConnection *readOnlyConnection;
@property (nonatomic, strong) YapDatabaseView *databaseView;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;

@end

@implementation DNTDebugSettingsDataProvider

+ (NSString *)databaseViewName {
    return VIEW_NAME;
}

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection feature:(DNTFeature *)feature {
    self = [super init];
    if (self) {
        _database = database;
        _collection = collection;
        _feature = feature;
        [self configure];
    }
    return self;
}

- (void)dealloc {
    [_database unregisterExtension:VIEW_NAME];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YapDatabaseModifiedNotification object:_database];
}

#pragma mark - Configure

- (void)configure {
    self.databaseView = [self createDatabaseView];
    [self.database registerExtension:self.databaseView withName:VIEW_NAME];

    self.readOnlyConnection = [self.database newConnection];
    [self.readOnlyConnection beginLongLivedReadTransaction];

    self.mappings = [self createDatabaseViewMappings];
    DNT_WEAK_SELF
    [self.readOnlyConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [weakSelf.mappings updateWithTransaction:transaction];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseModified:) name:YapDatabaseModifiedNotification object:self.database];
}

#pragma mark - Database View

- (YapDatabaseViewGroupingBlock)databaseViewGroupingBlock {
    NSString *collection = self.collection;
    DNT_WEAK_SELF
    return ^NSString *(NSString *collectionName, NSString *key, id object) {
        NSString *group = nil;
        if ( [object isKindOfClass:[DNTFeature class]] && [((DNTFeature *)object).key isEqualToString:weakSelf.feature.key] ) {
            group = [NSString stringWithFormat:@"%d.%@", -1, NSLocalizedString(@"Feature", nil)];
        }
        else if ( [collectionName isEqualToString:collection] ) {
            DNTDebugSetting *setting = (DNTDebugSetting *)object;
            if ( (setting.featureKey.length > 0) && ![setting.featureKey isEqualToString:weakSelf.feature.key] ) {
                return nil;
            }
            group = [NSString stringWithFormat:@"%@.%@", setting.groupOrder, setting.group ?: NSLocalizedString(@"Debug Settings", nil)];
        }
        return group;
    };
}

- (YapDatabaseViewSortingBlock)databaseViewSortingBlock {
    return ^ NSComparisonResult (NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        return [(DNTDebugSetting *)object1 compareWithOtherDebugSetting:(DNTDebugSetting *)object2];
    };
}

- (YapDatabaseView *)createDatabaseView {
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:[self databaseViewGroupingBlock] groupingBlockType:YapDatabaseViewBlockTypeWithObject sortingBlock:[self databaseViewSortingBlock] sortingBlockType:YapDatabaseViewBlockTypeWithObject versionTag:[DNTFeatures version]];
    return view;
}

#pragma mark - Database Mapping

- (YapDatabaseViewMappingGroupFilter)databaseViewMappingsGroupFilter {
    return ^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    };
}

- (YapDatabaseViewMappingGroupSort)databaseViewMappingsGroupSorter {
    return ^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return [group1 caseInsensitiveCompare:group2];
    };
}

- (YapDatabaseViewMappings *)createDatabaseViewMappings {
    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:[self databaseViewMappingsGroupFilter] sortBlock:[self databaseViewMappingsGroupSorter] view:VIEW_NAME];
    return mappings;
}

#pragma mark - Changes

- (void)databaseModified:(NSNotification *)notification {

    NSArray *notifications = [self.readOnlyConnection beginLongLivedReadTransaction];

    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;

    [[self.readOnlyConnection extension:VIEW_NAME] getSectionChanges:&sectionChanges rowChanges:&rowChanges forNotifications:notifications withMappings:self.mappings];

    if ( ( [sectionChanges count] == 0 ) && ( [rowChanges count] == 0 ) ) {
        return; // Nothing has changed.
    }

    [self.tableView beginUpdates];

    for ( YapDatabaseViewSectionChange *sectionChange in sectionChanges ) {
        switch (sectionChange.type) {
            case YapDatabaseViewChangeDelete: {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index] withRowAnimation:UITableViewRowAnimationAutomatic];
            } break;

            case YapDatabaseViewChangeInsert: {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index] withRowAnimation:UITableViewRowAnimationAutomatic];
            } break;

            case YapDatabaseViewChangeMove:
            case YapDatabaseViewChangeUpdate:
            default:
                break;
        }
    }

    for ( YapDatabaseViewRowChange *rowChange in rowChanges ) {
        switch (rowChange.type) {
            case YapDatabaseViewChangeDelete: {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            } break;

            case YapDatabaseViewChangeInsert: {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            } break;

            case YapDatabaseViewChangeMove: {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            } break;

            case YapDatabaseViewChangeUpdate: {
                if ( [[self objectAtIndexPath:rowChange.indexPath] isKindOfClass:[DNTFeature class]] ) {
                    self.feature = [self objectAtIndexPath:rowChange.indexPath];
                    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
                else {
                    [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                }
            } break;
        }
    }

    [self.tableView endUpdates];
}

#pragma mark - Public API

- (DNTDebugSetting *)objectAtIndexPath:(NSIndexPath *)indexPath {
    __block DNTDebugSetting *setting = nil;
    DNT_WEAK_SELF
    [self.readOnlyConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        setting = [[transaction extension:VIEW_NAME] objectAtIndexPath:indexPath withMappings:weakSelf.mappings];
    }];
    return setting;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.mappings numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mappings numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(self.cellConfiguration, @"Must set the cell configuration block.");
    id object = [self objectAtIndexPath:indexPath];
    return self.cellConfiguration(tableView, indexPath, object);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( self.feature.key && (section == 0)) {
        return NSLocalizedString(@"Feature", nil);
    } else if (self.headerTitleConfiguration) {
        id object = [self objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        return self.headerTitleConfiguration(tableView, section, object);
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.footerTitleConfiguration) {
        return self.footerTitleConfiguration(tableView, section);
    }
    return nil;
}

@end
