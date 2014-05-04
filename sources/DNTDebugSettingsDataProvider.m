//
//  DNTDebugSettingsDataProvider.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingsDataProvider.h"
#import "DNTFeature.h"
#import "DNTDebugSetting.h"

#define VIEW_NAME @"debug-settings.view"

@implementation DNTDebugSettingsDataProvider

- (id)initWithDatabase:(YapDatabase *)database collection:(NSString *)collection feature:(DNTFeature *)feature {
    self = [super initWithDatabase:database collection:collection name:VIEW_NAME];
    if (self) {
        _feature = feature;
    }
    return self;
}

#pragma mark - Database View

- (YapDatabaseViewGroupingBlock)createDatabaseViewGroupingBlock {
    NSString *collection = self.collection;
    DNT_WEAK_SELF
    return ^NSString *(NSString *collectionName, NSString *key, id object) {
        NSString *group = nil;
        if ( [object isKindOfClass:[DNTFeature class]] && [((DNTFeature *)object).key isEqualToString:weakSelf.feature.key] ) {
            group = [NSString stringWithFormat:@"%d.%@", -1, NSLocalizedString(@"Feature", nil)];
        }
        else if ( [collectionName isEqualToString:collection] ) {
            DNTDebugSetting *debug = (DNTDebugSetting *)object;
            if ( (debug.featureKey.length > 0) && ![debug.featureKey isEqualToString:weakSelf.feature.key] ) {
                return nil;
            }
            group = [NSString stringWithFormat:@"%@.%@", debug.setting.groupOrder, debug.setting.group ?: NSLocalizedString(@"Debug Settings", nil)];
        }
        return group;
    };
}

- (YapDatabaseViewSortingBlock)createDatabaseViewSortingBlock {
    return ^ NSComparisonResult (NSString *group, NSString *collection1, NSString *key1, DNTDebugSetting *object1, NSString *collection2, NSString *key2, DNTDebugSetting *object2) {
        return [object1.setting compareWithOtherSetting:object2.setting];
    };
}

@end
