//
//  DNTFeaturesService.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>

#import "DNTFeaturesService.h"
#import "DNTFeature.h"

@implementation DNTFeaturesService

#pragma mark - DNTFeatureService

- (DNTFeature *)featureWithKey:(id)key {
    return [self featureWithKey:key database:self.database collection:self.collection];
}

- (void)loadDefaultFeatures:(NSArray *)extras {
    [super loadDefaultSettings:extras];
}

- (void)resetToDefaults {
    [self resetToDefaultsInDatabase:self.database collection:self.collection];
}

- (void)updateFeatures:(NSArray *)features completion:(void(^)(void))completion {
    [self updateSettings:features update:^id<DNTSetting>(id<DNTSetting> existing, id<DNTSetting> setting, YapDatabaseReadWriteTransaction *transaction) {
        if (existing) {
            [existing updateFromSetting:setting];
            return existing;
        }
        return setting;
    } completion:completion];
}

#pragma mark - Public API

- (DNTFeature *)featureWithKey:(id)key database:(YapDatabase *)database collection:(NSString *)collection {
    return (DNTFeature *)[self settingWithKey:key database:database collection:collection];
}

- (void)loadDefaultSettings:(NSArray *)extras database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion {

}

- (void)resetToDefaultsInDatabase:(YapDatabase *)database collection:(NSString *)collection {

    __block NSMutableArray *requireSaving = [NSMutableArray array];

    [self.readOnlyConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [transaction enumerateKeysAndObjectsInCollection:collection usingBlock:^(NSString *key, id object, BOOL *stop) {
            if ( [object isKindOfClass:[DNTFeature class]] ) {
                DNTFeature *feature = (DNTFeature *)object;
                if ( [feature isToggled] ) {
                    feature.on = [feature.onByDefault copy];
                    [requireSaving addObject:feature];
                }
            }
        }];
    }];

    [self updateSettings:requireSaving asynchronously:YES update:nil database:database collection:collection completion:nil];
}

@end
