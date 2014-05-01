//
//  DNTDebugSettingSelect.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingSelect.h"

@implementation DNTDebugSettingSelect

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_optionTitles forKey:DNT_STRING(_optionTitles)];
    [aCoder encodeObject:_optionKeys forKey:DNT_STRING(_optionKeys)];
    [aCoder encodeObject:_selectedIndexes forKey:DNT_STRING(_selectedIndexes)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _selectedIndexes = [aDecoder decodeObjectForKey:DNT_STRING(_selectedIndexes)];
        _optionTitles = [aDecoder decodeObjectForKey:DNT_STRING(_optionTitles)];
        _optionKeys = [aDecoder decodeObjectForKey:DNT_STRING(_optionKeys)];
    }
    return self;
}

- (void)selectTitleAtIndex:(NSInteger)index completion:(void(^)(NSIndexSet *changedIndexes))completion {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    DNT_WEAK_SELF
    [[self class] updateDebugSettingWithKey:self.key update:^DNTDebugSettingSelect *(DNTDebugSettingSelect * debugSetting) {
        if ( [weakSelf.selectedIndexes containsIndex:index] ) {
            [weakSelf.selectedIndexes removeIndex:index];
            [indexes addIndex:index];
        }
        else {
            if ( !weakSelf.multipleSelectionAllowed ) {
                [indexes addIndexes:weakSelf.selectedIndexes];
                [weakSelf.selectedIndexes removeAllIndexes];
            }
            [weakSelf.selectedIndexes addIndex:index];
            [indexes addIndex:index];
        }
        return weakSelf;
    } completion:^{
        if (completion) completion(indexes);
    }];
}

@end
