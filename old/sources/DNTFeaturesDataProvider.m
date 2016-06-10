//
//  DNTFeaturesDataProvider.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeaturesDataProvider.h"
#import "DNTYapDatabaseDataSource.h"

#import "DNTFeatures.h"
#import "DNTToggleCell.h"

#define ONOFF(onoff) onoff ? NSLocalizedString(@"On", nil) : NSLocalizedString(@"Off", nil)
#define VIEW_NAME @"features.view"

@interface DNTFeaturesDataProvider ( /* Private */ )

@property (nonatomic, strong) NSString *collection;
- (YapDatabaseViewGroupingBlock)createDatabaseViewGroupingBlock;
- (YapDatabaseViewSortingBlock)createDatabaseViewSortingBlock;

@end

@implementation DNTFeaturesDataProvider

+ (NSString *)databaseViewName {
    return VIEW_NAME;
}

- (id)initWithDatabase:(YapDatabase *)database {
    self = [super initWithDatabase:database];
    if (self) {
        _collection = [[DNTFeature service] collection];
        self.dataSource = [[DNTYapDatabaseDataSource alloc] initWithDatabase:self.database collection:_collection name:VIEW_NAME];
        self.dataSource.databaseViewGroupingBlock = [self createDatabaseViewGroupingBlock];
        self.dataSource.databaseViewSortingBlock = [self createDatabaseViewSortingBlock];
        self.dataSource.cellConfiguration = [self createTableViewCellConfigurationBlock];
        self.dataSource.headerTitleConfiguration = [self createTableViewHeaderTitleConfigurationBlock];
    }
    return self;
}

#pragma mark - Datasource Configuration

- (YapDatabaseViewGroupingBlock)createDatabaseViewGroupingBlock {
    NSString *collection = self.collection;
    return ^NSString *(NSString *collectionName, NSString *key, DNTFeature *feature) {
        NSString *group = nil;
        if ( [collectionName isEqualToString:collection] ) {
            group = [NSString stringWithFormat:@"%@.%@", feature.groupOrder, feature.group ?: @"General"];
        }
        return group;
    };
}

- (YapDatabaseViewSortingBlock)createDatabaseViewSortingBlock {
    return ^ NSComparisonResult (NSString *group, NSString *collection1, NSString *key1, DNTFeature *feature1, NSString *collection2, NSString *key2, DNTFeature *feature2) {
        return [feature1 compareWithOtherSetting:feature2];
    };
}

#pragma mark - Table View Configuration

- (DNTTableViewCellConfiguration)createTableViewCellConfigurationBlock {
    return ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, DNTFeature *feature) {
        UITableViewCell *cell = nil;
        if ( [feature hasDebugOptions] ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = feature.title;
            cell.detailTextLabel.text = ONOFF([feature isOn]);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            DNTToggleCell *toggleCell = (DNTToggleCell *)cell;
            toggleCell.textLabel.text = feature.title;
            toggleCell.toggle.enabled = feature.editable;
            toggleCell.toggle.on = [feature isOn];
            toggleCell.toggle.tintColor = toggleCell.toggle.onTintColor = [feature isToggled] ? [UIColor redColor] : nil;
            [toggleCell.toggle removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [toggleCell.toggle addTarget:feature action:@selector(toggleSetting:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView bringSubviewToFront:toggleCell.toggle];
        }
        return cell;
    };
}

- (DNTTableViewHeaderTitleConfiguration)createTableViewHeaderTitleConfigurationBlock {
    return ^ NSString *(UITableView *tableView, NSInteger section, DNTFeature *feature) {
        return feature.group;
    };
}

@end
