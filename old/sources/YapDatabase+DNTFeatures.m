//
//  YapDatabase+DNTFeatures.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "YapDatabase+DNTFeatures.h"

@implementation YapDatabase (DNTFeatures)

+ (NSString *)pathForDatabaseWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *component = [NSString stringWithFormat:@"%@.sqlite", name];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:component];
    return path;
}

@end
