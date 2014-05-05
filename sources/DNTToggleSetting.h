//
//  DNTToggleSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSetting.h"

@interface DNTToggleSetting : DNTDebugSetting

@property (nonatomic, strong) NSNumber *onByDefault;
@property (nonatomic, strong) NSNumber *on;

- (BOOL)isOnByDefault;
- (BOOL)isOn;
- (BOOL)isToggled;

- (void)toggleSetting:(id)sender;

@end
