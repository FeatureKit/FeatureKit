//
//  DNTSettingsService.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNTSetting.h"

@class YapDatabase, YapDatabaseReadWriteTransaction;

typedef void(^DNTVoidCompletionBlock)(void);
typedef id <DNTSetting>(^DNTSettingUpdateBlock)(id <DNTSetting> setting, YapDatabaseReadWriteTransaction *transaction);
typedef id <DNTSetting>(^DNTSettingArrayUpdateBlock)(id <DNTSetting> existing, id <DNTSetting> setting, YapDatabaseReadWriteTransaction *transaction);


@protocol DNTSettingsService <NSObject>

@property (nonatomic, weak) YapDatabase *database;
@property (nonatomic, strong) NSString *collection;

+ (instancetype)service;

- (void)settingWithKey:(id)key update:(DNTSettingUpdateBlock)update completion:(DNTVoidCompletionBlock)completion;

- (void)updateSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update completion:(DNTVoidCompletionBlock)completion;

@end

@interface DNTSettingsService : NSObject <DNTSettingsService>

- (void)settingWithKey:(id)key update:(DNTSettingUpdateBlock)update database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion;

- (void)updateSettings:(NSArray *)settings update:(DNTSettingArrayUpdateBlock)update database:(YapDatabase *)database collection:(NSString *)collection completion:(DNTVoidCompletionBlock)completion;

@end

/// @name Constants
extern NSString * const DNTSettingsDidChangeNotification;
extern NSString * const DNTSettingsNotificationSettingKey;
extern NSString * const DNTSettingDidInvokeNotifcation;

