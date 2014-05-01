//
//  DNTFeature+DebugSettings.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeature.h"
#import "DNTDebugSetting.h"

@class YapDatabaseReadWriteTransaction;

@interface DNTFeature (DebugSettings)

- (void)debugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update inTransaction:(YapDatabaseReadWriteTransaction *)transaction;

@end
