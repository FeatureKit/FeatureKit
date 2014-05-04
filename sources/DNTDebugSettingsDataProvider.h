//
//  DNTDebugSettingsDataProvider.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTYapDatabaseDataSource.h"

@class DNTFeature;

@interface DNTDebugSettingsDataProvider : DNTYapDatabaseDataSource

@property (nonatomic, strong) DNTFeature *feature;

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection feature:(DNTFeature *)feature;

@end

