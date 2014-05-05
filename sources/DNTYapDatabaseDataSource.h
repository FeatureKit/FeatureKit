//
//  DNTYapDatabaseDataSource.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 03/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseView.h>
#import <YapDatabase/YapDatabaseViewMappings.h>

typedef UITableViewCell *(^DNTTableViewCellConfiguration) (UITableView *tableView, NSIndexPath *indexPath, id object);
typedef NSString * (^DNTTableViewHeaderTitleConfiguration) (UITableView *tableView, NSInteger section, id firstObject);
typedef NSString * (^DNTTableViewFooterTitleConfiguration) (UITableView *tableView, NSInteger section);

@protocol DNTYapDatabaseDataSourceDefaultConfiguration <NSObject>
- (YapDatabaseViewMappingGroupFilter)createDatabaseViewMappingsGroupFilter;
- (YapDatabaseViewMappingGroupSort)createDatabaseViewMappingsGroupSorter;
@end

@protocol DNTYapDatabaseDataSourceConfiguration <DNTYapDatabaseDataSourceDefaultConfiguration>
- (void)configure;
- (YapDatabaseViewGroupingBlock)createDatabaseViewGroupingBlock;
- (YapDatabaseViewSortingBlock)createDatabaseViewSortingBlock;
@end

@class DNTYapDatabaseDataSource;

@protocol DNTYapDatabaseDataSourceDelegate <NSObject>

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldDeleteRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldInsertRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;


- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldMoveRowInTableView:(UITableView *)tableView fromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldReloadRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 * @abstract
 * Generic data provider for settings.
 * @discussion It is possible to either subclass this provider, and implement the
 * create methods. Alternatively instantiate direction and set block properties.
 * @notes It assumes that you need Object block types for the DatabaseView.
 */
@interface DNTYapDatabaseDataSource : NSObject <UITableViewDataSource, DNTYapDatabaseDataSourceDefaultConfiguration>

@property (nonatomic, weak) id <DNTYapDatabaseDataSourceDelegate> delegate;

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong, readonly) NSString *collection;
@property (nonatomic, strong, readonly) YapDatabase *database;

/// @name Configuration

@property (nonatomic, copy) YapDatabaseViewGroupingBlock databaseViewGroupingBlock;
@property (nonatomic, copy) YapDatabaseViewSortingBlock databaseViewSortingBlock;
@property (nonatomic, copy) YapDatabaseViewMappingGroupFilter databaseViewMappingsGroupFilter;
@property (nonatomic, copy) YapDatabaseViewMappingGroupSort databaseViewMappingsGroupSorter;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) DNTTableViewCellConfiguration cellConfiguration;
@property (nonatomic, copy) DNTTableViewHeaderTitleConfiguration headerTitleConfiguration;
@property (nonatomic, copy) DNTTableViewFooterTitleConfiguration footerTitleConfiguration;

+ (NSString *)version;

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection name:(NSString *)name;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
