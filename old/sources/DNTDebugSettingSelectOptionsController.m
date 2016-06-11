//
//  DNTDebugSettingSelectOptionsController.m
//  Pods
//
//  Created by Daniel Thorpe on 01/05/2014.
//
//

#import "DNTDebugSettingSelectOptionsController.h"
#import "DNTDebugSettingSelectOptionsControllerDependencies.h"
#import "DNTSelectOptionSetting+UITableViewDataSource.h"

@implementation DNTDebugSettingSelectOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.select.title;
    self.tableView.dataSource = self.select;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.select selectTitleAtIndex:indexPath.row completion:^(NSIndexSet *changedIndexes) {
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:changedIndexes.count];
        [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - BSUIDependencyInjectionDestination

+ (Protocol *)expectedDependencyContainerInterface {
    return @protocol(DNTDebugSettingSelectOptionsControllerDependencies);
}

- (void)injectDependenciesFromContainer:(id<DNTDebugSettingSelectOptionsControllerDependencies>)container {
    self.select = container.select;
}

@end
