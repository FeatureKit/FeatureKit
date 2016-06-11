//
//  DNTDebugSettingsController.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DNTDependencyInjection.h"

@class DNTFeature;
@class DNTDebugSettingsDataProvider;

@interface DNTDebugSettingsController : UITableViewController <DNTDependencyInjectionDestination, DNTDependencyInjectionSource>
@property (nonatomic, strong) DNTFeature *feature;
@property (nonatomic, strong) DNTDebugSettingsDataProvider *dataProvider;
@end
