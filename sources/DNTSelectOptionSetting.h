//
//  DNTSelectOptionSetting.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSetting.h"

@interface DNTSelectOptionSetting : DNTSetting

@property (nonatomic, strong) NSArray *optionTitles;
@property (nonatomic, strong) NSArray *optionKeys;
@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
@property (nonatomic, getter = isMultipleSelectionAllowed) BOOL multipleSelectionAllowed;

- (void)selectTitleAtIndex:(NSInteger)index completion:(void(^)(NSIndexSet *changedIndexes))completion;

@end
