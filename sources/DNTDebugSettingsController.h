//
//  DNTDebugSettingsController.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSUIViewControllerDependencyInjection.h"

@class DNTFeature;
@class DNTDebugSettingsDataProvider;

@interface DNTDebugSettingsController : UITableViewController <BSUIDependencyInjectionDestination, BSUIDependencyInjectionSource>
@property (nonatomic, strong) DNTFeature *feature;
@property (nonatomic, strong) DNTDebugSettingsDataProvider *dataProvider;
@end
