//
//  DNTDebugSetting.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSetting.h"

#import "DNTFeatures.h"
#import "YapDatabase+DNTFeatures.h"

static YapDatabase *__database;
static NSString *__collection;

@implementation DNTDebugSetting


- (id)initWithKey:(id)key title:(NSString *)title group:(NSString *)group {
    self = [super init];
    if (self) {
        _identifier = nil;
        _key = key;
        _title = title;
        _featureKey = nil;
        _group = group;
        _groupOrder = @0;
        _userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identifier forKey:DNT_STRING(_identifier)];
    [aCoder encodeObject:_key forKey:DNT_STRING(_key)];
    [aCoder encodeObject:_title forKey:DNT_STRING(_title)];
    [aCoder encodeObject:_featureKey forKey:DNT_STRING(_featureKey)];
    [aCoder encodeObject:_group forKey:DNT_STRING(_group)];
    [aCoder encodeObject:_groupOrder forKey:DNT_STRING(_groupOrder)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [aDecoder decodeObjectForKey:DNT_STRING(_identifier)];
        _key = [aDecoder decodeObjectForKey:DNT_STRING(_key)];
        _title = [aDecoder decodeObjectForKey:DNT_STRING(_title)];
        _featureKey = [aDecoder decodeObjectForKey:DNT_STRING(_featureKey)];
        _group = [aDecoder decodeObjectForKey:DNT_STRING(_group)];
        _groupOrder = [aDecoder decodeObjectForKey:DNT_STRING(_groupOrder)];
        _userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Persistence

+ (void)updateDebugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update {
    return [self updateDebugSettingWithKey:key update:update inDatabase:[self database] collection:[self collection]];
}

+ (void)updateDebugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update inDatabase:(YapDatabase *)database collection:(NSString *)collection {
    NSParameterAssert(key);
    YapDatabaseConnection *connection = [database newConnection];
    DNT_WEAK_SELF
    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [weakSelf updateDebugSettingWithKey:key update:update transacation:transaction collection:collection];
    } completionBlock:^{
        // TODO: post a notification
    }];
}

+ (void)updateDebugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update transacation:(YapDatabaseReadWriteTransaction *)transaction collection:(NSString *)collection {
    DNTDebugSetting *existing = [transaction objectForKey:key inCollection:collection];
    DNTDebugSetting *debugSetting = update(existing);
    [transaction setObject:debugSetting forKey:key inCollection:collection];
}

+ (void)setDefaultDatabase:(YapDatabase *)database collection:(NSString *)collection {
    __database = database;
    __collection = collection;
}

+ (YapDatabase *)database {
    if ( !__database ) {
        __database = [DNTFeature database];
    }
    return __database;
}

+ (NSString *)collection {
    if ( !__collection ) {
        __collection = @"debug-settings";
    }
    return __collection;
}

+ (NSInteger)version {
    return 1;
}

@end
