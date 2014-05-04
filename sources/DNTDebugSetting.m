//
//  DNTDebugSetting.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTDebugSetting.h"

#import "DNTFeatures.h"

@implementation DNTDebugSetting

- (id)initWithSetting:(id <DNTSetting>)setting {
    self = [super init];
    if (self) {
        _setting = setting;
        _featureKey = nil;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_setting forKey:DNT_STRING(_setting)];
    [aCoder encodeObject:_featureKey forKey:DNT_STRING(_featureKey)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _setting = [aDecoder decodeObjectForKey:DNT_STRING(_setting)];
        _featureKey = [aDecoder decodeObjectForKey:DNT_STRING(_featureKey)];
    }
    return self;
}

@end

@implementation DNTFeature ( DNTDebugSetting )

- (void)debugSettingWithKey:(id)key update:(DNTDebugSettingUpdateBlock)update transaction:(YapDatabaseReadWriteTransaction *)transaction {

}

@end
