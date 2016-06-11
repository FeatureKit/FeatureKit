//
//  DNTSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DNTSettingsService;

@protocol DNTSetting <NSObject>

@property (nonatomic, strong) id key;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *parentSettingKey;

@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSNumber *groupOrder;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, getter = isEditable) BOOL editable;

@property (nonatomic, strong) NSString *notificationName;

- (NSComparisonResult)compareWithOtherSetting:(id <DNTSetting>)setting;

- (BOOL)updateFromSetting:(id <DNTSetting>)setting;

/// @name Service
+ (id <DNTSettingsService>)service;

+ (NSString *)collection;

@end

@interface DNTSetting : NSObject <DNTSetting, NSCoding>

- (id)initWithKey:(id)key title:(NSString *)title group:(NSString *)group;

+ (NSInteger)version;

@end

@protocol DNTSettingServiceTestSupport <NSObject>
+ (id <DNTSettingsService>)serviceTest;
@end

#import "DNTSettingsService.h"