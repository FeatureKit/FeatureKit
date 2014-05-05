//
//  DNTSettingsDataProvider.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSettingsDataProvider.h"

@implementation DNTSettingsDataProvider

- (instancetype)initWithDatabase:(YapDatabase *)database {
    self = [super init];
    if (self) {
        _database = database;
    }
    return self;
}

- (DNTTableViewCellConfiguration)createTableViewCellConfigurationBlock {
    return nil;
}

- (DNTTableViewHeaderTitleConfiguration)createTableViewHeaderTitleConfigurationBlock {
    return nil;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource objectAtIndexPath:indexPath];
}

@end
