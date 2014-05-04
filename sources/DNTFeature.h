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

@class YapDatabase, YapDatabaseReadWriteTransaction;
@class DNTFeature;

typedef DNTFeature *(^DNTFeatureBlock)(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction);

@interface DNTFeature : DNTToggleSetting <NSCoding>

@property (nonatomic, getter = hasDebugOptions) BOOL debugOptionsAvailable;

+ (id <DNTFeaturesService>)service;

- (void)switchOnOrOff:(BOOL)onOrOff;

/// @name Persisted Access

//+ (NSArray *)features;
//+ (NSArray *)featuresInDatabase:(YapDatabase *)database collection:(NSString *)collection;
//
//+ (instancetype)featureWithKey:(id)key;
//+ (instancetype)featureWithKey:(id)key inDatabase:(YapDatabase *)database collection:(NSString *)collection;
//
//+ (void)featureWithKey:(id)key update:(DNTFeatureBlock)update;
//+ (void)featureWithKey:(id)key update:(DNTFeatureBlock)update inDatabase:(YapDatabase *)database collection:(NSString *)collection;
//+ (DNTFeature *)featureWithKey:(id)key update:(DNTFeatureBlock)update collection:(NSString *)collection transaction:(YapDatabaseReadWriteTransaction *)transaction;
//
//+ (void)switchFeatureWithKey:(id)key onOrOff:(BOOL)onOrOff;
//+ (void)switchFeatureWithKey:(id)key onOrOff:(BOOL)onOrOff inDatabase:(YapDatabase *)database collection:(NSString *)collection;

@end

/// @name Constants
extern NSString * const DNTFeaturesDidChangeNotification;
extern NSString * const DNTFeaturesNotificationFeatureKey;