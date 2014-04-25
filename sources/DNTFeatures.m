//
//  DNTFeatures.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "DNTFeatures.h"

#import "YapDatabase+DNTFeatures.h"

@implementation DNTFeatures

+ (void)loadWithDatabaseNamed:(NSString *)databaseName {
    NSString *path = [YapDatabase pathForDatabaseWithName:databaseName];
    YapDatabase *database = [[YapDatabase alloc] initWithPath:path];
    [DNTFeature setDefaultDatabase:database collection:nil];
}

+ (NSString *)version {
    return [NSString stringWithFormat:@"%.0lf", (CGFloat)[DNTFeature version]];
}

@end
