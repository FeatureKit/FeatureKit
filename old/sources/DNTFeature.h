//
//  DNTFeature.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNTToggleSetting.h"
#import "DNTFeaturesService.h"

@class YapDatabaseReadWriteTransaction;

@interface DNTFeature : DNTToggleSetting <NSCoding>

@property (nonatomic, getter = hasDebugOptions) BOOL debugOptionsAvailable;

+ (id <DNTFeaturesService>)service;

- (NSDictionary *)debugSettings;

- (void)debugSettingWithKey:(id)key update:(DNTSettingUpdateBlock)update transaction:(YapDatabaseReadWriteTransaction *)transaction;

@end