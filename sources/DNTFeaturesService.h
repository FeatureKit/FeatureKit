//
//  DNTFeaturesService.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSettingsService.h"

@protocol DNTFeaturesService <DNTSettingsService>

- (void)resetToDefaults;

@end

@interface DNTFeaturesService : DNTSettingsService <DNTFeaturesService>

- (void)resetToDefaultsInDatabase:(YapDatabase *)database collection:(NSString *)collection;

@end
