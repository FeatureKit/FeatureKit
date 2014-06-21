//
//  DNTSettingsService.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNTSetting.h"

@class YapDatabase, YapDatabaseConnection, YapDatabaseReadWriteTransaction;

typedef void(^DNTVoidCompletionBlock)(void);
typedef id <DNTSetting>(^DNTSettingUpdateBlock)(id <DNTSetting> setting, YapDatabaseReadWriteTransaction *transaction);
typedef id <DNTSetting>(^DNTSettingArrayUpdateBlock)(id <DNTSetting> existing, id <DNTSetting> setting, YapDatabaseReadWriteTransaction *transaction);


@protocol DNTSettingsService <NSObject>

@property (nonatomic, weak) YapDatabase *database;
@property (nonatomic, strong) NSString *collection;

+ (instancetype)service;

- (id <DNTSetting>)settingWithKey:(id)key;

- (void)loadDefaultSettings:(NSArray *)extras;

- (void)settingWithKey:(id)key load:(DNTSettingUpdateBlock)update completion:(DNTVoidCompletionBlock)completion;

- (void)settingWithKey:(id)key update:(DNTSettingUpdateBlock)update completion:(DNTVoidCompletionBlock)completion;

- (void)loadSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update completion:(DNTVoidCompletionBlock)completion;

- (void)updateSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update completion:(DNTVoidCompletionBlock)completion;

@end

@protocol DNTSettingSource <NSObject>

+ (NSString *)settingKey;

+ (id <DNTSetting>)settingWithTransaction:(YapDatabaseReadWriteTransaction *)transaction collection:(NSString *)collection;

@end

@interface DNTSettingsService : NSObject <DNTSettingsService>

@property (nonatomic, strong) YapDatabaseConnection *readOnlyConnection;
@property (nonatomic, strong) YapDatabaseConnection *readWriteConnection;

- (id <DNTSetting>)settingWithKey:(id)key
                         database:(YapDatabase *)database
                       collection:(NSString *)collection;

- (void)loadDefaultSettings:(NSArray *)extras
                   database:(YapDatabase *)database
                 collection:(NSString *)collection
                 completion:(DNTVoidCompletionBlock)completion;

- (void)settingWithKey:(id)key
        asynchronously:(BOOL)asynchronously
                update:(DNTSettingUpdateBlock)update
              database:(YapDatabase *)database
            collection:(NSString *)collection
            completion:(DNTVoidCompletionBlock)completion;

- (void)updateSettings:(NSArray *)settings
        asynchronously:(BOOL)asynchronously
                update:(DNTSettingArrayUpdateBlock)update
              database:(YapDatabase *)database
            collection:(NSString *)collection
            completion:(DNTVoidCompletionBlock)completion;

- (void)executeReadWriteTransaction:(void(^)(YapDatabaseReadWriteTransaction *transaction))transaction
                         completion:(void(^)(void))completion
                     asynchronously:(BOOL)asynchronously;

- (NSArray *)defaultSettingsFromSources;

@end

/// @name Constants
extern NSString * const DNTSettingsDidChangeNotification;
extern NSString * const DNTSettingsNotificationSettingKey;
extern NSString * const DNTSettingDidInvokeNotifcation;

