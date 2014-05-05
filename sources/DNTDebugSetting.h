//
//  DNTDebugSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNTSetting.h"

@class YapDatabaseReadWriteTransaction;

@interface DNTDebugSetting : DNTSetting
@property (nonatomic, strong) NSString *featureKey;
@end

