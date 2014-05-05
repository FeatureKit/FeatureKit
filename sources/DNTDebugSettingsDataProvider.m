//
//  DNTDebugSettingsDataProvider.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingsDataProvider.h"
#import "DNTFeature.h"
#import "DNTDebugSetting.h"
#import "DNTSelectOptionSetting.h"

#import "DNTToggleCell.h"

#define VIEW_NAME @"debug-settings.view"

@interface DNTDebugSettingsDataProvider ( /* Private */ ) <DNTYapDatabaseDataSourceDelegate>

@property (nonatomic, strong) NSString *collection;
- (YapDatabaseViewGroupingBlock)createDatabaseViewGroupingBlock;
- (YapDatabaseViewSortingBlock)createDatabaseViewSortingBlock;

@end

@implementation DNTDebugSettingsDataProvider

+ (NSString *)databaseViewName {
    return VIEW_NAME;
}

- (id)initWithDatabase:(YapDatabase *)database feature:(DNTFeature *)feature {
    self = [super initWithDatabase:database];
    if (self) {
        _feature = feature;
        _collection = [[DNTSetting service] collection];
        self.dataSource = [[DNTYapDatabaseDataSource alloc] initWithDatabase:self.database collection:_collection name:VIEW_NAME];
        self.dataSource.databaseViewGroupingBlock = [self createDatabaseViewGroupingBlock];
        self.dataSource.databaseViewSortingBlock = [self createDatabaseViewSortingBlock];
        self.dataSource.cellConfiguration = [self createTableViewCellConfigurationBlock];
        self.dataSource.headerTitleConfiguration = [self createTableViewHeaderTitleConfigurationBlock];
        self.dataSource.delegate = self;
    }
    return self;
}

#pragma mark - Database View

- (YapDatabaseViewGroupingBlock)createDatabaseViewGroupingBlock {
    NSString *collection = self.collection;
    DNT_WEAK_SELF
    return ^NSString *(NSString *collectionName, NSString *key, id object) {
        NSString *group = nil;
        if ( [object isKindOfClass:[DNTFeature class]] && [((DNTFeature *)object).key isEqualToString:weakSelf.feature.key] ) {
            group = [NSString stringWithFormat:@"%d.%@", -1, NSLocalizedString(@"Feature", nil)];
        }
        else if ( [collectionName isEqualToString:collection] ) {
            DNTDebugSetting *debug = (DNTDebugSetting *)object;
            if ( (debug.featureKey.length > 0) && ![debug.featureKey isEqualToString:weakSelf.feature.key] ) {
                return nil;
            }
            group = [NSString stringWithFormat:@"%@.%@", debug.groupOrder, debug.group ?: NSLocalizedString(@"Debug Settings", nil)];
        }
        return group;
    };
}

- (YapDatabaseViewSortingBlock)createDatabaseViewSortingBlock {
    return ^ NSComparisonResult (NSString *group, NSString *collection1, NSString *key1, DNTDebugSetting *object1, NSString *collection2, NSString *key2, DNTDebugSetting *object2) {
        return [object1 compareWithOtherSetting:object2];
    };
}

#pragma mark - Table View Configuration

- (DNTTableViewCellConfiguration)createTableViewCellConfigurationBlock {
    DNT_WEAK_SELF
    return ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id object) {

        if ( [object isKindOfClass:[DNTFeature class]] ) {
            return [weakSelf configuredCellWithFeature:(DNTFeature *)object inTableView:tableView atIndexPath:indexPath];
        }
        else if ( [object isKindOfClass:[DNTDebugSetting class]] ) {
            DNTDebugSetting *debug = (DNTDebugSetting *)object;
            if ( [debug isKindOfClass:[DNTToggleSetting class]] ) {
                return [weakSelf configuredCellWithToggleSetting:(DNTToggleSetting *)debug inTableView:tableView atIndexPath:indexPath];
            }
            else if ( [debug isKindOfClass:[DNTSelectOptionSetting class]] ) {
                return [weakSelf configuredCellWithSelectSetting:(DNTSelectOptionSetting *)debug inTableView:tableView atIndexPath:indexPath];
            }
        }
        return nil;
    };
}

- (UITableViewCell *)configuredCellWithFeature:(DNTFeature *)feature inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    DNTToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
    cell.textLabel.text = feature.title;
    cell.toggle.enabled = [feature isEditable];
    cell.toggle.on = [feature isOn];
    cell.toggle.tintColor = cell.toggle.onTintColor = [feature isToggled] ? [UIColor redColor] : nil;
    [cell.toggle removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.toggle addTarget:feature action:@selector(toggleSetting:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView bringSubviewToFront:cell.toggle];
    self.feature = feature;
    return cell;
}

- (UITableViewCell *)configuredCellWithToggleSetting:(DNTToggleSetting *)toggle inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    DNTToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
    cell.textLabel.text = toggle.title;
    cell.toggle.enabled = [self.feature isOn];
    cell.toggle.on = [toggle isOn];
    cell.toggle.tintColor = cell.toggle.onTintColor = nil;
    [cell.toggle removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.toggle addTarget:toggle action:@selector(toggleSetting:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView bringSubviewToFront:cell.toggle];
    return cell;
}

- (UITableViewCell *)configuredCellWithSelectSetting:(DNTSelectOptionSetting *)select inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Select" forIndexPath:indexPath];
    cell.textLabel.text = select.title;
    if ( [select.selectedIndexes count] > 1 ) {
        cell.detailTextLabel.text = NSLocalizedString(@"Multiple", nil);
    }
    else {
        cell.detailTextLabel.text = select.optionTitles[[select.selectedIndexes firstIndex]];
    }
    return cell;
}

- (DNTTableViewHeaderTitleConfiguration)createTableViewHeaderTitleConfigurationBlock {
    return ^ NSString *(UITableView *tableView, NSInteger section, id object) {
        if ( [object conformsToProtocol:@protocol(DNTSetting)] ) {
            return [(id <DNTSetting>)object group];
        }
        return ((DNTDebugSetting *)object).group ?: NSLocalizedString(@"Debug Settings", nil);
    };
}

#pragma mark - DNTYapDatabaseDataSourceDelegate

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldDeleteRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldInsertRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldMoveRowInTableView:(UITableView *)tableView fromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    return YES;
}

- (BOOL)datasource:(DNTYapDatabaseDataSource *)dataSource shouldReloadRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    if ( [object isKindOfClass:[DNTFeature class]] ) {
        self.feature = object;
        [tableView reloadRowsAtIndexPaths:tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
        return NO;
    }
    return YES;
}

@end
