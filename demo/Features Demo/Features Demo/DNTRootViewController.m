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
    [DNTFeature featureWithKey:@"feature.bonus" update:^(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {
        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.bonus" title:@"Show bonus content" group:@"Application Features"];
            feature.onByDefault = NO;
        }
        return feature;
    }];

    [DNTFeature featureWithKey:@"feature.sync" update:^(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {

        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.sync" title:@"New Sync" group:@"In Development"];
            feature.onByDefault = NO;

            [feature debugSettingWithKey:@"feature.sync.debug.verbose-logging" update:^DNTDebugSetting *(DNTDebugSettingToggle *debugSetting) {
                if ( !debugSetting ) {
                    debugSetting = [[DNTDebugSettingToggle alloc] initWithKey:@"feature.sync.debug.verbose-logging" title:@"Verbose Logging" group:nil];
                    debugSetting.onByDefault = @NO;
                    debugSetting.on = @YES;
                }
                return debugSetting;
            } inTransaction:transaction];

            feature.debugOptionsAvailable = YES;
        }
        return feature;
    }];
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)segue { }

@end
