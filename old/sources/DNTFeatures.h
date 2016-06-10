//
//  DNTFeatures.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNTFeature.h"
#import "DNTFeaturesController.h"

#import "DNTDebugSetting.h"
#import "DNTToggleSetting.h"
#import "DNTSelectOptionSetting.h"

#import "DNTFeature+DebugSettings.h"

@interface DNTFeatures : NSObject

+ (NSString *)version;

@end
