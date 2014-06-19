//
//  DNTSettingsService.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSettingsService.h"
#import "YapDatabase+DNTFeatures.h"

static YapDatabase *__database;

@implementation DNTSettingsService

@synthesize database = _database;
@synthesize collection = _collection;

#pragma mark - DNTSettingsService

+ (instancetype)service {
    return [[self alloc] init];
}

- (YapDatabase *)database {
    if ( !_database ) {
        if ( !__database ) {
            __database = [[YapDatabase alloc] initWithPath:[YapDatabase pathForDatabaseWithName:@"Settings"]];
        }
        _database = __database;
    }
    return _database;
}

- (YapDatabaseConnection *)readOnlyConnection {
    if ( !_readOnlyConnection ) {
        _readOnlyConnection = [self.database newConnection];
    }
    return _readOnlyConnection;
}

- (YapDatabaseConnection *)readWriteConnection {
    if ( !_readWriteConnection ) {
        _readWriteConnection = [self.database newConnection];
    }
    return _readWriteConnection;
}

#pragma mark - DNTSettingsService

- (id <DNTSetting>)settingWithKey:(id)key {
    return [self settingWithKey:key database:self.database collection:self.collection];
}

- (void)settingWithKey:(id)key load:(DNTSettingUpdateBlock)update completion:(DNTVoidCompletionBlock)completion {
    [self settingWithKey:key asynchronously:NO update:update database:self.database collection:self.collection completion:completion];
}

- (void)settingWithKey:(id)key update:(DNTSettingUpdateBlock)update completion:(DNTVoidCompletionBlock)completion {
    [self settingWithKey:key asynchronously:YES update:update database:self.database collection:self.collection completion:completion];
}

- (void)loadSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update completion:(DNTVoidCompletionBlock)completion {
    [self updateSettings:settings asynchronously:NO update:update database:self.database collection:self.collection completion:completion];
}

- (void)updateSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update completion:(DNTVoidCompletionBlock)completion {
    [self updateSettings:settings asynchronously:YES update:update database:self.database collection:self.collection completion:completion];
}

#pragma mark - Public API

- (id <DNTSetting>)settingWithKey:(id)key database:(YapDatabase *)database collection:(NSString *)collection {
    NSParameterAssert(key);
    __block id <DNTSetting> setting = nil;
    [self.readOnlyConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        setting = [transaction objectForKey:key inCollection:collection];
    }];
    return setting;
}

- (void)settingWithKey:(id)key asynchronously:(BOOL)asynchronously update:(DNTSettingUpdateBlock)update database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion {
    NSParameterAssert(key);

    __block id <DNTSetting> setting = nil;

    [self executeReadWriteTransaction:^(YapDatabaseReadWriteTransaction *transaction) {

        id <DNTSetting> existing = [transaction objectForKey:key inCollection:collection];
        setting = update(existing, transaction) ?: existing;
        [transaction setObject:setting forKey:key inCollection:collection];

    } completion:^{

        if (completion) {
            completion();
        }

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        if ( setting.notificationName ) {
            [nc postNotificationName:setting.notificationName object:self userInfo:@{ DNTSettingsNotificationSettingKey : setting }];
        }
        else {
            [nc postNotificationName:DNTSettingsDidChangeNotification object:self userInfo:@{ DNTSettingsNotificationSettingKey : setting }];
        }
        
    } asynchronously:asynchronously];

}

- (void)updateSettings:(NSArray *)settings asynchronously:(BOOL)asynchronously update:(DNTSettingArrayUpdateBlock)update database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion {

    [self executeReadWriteTransaction:^(YapDatabaseReadWriteTransaction *transaction) {

        for ( id object in settings ) {
            if ( [object conformsToProtocol:@protocol(DNTSetting)] ) {
                id <DNTSetting> setting = (id <DNTSetting>)object;
                id <DNTSetting> existing = [transaction objectForKey:setting.key inCollection:collection];
                if (update) {
                    setting = update(existing, setting, transaction);
                }
                [transaction setObject:setting forKey:setting.key inCollection:collection];
            }
        }

    } completion:^{

        if (completion) {
            completion();
        }

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:DNTSettingsDidChangeNotification object:self];

    } asynchronously:asynchronously];
}

- (void)executeReadWriteTransaction:(void(^)(YapDatabaseReadWriteTransaction *transaction))transaction completion:(void(^)(void))completion asynchronously:(BOOL)asynchronously {
    if (asynchronously) {
        [self.readWriteConnection asyncReadWriteWithBlock:transaction completionBlock:completion];
    }
    else {
        [self.readWriteConnection readWriteWithBlock:transaction];
        if (completion) {
            completion();
        }
    }
}

@end

#pragma mark - Constants
NSString * const DNTSettingsDidChangeNotification = @"DNTSettingsDidChangeNotificationName";
NSString * const DNTSettingsNotificationSettingKey = @"DNTSettingsNotificationSettingKey";
NSString * const DNTSettingDidInvokeNotifcation = @"DNTSettingDidInvokeNotifcation";

