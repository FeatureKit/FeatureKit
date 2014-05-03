//
//  DNTFeaturesController.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSUIViewControllerDependencyInjection.h"

@class DNTFeaturesDataProvider;

@interface DNTFeaturesController : UITableViewController <BSUIDependencyInjectionSource>

@property (nonatomic, strong) DNTFeaturesDataProvider *dataProvider;

+ (instancetype)controller;

- (IBAction)toggleFeature:(id)sender;

- (IBAction)resetFeatures:(id)sender;

@end
