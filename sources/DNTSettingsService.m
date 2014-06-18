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

#pragma mark - DNTSettingsService

- (void)settingWithKey:(id)key update:(DNTSettingUpdateBlock)update completion:(DNTVoidCompletionBlock)completion {
    [self settingWithKey:key update:update database:self.database collection:self.collection completion:completion];
}

- (void)updateSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update completion:(DNTVoidCompletionBlock)completion {
    [self updateSettings:settings update:update database:self.database collection:self.collection completion:completion];
}

#pragma mark - Public API

- (void)settingWithKey:(id)key update:(DNTSettingUpdateBlock)update database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion {
    NSParameterAssert(key);
    __block id <DNTSetting> setting = nil;
    YapDatabaseConnection *connection = [database newConnection];
    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        id <DNTSetting> existing = [transaction objectForKey:key inCollection:collection];
        setting = update(existing, transaction) ?: existing;
        [transaction setObject:setting forKey:key inCollection:collection];
    } completionBlock:^{
        if (completion) completion();
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        if ( setting.notificationName ) {
            [nc postNotificationName:setting.notificationName object:self userInfo:@{ DNTSettingsNotificationSettingKey : setting }];
        }
        else {
            [nc postNotificationName:DNTSettingsDidChangeNotification object:self userInfo:@{ DNTSettingsNotificationSettingKey : setting }];
        }
    }];
}

- (void)updateSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion {

    YapDatabaseConnection *connection = [database newConnection];
    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {

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
    } completionBlock:^{
        if (completion) completion();
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:DNTSettingsDidChangeNotification object:self];
    }];
}

@end

#pragma mark - Constants
NSString * const DNTSettingsDidChangeNotification = @"DNTSettingsDidChangeNotificationName";
NSString * const DNTSettingsNotificationSettingKey = @"DNTSettingsNotificationSettingKey";
NSString * const DNTSettingDidInvokeNotifcation = @"DNTSettingDidInvokeNotifcation";
