//
//  DNTDebugSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YapDatabase/YapDatabase.h>

@class DNTDebugSetting;

typedef DNTDebugSetting *(^DNTDebugSettingUpdateBlock)(id debugSetting);

@interface DNTDebugSetting : NSObject <NSCoding>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) id key;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *featureKey;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSNumber *groupOrder;

@property (nonatomic, strong) NSMutableDictionary *userInfo;

- (instancetype)initWithKey:(id)key title:(NSString *)title group:(NSString *)group;

- (NSComparisonResult)compareWithOtherDebugSetting:(DNTDebugSetting *)other;

/// @name Persistence

+ (void)updateDebugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update completion:(void(^)(void))completion;
+ (void)updateDebugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update inDatabase:(YapDatabase *)database collection:(NSString *)collection completion:(void(^)(void))completion;
+ (void)updateDebugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update transacation:(YapDatabaseReadWriteTransaction *)transaction collection:(NSString *)collection;

+ (YapDatabase *)database;
+ (NSString *)collection;

@end
