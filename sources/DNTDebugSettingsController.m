//
//  DNTDebugSettingsController.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingsController.h"
#import "DNTDebugSettingsDataProvider.h"
#import "DNTFeatures.h"

#import "DNTToggleCell.h"

#import "DNTDebugSettingsControllerDependencies.h"
#import "DNTDebugSettingSelectOptionsControllerDependencies.h"

@implementation DNTDebugSettingsController

#pragma mark - Storyboard Support

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Features~iphone" bundle:nil];
    self = [sb instantiateViewControllerWithIdentifier:@"dnt.features.debug-settings"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ Settings", nil), self.feature.title];
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
    self.dataProvider = [[DNTDebugSettingsDataProvider alloc] initWithDatabase:[DNTDebugSetting database] collection:[DNTDebugSetting collection] feature:self.feature];
    self.dataProvider.cellConfiguration = [self tableViewCellConfiguration];
    self.dataProvider.headerTitleConfiguration = [self tableViewHeaderTitleConfiguration];
    self.dataProvider.tableView = self.tableView;
    self.tableView.dataSource = self.dataProvider;
}

#pragma mark - Table View Configuration

- (DNTTableViewCellConfiguration)tableViewCellConfiguration {
    DNT_WEAK_SELF
    return ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, id object) {

        if ( [object isKindOfClass:[DNTFeature class]] ) {
            return [weakSelf configuredCellWithFeature:(DNTFeature *)object inTableView:tableView atIndexPath:indexPath];
        } else if ( [object isKindOfClass:[DNTDebugSetting class]] ) {
            DNTDebugSetting *setting = (DNTDebugSetting *)object;
            if ( [setting isKindOfClass:[DNTDebugSettingToggle class]] ) {
                DNTDebugSettingToggle *toggle = (DNTDebugSettingToggle *)setting;
                return [weakSelf configuredCellWithToggleSetting:(DNTDebugSettingToggle *)setting inTableView:tableView atIndexPath:indexPath];
            }
            else if ( [setting isKindOfClass:[DNTDebugSettingSelect class]] ) {
                DNTDebugSettingSelect *select = (DNTDebugSettingSelect *)setting;
                return [weakSelf configuredCellWithSelectSetting:(DNTDebugSettingSelect *)setting inTableView:tableView atIndexPath:indexPath];
            }
        }
        return nil;
    };
}

- (UITableViewCell *)configuredCellWithFeature:(DNTFeature *)feature inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    DNTToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
    cell.textLabel.text = feature.title;
    cell.toggle.enabled = [feature isEditable];
    cell.toggle.on = [feature isOn];
    cell.toggle.tintColor = cell.toggle.onTintColor = [feature isToggled] ? [UIColor redColor] : nil;
    [cell.toggle addTarget:self action:@selector(toggleFeature:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView bringSubviewToFront:cell.toggle];
    return cell;
}

- (UITableViewCell *)configuredCellWithToggleSetting:(DNTDebugSettingToggle *)toggle inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    DNTToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
    cell.textLabel.text = toggle.title;
    cell.toggle.enabled = [self.dataProvider.feature isOn];
    cell.toggle.on = [toggle isOn];
    cell.toggle.tintColor = cell.toggle.onTintColor = nil;
    [cell.contentView bringSubviewToFront:cell.toggle];
    return cell;
}

- (UITableViewCell *)configuredCellWithSelectSetting:(DNTDebugSettingSelect *)select inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Select" forIndexPath:indexPath];
    cell.textLabel.text = select.title;
    if ( [select.selectedIndexes count] > 1 ) {
        cell.detailTextLabel.text = NSLocalizedString(@"Multiple", nil);
    }
    else {
            cell.detailTextLabel.text = select.optionTitles[[select.selectedIndexes firstIndex]];
    }
    return cell;
}

- (DNTTableViewHeaderTitleConfiguration)tableViewHeaderTitleConfiguration {
    return ^ NSString *(UITableView *tableView, NSInteger section, DNTDebugSetting *setting) {
        return setting.group ?: NSLocalizedString(@"Debug Settings", nil);
    };
}

#pragma mark - Actions

- (IBAction)toggleFeature:(UISwitch *)sender {
    CGPoint center = [sender.superview convertPoint:sender.frame.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
    DNTFeature *feature = [self.dataProvider objectAtIndexPath:indexPath];
    [feature switchOnOrOff:sender.on];
    self.feature = feature;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( [self.feature isOn] ) {
        id object = [self.dataProvider objectAtIndexPath:indexPath];
        if ( [object isKindOfClass:[DNTDebugSettingSelect class]] ) {
            [self performSegueWithIdentifier:@"pushSelectOptions" sender:object];
        }
    }
}

#pragma mark - BSUIDependencyInjectionDestination

+ (Protocol *)expectedDependencyContainerInterface {
    return @protocol(DNTDebugSettingsControllerDependencies);
}

- (void)injectDependenciesFromContainer:(id<DNTDebugSettingsControllerDependencies>)container {
    self.feature = container.feature;
}

#pragma mark - BSUIDependencyInjectionSource

- (id <BSUIDependencyContainer>)dependencyContainerForProtocol:(Protocol *)protocol sender:(id)sender {
    if ( BSUIProtocolIsEqual(protocol, @protocol(DNTDebugSettingSelectOptionsControllerDependencies)) ) {
        DNTDebugSettingSelectOptionsControllerDependencies *container = [[DNTDebugSettingSelectOptionsControllerDependencies alloc] init];
        container.select = (DNTDebugSettingSelect *)sender;
        return container;
    }
    return nil;
}

@end
