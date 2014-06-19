//
//  DNTFeaturesService.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSettingsService.h"

@class DNTFeature;

@protocol DNTFeaturesService <DNTSettingsService>

- (DNTFeature *)featureWithKey:(id)key;

- (void)resetToDefaults;

- (void)updateFeatures:(NSArray *)features completion:(void(^)(void))completion;

@end

@interface DNTFeaturesService : DNTSettingsService <DNTFeaturesService>

- (DNTFeature *)featureWithKey:(id)key database:(YapDatabase *)database collection:(NSString *)collection;

- (void)resetToDefaultsInDatabase:(YapDatabase *)database collection:(NSString *)collection;

@end
