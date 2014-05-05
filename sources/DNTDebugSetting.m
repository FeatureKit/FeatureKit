//
//  DNTDebugSetting.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>

#import "DNTDebugSetting.h"

@implementation DNTDebugSetting

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_featureKey forKey:DNT_STRING(_featureKey)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _featureKey = [aDecoder decodeObjectForKey:DNT_STRING(_featureKey)];
    }
    return self;
}

@end
