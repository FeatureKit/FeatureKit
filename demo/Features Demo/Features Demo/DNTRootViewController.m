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
        }
        feature.title = NSLocalizedString(@"Show bonus content", nil);
        feature.onByDefault = NO;
        return feature;
    }];

    [DNTFeature featureWithKey:@"feature.sync" update:^(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {

        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.sync" title:@"New Sync" group:@"In Development"];
        }
        feature.title = NSLocalizedString(@"New sync", nil);
        feature.onByDefault = NO;
        feature.debugOptionsAvailable = YES;

        [feature debugSettingWithKey:@"feature.sync.debug.verbose-logging" update:^DNTDebugSetting *(DNTDebugSettingToggle *debugSetting) {
            if ( !debugSetting ) {
                debugSetting = [[DNTDebugSettingToggle alloc] initWithKey:@"feature.sync.debug.verbose-logging" title:@"Verbose Logging" group:nil];
            }
            debugSetting.title = @"Verbose Logging";
            debugSetting.onByDefault = @NO;
            debugSetting.on = @YES;
            return debugSetting;
        } inTransaction:transaction];

        [feature debugSettingWithKey:@"feature.sync.debug.mode" update:^DNTDebugSetting *(DNTDebugSettingSelect *debugSetting) {
            if ( !debugSetting ) {
                debugSetting = [[DNTDebugSettingSelect alloc] initWithKey:@"feature.sync.debug.mode" title:@"Sync Mode" group:nil];
            }
            debugSetting.optionKeys = @[ @"standard", @"advanced", @"magic" ];
            debugSetting.optionTitles = @[ NSLocalizedString(@"Standard", nil), NSLocalizedString(@"Advanced", nil), NSLocalizedString(@"Magic", nil) ];
            debugSetting.selectedIndexes = [NSMutableIndexSet indexSetWithIndex:0];
            debugSetting.multipleSelectionAllowed = NO;
            return debugSetting;
        } inTransaction:transaction];

        return feature;
    }];
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)segue { }

@end
