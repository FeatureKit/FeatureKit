//
//  DNTYapDatabaseDataSource.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 03/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTYapDatabaseDataSource.h"
#import <YapDatabase/YapDatabaseView.h>
#import <YapDatabase/YapDatabaseViewMappings.h>

@interface DNTYapDatabaseDataSource ( /* Private */ )

@property (nonatomic, strong) YapDatabaseConnection *readOnlyConnection;
@property (nonatomic, strong) YapDatabaseView *databaseView;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;

@end

@implementation DNTYapDatabaseDataSource

+ (NSString *)version {
    return @"1.0";
}

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection name:(NSString *)name {
    NSParameterAssert(database);
    NSParameterAssert(collection);
    NSParameterAssert(name);
    self = [super init];
    if (self) {
        _extensionName = name;
        _database = database;
        _collection = collection;
    }
    return self;
}

- (void)dealloc {
    [_database unregisterExtension:_extensionName];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YapDatabaseModifiedNotification object:_database];
}

#pragma mark - Dynamic Properties

- (YapDatabaseViewMappings *)mappings {
    if ( !_mappings ) {
        [self configure];
    }
    return _mappings;
}

#pragma mark - Configure

- (void)configure {
    self.databaseView = [self createDatabaseView];
    [self.database registerExtension:self.databaseView withName:self.extensionName];

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

- (YapDatabaseView *)createDatabaseView {

    if ( !self.databaseViewGroupingBlock ) {
        if ( [self respondsToSelector:@selector(createDatabaseViewGroupingBlock)] ) {
            self.databaseViewGroupingBlock = [(id <DNTYapDatabaseDataSourceConfiguration>)self createDatabaseViewGroupingBlock];
        }
    }

    if ( !self.databaseViewSortingBlock ) {
        if ( [self respondsToSelector:@selector(createDatabaseViewSortingBlock)] ) {
            self.databaseViewSortingBlock = [(id <DNTYapDatabaseDataSourceConfiguration>)self createDatabaseViewSortingBlock];
        }
    }

    NSAssert(self.databaseViewGroupingBlock, @"Must have a grouping block for the database view");
    NSAssert(self.databaseViewSortingBlock, @"Must have a sorting block for the database view");

    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGroupingBlock:self.databaseViewGroupingBlock groupingBlockType:YapDatabaseViewBlockTypeWithObject sortingBlock:self.databaseViewSortingBlock sortingBlockType:YapDatabaseViewBlockTypeWithObject versionTag:[[self class] version]];

    return view;
}

#pragma mark - Database Mapping

- (YapDatabaseViewMappingGroupFilter)createDatabaseViewMappingsGroupFilter {
    return ^BOOL(NSString *group, YapDatabaseReadTransaction *transaction) {
        return YES;
    };
}

- (YapDatabaseViewMappingGroupSort)createDatabaseViewMappingsGroupSorter {
    return ^NSComparisonResult(NSString *group1, NSString *group2, YapDatabaseReadTransaction *transaction) {
        return [group1 caseInsensitiveCompare:group2];
    };
}

- (YapDatabaseViewMappings *)createDatabaseViewMappings {

    if ( !self.databaseViewMappingsGroupFilter ) {
        self.databaseViewMappingsGroupFilter = [self createDatabaseViewMappingsGroupFilter];
    }

    if ( !self.databaseViewMappingsGroupSorter ) {
        self.databaseViewMappingsGroupSorter = [self createDatabaseViewMappingsGroupSorter];
    }

    NSAssert(self.databaseViewMappingsGroupFilter, @"Must have a group filter block for the view mappings");
    NSAssert(self.databaseViewMappingsGroupSorter, @"Must have a sorter block for the view mappings");

    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroupFilterBlock:self.databaseViewMappingsGroupFilter sortBlock:self.databaseViewMappingsGroupSorter view:self.extensionName];

    return mappings;
}

#pragma mark - Changes

- (void)databaseModified:(NSNotification *)notification {

    NSArray *notifications = [self.readOnlyConnection beginLongLivedReadTransaction];

    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;

    [[self.readOnlyConnection extension:self.extensionName] getSectionChanges:&sectionChanges rowChanges:&rowChanges forNotifications:notifications withMappings:self.mappings];

    if ( ( [sectionChanges count] == 0 ) && ( [rowChanges count] == 0 ) ) {
        return; // Nothing has changed.
    }

    [self.tableView beginUpdates];

    for ( YapDatabaseViewSectionChange *sectionChange in sectionChanges ) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:sectionChange.index];
        switch (sectionChange.type) {
            case YapDatabaseViewChangeDelete: {
                [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
            } break;

            case YapDatabaseViewChangeInsert: {
                [self.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
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
                if ( !self.delegate || [self.delegate datasource:self shouldDeleteRowInTableView:self.tableView atIndexPath:rowChange.indexPath] ) {
                    [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            } break;

            case YapDatabaseViewChangeInsert: {
                if ( !self.delegate || [self.delegate datasource:self shouldInsertRowInTableView:self.tableView atIndexPath:rowChange.newIndexPath] ) {
                    [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            } break;

            case YapDatabaseViewChangeMove: {
                if ( !self.delegate || [self.delegate datasource:self shouldMoveRowInTableView:self.tableView fromIndexPath:rowChange.indexPath toIndexPath:rowChange.newIndexPath] ) {
                    [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            } break;

            case YapDatabaseViewChangeUpdate: {
                if ( !self.delegate || [self.delegate datasource:self shouldReloadRowInTableView:self.tableView atIndexPath:rowChange.indexPath] ) {
                    [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                }
            } break;
        }
    }

    [self.tableView endUpdates];
}

#pragma mark - Public API

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    __block id object = nil;
    DNT_WEAK_SELF
    [self.readOnlyConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        object = [[transaction extension:self.extensionName] objectAtIndexPath:indexPath withMappings:weakSelf.mappings];
    }];
    return object;
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
    if (self.headerTitleConfiguration) {
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
