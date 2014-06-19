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

+ (NSString *)version {
    return [NSString stringWithFormat:@"%.0lf", (CGFloat)[DNTFeature version]];
}

@end
