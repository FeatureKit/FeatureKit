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

    DNTFeature *bonus = [[DNTFeature alloc] initWithKey:@"feature.bonus" title:@"Show bonus content" group:@"Application Features"];
    bonus.title = @"Show bonus content";
    bonus.onByDefault = @NO;

    [[DNTFeature service] loadDefaultFeatures:@[ bonus ]];

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
