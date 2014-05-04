//
//  DNTToggleSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSetting.h"

@interface DNTToggleSetting : DNTSetting

@property (nonatomic, strong) NSNumber *onByDefault;
@property (nonatomic, strong) NSNumber *on;

- (BOOL)isOnByDefault;
- (BOOL)isOn;
- (BOOL)isToggled;

@end
