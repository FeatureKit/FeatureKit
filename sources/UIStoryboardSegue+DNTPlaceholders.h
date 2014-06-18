//
//  UIStoryboardSegue+DNTPlaceholders.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 18/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DNTStoryboardViewController <NSObject>

- (NSString *)storyboardName;

@optional
- (NSString *)storyboardIdentifier;

@end

@interface UIStoryboardSegue (DNTPlaceholders)

- (instancetype)dnt_initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination;

@end
