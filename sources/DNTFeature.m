//
//  DNTFeature.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeature.h"
#import "DNTFeaturesService.h"

@interface DNTFeature ( /* Private */ )

//- (void)modify:(void(^)(DNTFeature *feature))modifications;
//
//- (void)modify:(void(^)(DNTFeature *feature))modifications completion:(void(^)(void))completion inDatabase:(YapDatabase *)database collection:(NSString *)collection;

@end

@implementation DNTFeature

+ (NSString *)collection {
    return @"dnt.features";
}

+ (id <DNTSettingsService>)service {
    id <DNTSettingsService> service = [DNTFeaturesService service];
    service.collection = [self collection];
    return service;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_debugOptionsAvailable forKey:DNT_STRING(_debugOptionsAvailable)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _debugOptionsAvailable = [aDecoder decodeBoolForKey:DNT_STRING(_debugOptionsAvailable)];
    }
    return self;
}

#pragma mark - Public API

- (void)switchOnOrOff:(BOOL)onOrOff {
    [[[self class] service] settingWithKey:self.key update:^id<DNTSetting>(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {
        feature.on = @(onOrOff);
        return feature;
    } completion:nil];
}

//#pragma mark - Service
//
//+ (NSArray *)features {
//    return [self featuresInDatabase:[self database] collection:[self collection]];
//}
//
//+ (NSArray *)featuresInDatabase:(YapDatabase *)database collection:(NSString *)collection {
//    __block NSMutableArray *features = [NSMutableArray array];
//    YapDatabaseConnection *connection = [database newConnection];
//    [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
//        [transaction enumerateKeysAndObjectsInCollection:collection usingBlock:^(NSString *key, id object, BOOL *stop) {
//            if ( [object isKindOfClass:[DNTFeature class]] ) {
//                [features addObject:object];
//            }
//        }];
//    }];
//    return features;
//}
//
//+ (instancetype)featureWithKey:(id)key {
//    return [self featureWithKey:key inDatabase:[self database] collection:[self collection]];
//}
//
//+ (instancetype)featureWithKey:(id)key inDatabase:(YapDatabase *)database collection:(NSString *)collection {
//    NSParameterAssert(key);
//    __block DNTFeature *feature = nil;
//    YapDatabaseConnection *connection = [database newConnection];
//    [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
//        feature = [transaction objectForKey:key inCollection:collection];
//    }];
//    return feature;
//}
//
//+ (void)featureWithKey:(id)key update:(DNTFeatureBlock)update {
//    [self featureWithKey:key update:update inDatabase:[self database] collection:[self collection]];
//}
//
//+ (void)featureWithKey:(id)key update:(DNTFeatureBlock)update inDatabase:(YapDatabase *)database collection:(NSString *)collection {
//    NSParameterAssert(key);
//    YapDatabaseConnection *connection = [database newConnection];
//    __block DNTFeature *feature = nil;
//    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        feature = [self featureWithKey:key update:update collection:collection transaction:transaction];
//    } completionBlock:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:DNTFeaturesDidChangeNotification object:nil userInfo:@{ DNTFeaturesNotificationFeatureKey : feature }];
//    }];
//}
//
//+ (DNTFeature *)featureWithKey:(id)key update:(DNTFeatureBlock)update collection:(NSString *)collection transaction:(YapDatabaseReadWriteTransaction *)transaction {
//    DNTFeature *existing = [transaction objectForKey:key inCollection:collection];
//    DNTFeature *feature = update(existing, transaction);
//    if (feature && existing) {
//        feature->_on = feature.on || existing.on;
//    }
//    [transaction setObject:feature forKey:key inCollection:collection];
//    return feature;
//}
//
//+ (void)switchFeatureWithKey:(id)key onOrOff:(BOOL)onOrOff {
//    [self switchFeatureWithKey:key onOrOff:onOrOff inDatabase:[self database] collection:[self collection]];
//}
//
//+ (void)switchFeatureWithKey:(id)key onOrOff:(BOOL)onOrOff inDatabase:(YapDatabase *)database collection:(NSString *)collection {
//    [self featureWithKey:key update:^(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {
//        feature->_on = onOrOff;
//        return feature;
//    } inDatabase:database collection:collection];
//}

//#pragma mark - Private API
//
//- (void)modify:(void(^)(DNTFeature *feature))modifications {
//    [self modify:modifications completion:nil inDatabase:[[self class] database] collection:[[self class] collection]];
//}
//
//- (void)modify:(void(^)(DNTFeature *feature))modifications completion:(void(^)(void))completion inDatabase:(YapDatabase *)database collection:(NSString *)collection {
//    modifications(self);
//    YapDatabaseConnection *connection = [database newConnection];
//    DNT_WEAK_SELF
//    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        __strong DNTFeature *strongSelf = weakSelf;
//        [transaction setObject:strongSelf forKey:strongSelf.key inCollection:collection];
//    } completionBlock:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:DNTFeaturesDidChangeNotification object:self userInfo:@{ DNTFeaturesNotificationFeatureKey : self}];
//        if (completion) completion();
//    }];
//}

@end
