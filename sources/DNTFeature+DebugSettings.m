//
//  DNTFeature+DebugSettings.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeature+DebugSettings.h"

@implementation DNTFeature (DebugSettings)

- (void)debugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update inTransaction:(YapDatabaseReadWriteTransaction *)transaction {
    DNT_WEAK_SELF
    [DNTDebugSetting updateDebugSettingWithKey:key update:^DNTDebugSetting *(DNTDebugSetting * debugSetting) {
        debugSetting = (DNTDebugSetting *)update(debugSetting);
        debugSetting.featureKey = weakSelf.key;
        return debugSetting;
    } transacation:transaction collection:[DNTDebugSetting collection]];
}

@end
