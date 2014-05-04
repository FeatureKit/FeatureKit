//
//  DNTFeaturesController.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeaturesController.h"

#import "DNTFeaturesDataProvider.h"
#import "DNTFeature.h"

#import "DNTDebugSettingsControllerDependencies.h"

#define ONOFF(onoff) onoff ? NSLocalizedString(@"On", nil) : NSLocalizedString(@"Off", nil)

@interface DNTFeaturesController ( /* Private */ )

@property (nonatomic, strong) DNTFeaturesDataProvider *dataProvider;

- (void)configureDataProvider;

@end

@implementation DNTFeaturesController

#pragma mark - Storyboard Support

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Features~iphone" bundle:nil];
    self = [sb instantiateViewControllerWithIdentifier:@"dnt.features"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDataProvider];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    [self configureResetButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void)configureDataProvider {
    self.dataProvider = [[DNTFeaturesDataProvider alloc] initWithDatabase:[[DNTFeature service] database]];
    self.dataProvider.dataSource.tableView = self.tableView;
    self.tableView.dataSource = self.dataProvider.dataSource;
}

- (void)configureResetButton {
    UINavigationItem *navigationItem = self.parentViewController ? self.parentViewController.navigationItem : self.navigationItem;
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetFeatures:)];
}

#pragma mark - Actions

- (IBAction)toggleFeature:(UISwitch *)sender {
    CGPoint center = [sender.superview convertPoint:sender.frame.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
    DNTFeature *feature = [self.dataProvider.dataSource objectAtIndexPath:indexPath];
    [feature switchOnOrOff:sender.on];
}

- (IBAction)resetFeatures:(id)sender {
    [[DNTFeature service] resetToDefaults];
}

#pragma mark - BSUIDependencyInjectionSource

- (id <BSUIDependencyContainer>)dependencyContainerForProtocol:(Protocol *)protocol sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
    if ( BSUIProtocolIsEqual(protocol, @protocol(DNTDebugSettingsControllerDependencies)) ) {
        DNTDebugSettingsControllerDependencies *container = [[DNTDebugSettingsControllerDependencies alloc] init];
        container.feature = [self.dataProvider.dataSource objectAtIndexPath:indexPath];
        return container;
    }
    return nil;
}

@end
