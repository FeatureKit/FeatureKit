//
//  DNTDebugSettingSelect+UITableViewDataSource.m
//  Pods
//
//  Created by Daniel Thorpe on 01/05/2014.
//
//

#import "DNTDebugSettingSelect+UITableViewDataSource.h"

@implementation DNTDebugSettingSelect (UITableViewDataSource)

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.optionTitles[indexPath.row];
    if ( [self.selectedIndexes containsIndex:indexPath.row] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

@end
