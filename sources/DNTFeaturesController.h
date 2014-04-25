//
//  DNTFeaturesController.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNTFeaturesDataProvider;

@interface DNTFeaturesController : UITableViewController

@property (nonatomic, strong) DNTFeaturesDataProvider *dataProvider;

+ (instancetype)controller;

- (IBAction)toggleFeature:(id)sender;

@end
