//
//  DNTDebugSettingSelect.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSetting.h"

@interface DNTDebugSettingSelect : DNTDebugSetting

@property (nonatomic, strong) NSDictionary *selectOptions;
@property (nonatomic, strong) NSString *selection;

@end    
