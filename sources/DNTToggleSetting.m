//
//  DNTToggleSetting.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTToggleSetting.h"

@implementation DNTToggleSetting

- (id)initWithKey:(id)key title:(NSString *)title group:(NSString *)group {
    self = [super initWithKey:key title:title group:group];
    if (self) {
        _onByDefault = @NO;
        _on = @NO;
    }
    return self;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@", default: %@, currently: %@", DNT_YESNO(self.onByDefault), DNT_YESNO([self isOn])];
}

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

- (BOOL)isOnByDefault {
    return [self.onByDefault boolValue];
}

- (BOOL)isOn {
    return self.on ? [self.on boolValue] : [self.onByDefault boolValue];
}

- (BOOL)isToggled {
    return [self isOn] != [self isOnByDefault];
}

- (BOOL)updateFromSetting:(DNTToggleSetting *)setting {
    if ( [super updateFromSetting:setting] ) {
        self.onByDefault = setting.onByDefault;
        self.on = setting.on;
        return YES;
    }
    return NO;
}

@end
