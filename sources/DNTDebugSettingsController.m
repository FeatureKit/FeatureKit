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
    self.dataProvider = [[DNTDebugSettingsDataProvider alloc] initWithDatabase:[[DNTSetting service] database] feature:self.feature];
    self.dataProvider.dataSource.tableView = self.tableView;
    self.tableView.dataSource = self.dataProvider.dataSource;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( [self.dataProvider.feature isOn] ) {
        id object = [self.dataProvider objectAtIndexPath:indexPath];
        if ( [object isKindOfClass:[DNTSelectOptionSetting class]] ) {
            [self performSegueWithIdentifier:@"pushSelectOptions" sender:object];
        }
    }
}

#pragma mark - Storyboards

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - DNTDependencyInjectionDestination

+ (Protocol *)expectedDependencyContainerInterface {
    return @protocol(DNTDebugSettingsControllerDependencies);
}

- (void)injectDependenciesFromContainer:(id<DNTDebugSettingsControllerDependencies>)container {
    self.feature = container.feature;
}

#pragma mark - DNTDependencyInjectionSource

- (id <DNTDependencyContainer>)dependencyContainerForProtocol:(Protocol *)protocol sender:(id)sender {
    if ( DNTProtocolIsEqual(protocol, @protocol(DNTDebugSettingSelectOptionsControllerDependencies)) ) {
        DNTDebugSettingSelectOptionsControllerDependencies *container = [[DNTDebugSettingSelectOptionsControllerDependencies alloc] init];
        container.select = (DNTSelectOptionSetting *)sender;
        return container;
    }
    return nil;
}

@end
