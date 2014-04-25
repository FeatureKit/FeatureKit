//
//  DNTDebugSettingToggle.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSetting.h"

@interface DNTDebugSettingToggle : DNTDebugSetting

@property (nonatomic, strong) NSNumber *onByDefault;
@property (nonatomic, strong) NSNumber *on;

- (BOOL)isOn;

@end
