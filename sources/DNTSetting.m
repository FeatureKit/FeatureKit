//
//  DNTSetting.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 04/05/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTSetting.h"
#import "DNTSettingsService.h"

@implementation DNTSetting

@synthesize key = _key;
@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize parentSettingKey = _parentSettingKey;
@synthesize group = _group;
@synthesize groupOrder = _groupOrder;
@synthesize editable = _editable;

+ (NSInteger)version {
    return 1;
}

+ (NSString *)collection {
    return @"dnt.settings";
}

- (id)initWithKey:(id)key title:(NSString *)title group:(NSString *)group {
    self = [super init];
    if (self) {
        _key = key;
        _title = title;
        _group = group;
        _identifier = nil;
        _parentSettingKey = nil;
        _groupOrder = @0;
        _userInfo = [NSMutableDictionary dictionary];
        _editable = YES;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@), %@, editable: %@", self.title, self.group ?: @"none", self.key, DNT_YESNO(self.editable)];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:[[self class] version] forKey:DNT_STRING(VERSION)];
    [aCoder encodeObject:_key forKey:DNT_STRING(_key)];
    [aCoder encodeObject:_identifier forKey:DNT_STRING(_identifier)];
    [aCoder encodeObject:_title forKey:DNT_STRING(_title)];
    [aCoder encodeObject:_parentSettingKey forKey:DNT_STRING(_parentSettingKey)];
    [aCoder encodeObject:_group forKey:DNT_STRING(_group)];
    [aCoder encodeObject:_groupOrder forKey:DNT_STRING(_groupOrder)];
    [aCoder encodeBool:_editable forKey:DNT_STRING(_editable)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger version = [aDecoder decodeIntegerForKey:DNT_STRING(VERSION)];
    if ( [[self class] version] < version ) {
        return nil;
    }
    self = [super init];
    if (self) {
        _key = [aDecoder decodeObjectForKey:DNT_STRING(_key)];
        _identifier = [aDecoder decodeObjectForKey:DNT_STRING(_identifier)];
        _title = [aDecoder decodeObjectForKey:DNT_STRING(_title)];
        _parentSettingKey = [aDecoder decodeObjectForKey:DNT_STRING(_parentSettingKey)];
        _group = [aDecoder decodeObjectForKey:DNT_STRING(_group)];
        _groupOrder = [aDecoder decodeObjectForKey:DNT_STRING(_groupOrder)];
        _userInfo = [aDecoder decodeObjectForKey:DNT_STRING(_userInfo)] ?: [NSMutableDictionary dictionary];
        _editable = [aDecoder decodeBoolForKey:DNT_STRING(_editable)];
    }
    return self;
}

#pragma mark - DNTSetting

+ (id <DNTSettingsService>)service {
    id <DNTSettingsService> service = [DNTSettingsService service];
    service.collection = [self collection];
    return service;
}

- (NSComparisonResult)compareWithOtherSetting:(id<DNTSetting>)setting {
    NSComparisonResult result = [self.identifier caseInsensitiveCompare:setting.identifier];
    if ( result == NSOrderedSame ) {
        result = [self.key caseInsensitiveCompare:setting.key];
    }
    return result;
}

- (BOOL)updateFromSetting:(id<DNTSetting>)setting {
    if ( [self.key isEqualToString:setting.key] ) {
        self.title = setting.title;
        self.group = setting.group;
        self.groupOrder = setting.groupOrder;
        self.identifier = setting.identifier;
        self.editable = setting.editable;
        return YES;
    }
    return NO;
}

@end
