//
//  DNTFeaturesDataProvider.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <YapDatabase/YapDatabase.h>

@class DNTFeature;

typedef UITableViewCell *(^DNTTableViewCellConfiguration) (UITableView *tableView, NSIndexPath *indexPath, id object);
typedef NSString * (^DNTTableViewHeaderTitleConfiguration) (UITableView *tableView, NSInteger section, id firstObject);
typedef NSString * (^DNTTableViewFooterTitleConfiguration) (UITableView *tableView, NSInteger section);

@interface DNTFeaturesDataProvider : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) YapDatabase *database;
@property (nonatomic, strong, readonly) NSString *collection;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) DNTTableViewCellConfiguration cellConfiguration;
@property (nonatomic, copy) DNTTableViewHeaderTitleConfiguration headerTitleConfiguration;
@property (nonatomic, copy) DNTTableViewFooterTitleConfiguration footerTitleConfiguration;

+ (NSString *)databaseViewName;

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection;

- (DNTFeature *)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
