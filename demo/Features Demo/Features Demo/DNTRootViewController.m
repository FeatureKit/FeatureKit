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
    [[DNTFeature service] settingWithKey:@"feature.bonus" load:^id<DNTSetting>(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {

        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.bonus" title:@"Show bonus content" group:@"Application Features"];
        }
        feature.title = @"Show bonus content";
        feature.onByDefault = @NO;
        return feature;
        
    } completion:nil];

    [[DNTFeature service] settingWithKey:@"feature.sync" load:^id<DNTSetting>(DNTFeature *feature, YapDatabaseReadWriteTransaction *transaction) {

        if ( !feature ) {
            feature = [[DNTFeature alloc] initWithKey:@"feature.sync" title:@"New Sync" group:@"In Development"];
        }
        feature.title = @"New sync";
        feature.onByDefault = @NO;
        feature.debugOptionsAvailable = YES;

        [feature debugSettingWithKey:@"feature.sync.debug.verbose-logging" update:^id<DNTSetting>(DNTToggleSetting *toggle, YapDatabaseReadWriteTransaction *transaction) {

            if ( !toggle ) {
                toggle = [[DNTToggleSetting alloc] initWithKey:@"feature.sync.debug.verbose-logging" title:@"Verbose Logging" group:nil];
            }
            toggle.title = @"Verbose Logging";
            toggle.onByDefault = @NO;
            return toggle;

        } transaction:transaction];

        [feature debugSettingWithKey:@"feature.sync.debug.mode" update:^id<DNTSetting>(DNTSelectOptionSetting *select, YapDatabaseReadWriteTransaction *transaction) {

            if ( !select ) {
                select = [[DNTSelectOptionSetting alloc] initWithKey:@"feature.sync.debug.mode" title:@"Sync Mode" group:nil];
            }
            select.title = @"Sync Mode";
            select.optionKeys = @[ @"standard", @"advanced", @"magic" ];
            select.optionTitles = @[ @"Standard", @"Advanced", @"Magic" ];
            select.selectedIndexes = [NSMutableIndexSet indexSetWithIndex:0];
            select.multipleSelectionAllowed = NO;
            return select;

        } transaction:transaction];

        [feature debugSettingWithKey:@"feature.sync.debug.clear-cache" update:^id<DNTSetting>(DNTDebugSetting *debug, YapDatabaseReadWriteTransaction *transaction) {

            if ( !debug ) {
                debug = [[DNTDebugSetting alloc] initWithKey:@"feature.sync.debug.clear-cache" title:@"Clear Cache" group:nil];
            }
            debug.title = @"Clear Cache";
            debug.userInfo[@"special key"] = @"special value";
            debug.notificationName = @"ClearCacheNotification";
            return debug;

        } transaction:transaction];

        return feature;

    } completion:nil];

    // For demonstration purpose, listen for when settings change.
    [[NSNotificationCenter defaultCenter] addObserverForName:DNTSettingsDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        id <DNTSetting> setting = note.userInfo[DNTSettingsNotificationSettingKey];
        NSLog(@"%@%@", note.name, setting ? [NSString stringWithFormat:@", %@", setting] : nil);
    }];

    // For demonstration purpose, listen for when settings change.
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ClearCacheNotification" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"%@ userInfo: %@", note.name, note.userInfo ?: @"none");
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.bonusContent.hidden = ![[[DNTFeature service] featureWithKey:@"feature.bonus"] isOn];
    DNTFeature *sync = [[DNTFeature service] featureWithKey:@"feature.sync"];
    self.syncButton.hidden = ![sync isOn];
    DNTSelectOptionSetting *debugMode = [sync debugSettings][@"feature.sync.debug.mode"];
    NSString *debugModeTitle = debugMode.optionTitles[[debugMode.selectedIndexes firstIndex]];
    NSString *title = [NSString stringWithFormat:@"Sync using %@ method.", debugModeTitle];
    [self.syncButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)segue { }

@end
