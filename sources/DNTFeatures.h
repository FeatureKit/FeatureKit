//
//  DNTFeatures.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNTFeature.h"
#import "DNTFeaturesController.h"

@interface DNTFeatures : NSObject

+ (void)loadWithDatabaseNamed:(NSString *)databaseName;

+ (NSString *)version;

@end
