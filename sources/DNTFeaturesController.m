//
//  DNTFeaturesController.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeaturesController.h"

#import "DNTFeature.h"
#import "DNTFeaturesDataProvider.h"
#import "DNTToggleCell.h"

#import "DNTDebugSettingsControllerDependencies.h"

#define ONOFF(onoff) onoff ? NSLocalizedString(@"On", nil) : NSLocalizedString(@"Off", nil)

@interface DNTFeaturesController ( /* Private */ )

@property (nonatomic, weak) YapDatabase *database;

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

    [[NSNotificationCenter defaultCenter] addObserverForName:DNTFeaturesDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"Received notification: %@, feature: %@", note.name, note.userInfo[DNTFeaturesNotificationFeatureKey]);
    }];
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
    self.dataProvider = [[DNTFeaturesDataProvider alloc] initWithDatabase:[DNTFeature database] collection:[DNTFeature collection]];
    self.dataProvider.cellConfiguration = [self tableViewCellConfiguration];
    self.dataProvider.headerTitleConfiguration = [self tableViewHeaderTitleConfiguration];
    self.dataProvider.tableView = self.tableView;
    self.tableView.dataSource = self.dataProvider;
}

#pragma mark - Table View Configuration

- (DNTTableViewCellConfiguration)tableViewCellConfiguration {
    return ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, DNTFeature *feature) {
        UITableViewCell *cell = nil;
        if ( [feature hasDebugOptions] ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.textLabel.text = feature.title;
            cell.detailTextLabel.text = ONOFF([feature isOn]);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            DNTToggleCell *toggleCell = (DNTToggleCell *)cell;
            toggleCell.textLabel.text = feature.title;
            toggleCell.toggle.enabled = feature.editable;
            toggleCell.toggle.on = [feature isOn];
            [toggleCell.toggle addTarget:self action:@selector(toggleFeature:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView bringSubviewToFront:toggleCell.toggle];
        }
        return cell;
    };
}

- (DNTTableViewHeaderTitleConfiguration)tableViewHeaderTitleConfiguration {
    return ^ NSString *(UITableView *tableView, NSInteger section, DNTFeature *feature) {
        return feature.group;
    };
}

#pragma mark - UITableViewDelegate

#pragma mark - Actions

- (IBAction)toggleFeature:(UISwitch *)sender {
    CGPoint center = [sender.superview convertPoint:sender.frame.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
    DNTFeature *feature = [self.dataProvider objectAtIndexPath:indexPath];
    [feature switchOnOrOff:sender.on];
}

#pragma mark - BSUIDependencyInjectionSource

- (id <BSUIDependencyContainer>)dependencyContainerForProtocol:(Protocol *)protocol sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
    if ( BSUIProtocolIsEqual(protocol, @protocol(DNTDebugSettingsControllerDependencies)) ) {
        DNTDebugSettingsControllerDependencies *container = [[DNTDebugSettingsControllerDependencies alloc] init];
        container.feature = [self.dataProvider objectAtIndexPath:indexPath];
        return container;
    }
}

@end
