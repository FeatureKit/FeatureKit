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

//+ (void)loadWithDatabaseNamed:(NSString *)databaseName {
//    NSString *path = [YapDatabase pathForDatabaseWithName:databaseName];
//    YapDatabase *database = [[YapDatabase alloc] initWithPath:path];
//    [DNTFeature setDefaultDatabase:database collection:nil];
//}
//
//+ (void)updateFeatures:(NSArray *)features completion:(void(^)(void))completion {
//    YapDatabaseConnection *connection = [[DNTFeature database] newConnection];
//    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
//        for ( DNTFeature *feature in features ) {
//            [DNTFeature featureWithKey:feature.key update:^DNTFeature *(DNTFeature *existing, YapDatabaseReadWriteTransaction *transaction) {
//                [feature updateFromExistingFeature:existing];
//                return feature;
//            } collection:[DNTFeature collection] transaction:transaction];
//        }
//    } completionBlock:^{
//        if (completion) completion();
//    }];
//}

+ (NSString *)version {
    return [NSString stringWithFormat:@"%.0lf", (CGFloat)[DNTFeature version]];
}

@end
