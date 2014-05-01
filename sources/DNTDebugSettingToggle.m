//
//  DNTDebugSettingToggle.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSettingToggle.h"

@implementation DNTDebugSettingToggle

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_onByDefault forKey:DNT_STRING(_onByDefault)];
    [aCoder encodeObject:_on forKey:DNT_STRING(_on)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _onByDefault = [aDecoder decodeObjectForKey:DNT_STRING(_onByDefault)];
        _on = [aDecoder decodeObjectForKey:DNT_STRING(_on)];
    }
    return self;
}

- (BOOL)isOn {
    return self.on ? [self.on boolValue] : [self.onByDefault boolValue];
}

@end
