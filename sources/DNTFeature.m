//
//  DNTFeature.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeature.h"
#import "DNTFeaturesService.h"

#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseTransaction.h>

@interface DNTFeature ( /* Private */ )
@end

@implementation DNTFeature

+ (NSString *)collection {
    return @"dnt.features";
}

+ (id <DNTFeaturesService>)service {
    id <DNTFeaturesService> service = [DNTFeaturesService service];
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

- (NSDictionary *)debugSettings {

    id <DNTFeaturesService> service = [[self class] service];
    YapDatabaseConnection *connection = [[service database] newConnection];

    __block NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    NSString *featureKey = self.key;

    [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [transaction enumerateKeysAndObjectsInCollection:[DNTSetting collection] usingBlock:^(NSString *key, id <DNTSetting> object, BOOL *stop) {
            if ( [object isKindOfClass:[DNTDebugSetting class]] ) {
                DNTDebugSetting *setting = (DNTDebugSetting *)object;
                if ( [setting.featureKey isEqualToString:featureKey] ) {
                    [settings setObject:setting forKey:setting.key];
                }
            }
        }];
    }];

    return settings;
}

- (void)debugSettingWithKey:(id)key update:(DNTSettingUpdateBlock)update transaction:(YapDatabaseReadWriteTransaction *)transaction {
    NSString *collection = [DNTSetting collection];
    DNTDebugSetting *debug = (DNTDebugSetting *)update([transaction objectForKey:key inCollection:collection], transaction);
    debug.featureKey = self.key;
    [transaction setObject:debug forKey:key inCollection:collection];
}

@end
