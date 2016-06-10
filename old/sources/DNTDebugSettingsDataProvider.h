//
//  DNTDebugSettingsDataProvider.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSettingsDataProvider.h"

@class DNTFeature;

@interface DNTDebugSettingsDataProvider : DNTSettingsDataProvider

@property (nonatomic, strong) DNTFeature *feature;

- (id)initWithDatabase:(YapDatabase *)database feature:(DNTFeature *)feature;

@end

