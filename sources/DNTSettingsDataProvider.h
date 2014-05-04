//
//  DNTSettingsDataProvider.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNTYapDatabaseDataSource.h"

@class YapDatabase;

@interface DNTSettingsDataProvider : NSObject

@property (nonatomic, weak) YapDatabase *database;
@property (nonatomic, strong) DNTYapDatabaseDataSource *dataSource;

- (instancetype)initWithDatabase:(YapDatabase *)database;

- (DNTTableViewCellConfiguration)createTableViewCellConfigurationBlock;
- (DNTTableViewHeaderTitleConfiguration)createTableViewHeaderTitleConfigurationBlock;
@end

