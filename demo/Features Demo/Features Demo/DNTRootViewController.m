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

    [[DNTFeature service] settingWithKey:@"feature.bonus" update:^id<DNTSetting>(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {

        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.bonus" title:@"Show bonus content" group:@"Application Features"];
        }
        feature.title = NSLocalizedString(@"Show bonus content", nil);
        feature.onByDefault = @NO;
        return feature;

    } completion:nil];

    [[DNTFeature service] settingWithKey:@"feature.sync" update:^id<DNTSetting>(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {

        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.sync" title:@"New Sync" group:@"In Development"];
        }
        feature.title = NSLocalizedString(@"New sync", nil);
        feature.onByDefault = @NO;
        feature.debugOptionsAvailable = YES;

        [feature debugSettingWithKey:@"feature.sync.debug.verbose-logging" update:^DNTDebugSetting *(DNTDebugSetting *debug, YapDatabaseReadWriteTransaction *transaction) {
            DNTToggleSetting *setting = (DNTToggleSetting *)debug.setting;
            if ( !debug ) {
                setting = [[DNTToggleSetting alloc] initWithKey:@"feature.sync.debug.verbose-logging" title:@"Verbose Logging" group:nil];
                debug = [[DNTDebugSetting alloc] initWithSetting:setting];
            }
            setting.title = @"Verbose Logging";
            setting.onByDefault = @NO;
            debug.setting = setting;
            return debug;

        } transaction:transaction];

        [feature debugSettingWithKey:@"feature.sync.debug.mode" update:^DNTDebugSetting *(DNTDebugSetting *debug, YapDatabaseReadWriteTransaction *transaction) {
            DNTSelectOptionSetting *setting = (DNTSelectOptionSetting *)debug.setting;
            if ( !debug ) {
                setting = [[DNTSelectOptionSetting alloc] initWithKey:@"feature.sync.debug.mode" title:@"Sync Mode" group:nil];
                debug = [[DNTDebugSetting alloc] initWithSetting:setting];
            }
            setting.title = @"Sync Mode";
            setting.optionKeys = @[ @"standard", @"advanced", @"magic" ];
            setting.optionTitles = @[ NSLocalizedString(@"Standard", nil), NSLocalizedString(@"Advanced", nil), NSLocalizedString(@"Magic", nil) ];
            setting.selectedIndexes = [NSMutableIndexSet indexSetWithIndex:0];
            setting.multipleSelectionAllowed = NO;

            debug.setting = setting;
            return debug;

        } transaction:transaction];

        return feature;

    } completion:nil];
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)segue { }

@end
