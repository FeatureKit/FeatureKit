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

- (void)resetToDefaults {
    [self resetToDefaultsInDatabase:self.database collection:self.collection];
}

- (void)resetToDefaultsInDatabase:(YapDatabase *)database collection:(NSString *)collection {

    YapDatabaseConnection *connection = [database newConnection];
    __block NSMutableArray *requireSaving = [NSMutableArray array];

    [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
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

    [self updateSettings:requireSaving update:nil database:database collection:collection completion:nil];
}

@end
