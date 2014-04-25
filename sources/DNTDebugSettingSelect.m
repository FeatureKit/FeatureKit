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
    [aCoder encodeObject:_selectOptions forKey:DNT_STRING(_selectOptions)];
    [aCoder encodeObject:_selection forKey:DNT_STRING(_selection)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _selectOptions = [aDecoder decodeObjectForKey:DNT_STRING(_selectOptions)];
        _selection = [aDecoder decodeObjectForKey:DNT_STRING(_selection)];
    }
    return self;
}

@end
