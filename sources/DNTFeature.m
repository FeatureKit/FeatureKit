//
//  DNTFeature.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeature.h"
#import "YapDatabase+DNTFeatures.h"

#define WEAK_SELF __weak __typeof(&*self)weakSelf = self;
#define STRING(value) (@#value)
#define YESNO(value) value ? @"YES" : @"NO"
#define PRETTY_METHOD NSStringFromSelector(_cmd)
#define VERSION 1

static YapDatabase *__database;
static NSString *__collection;

@interface DNTFeature ( /* Private */ )

@property (nonatomic, getter = isToggled, readwrite) BOOL toggled;

- (void)modify:(void(^)(DNTFeature *feature))modifications;

- (void)modify:(void(^)(DNTFeature *feature))modifications completion:(void(^)(void))completion inDatabase:(YapDatabase *)database collection:(NSString *)collection;

@end

@implementation DNTFeature

- (id)initWithKey:(id)key title:(NSString *)title group:(NSString *)group {
    self = [super init];
    if (self) {
        _key = key;
        _identifier = nil;
        _title = title;
        _parentFeatureKey = nil;
        _group = group;
        _groupOrder = @0;
        _userInfo = [NSMutableDictionary dictionary];

        _editable = YES;
        _onByDefault = YES;
        _on = YES;
        _toggled = NO;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Feature: (%@) %@, %@, editable: %@, default: %@, currently: %@", self.group ?: @"none", self.title, self.key, YESNO(self.editable), YESNO(self.onByDefault), YESNO([self isOn])];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:VERSION forKey:STRING(VERSION)];
    [aCoder encodeObject:_key forKey:STRING(_key)];
    [aCoder encodeObject:_identifier forKey:STRING(_identifier)];
    [aCoder encodeObject:_title forKey:STRING(_title)];
    [aCoder encodeObject:_parentFeatureKey forKey:STRING(_parentFeatureKey)];
    [aCoder encodeObject:_group forKey:STRING(_group)];
    [aCoder encodeObject:_groupOrder forKey:STRING(_groupOrder)];
    [aCoder encodeObject:_userInfo forKey:STRING(_userInfo)];
    [aCoder encodeBool:_editable forKey:STRING(_editable)];
    [aCoder encodeBool:_onByDefault forKey:STRING(_onByDefault)];
    [aCoder encodeBool:_on forKey:STRING(_on)];
    [aCoder encodeBool:_toggled forKey:STRING(_toggled)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSInteger version = [aDecoder decodeIntegerForKey:STRING(VERSION)];
    if ( VERSION < version ) {
        return nil;
    }
    self = [super init];
    if (self) {
        _key = [aDecoder decodeObjectForKey:STRING(_key)];
        _identifier = [aDecoder decodeObjectForKey:STRING(_identifier)];
        _title = [aDecoder decodeObjectForKey:STRING(_title)];
        _parentFeatureKey = [aDecoder decodeObjectForKey:STRING(_parentFeatureKey)];
        _group = [aDecoder decodeObjectForKey:STRING(_group)];
        _groupOrder = [aDecoder decodeObjectForKey:STRING(_groupOrder)];
        _userInfo = [aDecoder decodeObjectForKey:STRING(_userInfo)];
        _editable = [aDecoder decodeBoolForKey:STRING(_editable)];
        _onByDefault = [aDecoder decodeBoolForKey:STRING(_onByDefault)];
        _on = [aDecoder decodeBoolForKey:STRING(_on)];
        _toggled = [aDecoder decodeBoolForKey:STRING(_toggled)];
    }
    return self;
}

#pragma mark - Public API

- (void)switchOnOrOff:(BOOL)onOrOff {
    [self modify:^(DNTFeature *feature) {
        feature->_on = onOrOff;
    }];
}

- (NSComparisonResult)compareWithOtherFeature:(DNTFeature *)feature {
    NSComparisonResult result = [self.identifier caseInsensitiveCompare:feature.identifier];
    if ( result == NSOrderedSame ) {
        result = [self.key caseInsensitiveCompare:feature.key];
    }
    return result;
}

+ (instancetype)featureWithKey:(id)key {
    return [self featureWithKey:key inDatabase:[self database] collection:[self collection]];
}

+ (instancetype)featureWithKey:(id)key inDatabase:(YapDatabase *)database collection:(NSString *)collection {
    NSParameterAssert(key);
    __block DNTFeature *feature = nil;
    YapDatabaseConnection *connection = [database newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        feature = [transaction objectForKey:key inCollection:collection];
    }];
    return feature;
}

+ (void)switchFeatureWithKey:(id)key onOrOff:(BOOL)onOrOff {
    [self switchFeatureWithKey:key onOrOff:onOrOff inDatabase:[self database] collection:[self collection]];
}

+ (void)switchFeatureWithKey:(id)key onOrOff:(BOOL)onOrOff inDatabase:(YapDatabase *)database collection:(NSString *)collection {
    NSParameterAssert(key);
    YapDatabaseConnection *connection = [database newConnection];
    __block DNTFeature *feature = nil;
    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        feature = [transaction objectForKey:key inCollection:collection];
        feature->_on = onOrOff;
        [transaction setObject:feature forKey:key inCollection:collection];
    } completionBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DNTFeaturesDidChangeNotification object:nil userInfo:@{ DNTFeaturesNotificationFeatureKey : feature }];
    }];
}

#pragma mark - Private API

- (void)modify:(void(^)(DNTFeature *feature))modifications {
    [self modify:modifications completion:nil inDatabase:[[self class] database] collection:[[self class] collection]];
}

- (void)modify:(void(^)(DNTFeature *feature))modifications completion:(void(^)(void))completion inDatabase:(YapDatabase *)database collection:(NSString *)collection {
    modifications(self);
    YapDatabaseConnection *connection = [database newConnection];
    WEAK_SELF
    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        __strong DNTFeature *strongSelf = weakSelf;
        [transaction setObject:strongSelf forKey:strongSelf.key inCollection:collection];
    } completionBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DNTFeaturesDidChangeNotification object:weakSelf userInfo:@{ DNTFeaturesNotificationFeatureKey : weakSelf}];
        if (completion) completion();
    }];


}

#pragma mark - Persistence

+ (void)setDefaultDatabase:(YapDatabase *)database collection:(NSString *)collection {
    __database = database;
    __collection = collection;
}

+ (YapDatabase *)database {
    if ( !__database ) {
        __database = [[YapDatabase alloc] initWithPath:[YapDatabase pathForDatabaseWithName:@"Features"]];
    }
    return __database;
}

+ (NSString *)collection {
    if ( !__collection ) {
        __collection = @"features";
    }
    return __collection;
}


@end

#pragma mark - Constants
NSString * const DNTFeaturesDidChangeNotification = @"DNTFeaturesDidChangeNotificationName";
NSString * const DNTFeaturesNotificationFeatureKey = @"DNTFeaturesNotificationFeatureKey";
