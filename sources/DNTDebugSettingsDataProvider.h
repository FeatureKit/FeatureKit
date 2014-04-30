//
//  DNTDebugSettingsDataProvider.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YapDatabase/YapDatabase.h>

#import "DNTFeaturesDataProvider.h"

@class DNTDebugSetting;

@interface DNTDebugSettingsDataProvider : NSObject

@property (nonatomic, strong, readonly) YapDatabase *database;
@property (nonatomic, strong, readonly) NSString *collection;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) DNTTableViewCellConfiguration cellConfiguration;
@property (nonatomic, copy) DNTTableViewHeaderTitleConfiguration headerTitleConfiguration;
@property (nonatomic, copy) DNTTableViewFooterTitleConfiguration footerTitleConfiguration;

+ (NSString *)databaseViewName;

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection;

- (DNTDebugSetting *)objectAtIndexPath:(NSIndexPath *)indexPath;

@end

