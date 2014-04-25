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

@interface DNTFeaturesController ( /* Private */ )

@property (nonatomic, weak) YapDatabase *database;

- (void)configureDataProvider;

@end

@implementation DNTFeaturesController

+ (instancetype)controller {
    return [[self alloc] initWithNibName:@"DNTFeaturesController" bundle:nil];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"DNTToggleCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.dataSource = self.dataProvider;
}

#pragma mark - Table View Configuration

- (DNTTableViewCellConfiguration)tableViewCellConfiguration {
    return ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath, DNTFeature *feature) {
        DNTToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = feature.title;
        cell.toggle.enabled = feature.editable;
        cell.toggle.on = [feature isOn];
        [cell.toggle addTarget:self action:@selector(toggleFeature:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryType = [feature isToggled] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        [cell.contentView bringSubviewToFront:cell.toggle];
        return cell;
    };
}

- (DNTTableViewHeaderTitleConfiguration)tableViewHeaderTitleConfiguration {
    return ^ NSString *(UITableView *tableView, NSInteger section, DNTFeature *feature) {
        return feature.group;
    };
}

#pragma mark - Actions

- (IBAction)toggleFeature:(UISwitch *)sender {
    CGPoint center = [sender.superview convertPoint:sender.frame.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
    DNTFeature *feature = [self.dataProvider objectAtIndexPath:indexPath];
    [feature switchOnOrOff:sender.on];
}

@end
