//
//  DNTDebugSettingsController.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingsController.h"
#import "DNTDebugSettingsControllerDependencies.h"
#import "DNTDebugSettingsDataProvider.h"
#import "DNTFeatures.h"

#import "DNTToggleCell.h"

@implementation DNTDebugSettingsController

#pragma mark - Storyboard Support

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Features~iphone" bundle:nil];
    self = [sb instantiateViewControllerWithIdentifier:@"dnt.features.debug-settings"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDataProvider];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void)configureDataProvider {
    self.dataProvider = [[DNTDebugSettingsDataProvider alloc] initWithDatabase:[DNTDebugSetting database] collection:[DNTDebugSetting collection]];
    self.dataProvider.cellConfiguration = [self tableViewCellConfiguration];
    self.dataProvider.headerTitleConfiguration = [self tableViewHeaderTitleConfiguration];
    self.dataProvider.tableView = self.tableView;
    self.tableView.dataSource = self.dataProvider;
}

#pragma mark - Table View Configuration

- (DNTTableViewCellConfiguration)tableViewCellConfiguration {
    DNT_WEAK_SELF
    return ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, DNTDebugSetting *setting) {
        if ( [setting isKindOfClass:[DNTDebugSettingToggle class]] ) {
            DNTDebugSettingToggle *toggle = (DNTDebugSettingToggle *)setting;
            DNTToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            cell.textLabel.text = toggle.title;
            cell.toggle.enabled = [weakSelf.feature isOn];
            cell.toggle.on = [toggle isOn];
            [cell.contentView bringSubviewToFront:cell.toggle];
            return cell;
        }
        return nil;
    };
}

- (DNTTableViewHeaderTitleConfiguration)tableViewHeaderTitleConfiguration {
    return ^ NSString *(UITableView *tableView, NSInteger section, DNTFeature *feature) {
        return feature.group;
    };
}

#pragma mark - BSUIDependencyInjectionDestination

+ (Protocol *)expectedDependencyContainerInterface {
    return @protocol(DNTDebugSettingsControllerDependencies);
}

- (void)injectDependenciesFromContainer:(id<DNTDebugSettingsControllerDependencies>)container {
    self.feature = container.feature;
}

@end
