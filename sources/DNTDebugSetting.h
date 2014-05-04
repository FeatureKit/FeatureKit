//
//  DNTDebugSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNTFeature.h"

@protocol DNTSetting;
@class YapDatabaseReadWriteTransaction;

@interface DNTDebugSetting : NSObject
@property (nonatomic, strong) NSString *featureKey;
@property (nonatomic, strong) id <DNTSetting> setting;

- (id)initWithSetting:(id <DNTSetting>)setting;

@end

typedef DNTDebugSetting *(^DNTDebugSettingUpdateBlock)(DNTDebugSetting * debug, YapDatabaseReadWriteTransaction *transaction);

@interface DNTFeature ( DNTDebugSetting )

- (void)debugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update transaction:(YapDatabaseReadWriteTransaction *)transaction;

@end

