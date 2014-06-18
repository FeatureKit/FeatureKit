//
//  UIStoryboardSegue+DNTPlaceholders.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 18/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "UIStoryboardSegue+DNTPlaceholders.h"

#import <objc/runtime.h>
#import "DNTPlaceholderViewController.h"

@implementation UIStoryboardSegue (BSExternalStoryboard)

+ (void)load {
    // Swizzle
    SEL original = @selector(initWithIdentifier:source:destination:);
    SEL alternative = @selector(dnt_initWithIdentifier:source:destination:);
    method_exchangeImplementations(class_getInstanceMethod(self, original), class_getInstanceMethod(self, alternative));
}

- (instancetype)dnt_initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    
    if ( ![destination conformsToProtocol:@protocol(DNTStoryboardViewController)] ) {
        return [self dnt_initWithIdentifier:identifier source:source destination:destination];
    }
    
    UIViewController <DNTStoryboardViewController> *placeholder = (UIViewController <DNTStoryboardViewController> *)destination;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[placeholder storyboardName] bundle:[NSBundle bundleForClass:[DNTPlaceholderViewController class]]];
    NSAssert(storyboard, @"The storyboard must exist.");
    UIViewController *viewController = nil;
    NSString *destinationIdentifier = [placeholder respondsToSelector:@selector(storyboardIdentifier)] ? [placeholder storyboardIdentifier] : nil;
    if ( destinationIdentifier ) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:destinationIdentifier];
    }
    else {
        viewController = [storyboard instantiateInitialViewController];
    }
    NSAssert(viewController, @"The view controller must created.");
    return [self dnt_initWithIdentifier:identifier source:source destination:viewController];
}

@end
