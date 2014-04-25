//
//  DNTViewController.m
//  Features Demo
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTRootViewController.h"

#import <DNTFeatures/DNTFeatures.h>

@implementation DNTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add some features
    [DNTFeature updateFeatureWithKey:@"feature.bonus" update:^(DNTFeature *feature) {
        feature = [[DNTFeature alloc] initWithKey:@"feature.bonus" title:@"Show bonus content" group:@"Application Features"];
        feature.onByDefault = NO;
        return feature;
    }];

    [DNTFeature updateFeatureWithKey:@"development.sync" update:^(DNTFeature *feature) {
        feature = [[DNTFeature alloc] initWithKey:@"development.sync" title:@"New Sync" group:@"In Development"];
        feature.onByDefault = NO;
        return feature;
    }];
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)segue { }

@end
