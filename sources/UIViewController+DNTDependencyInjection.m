//
//  UIViewController+DNTDependencyInjection.m
//  DNTFeatures
//
//  Created by Daniel Thorpe on 18/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import "UIViewController+DNTDependencyInjection.h"
#import "DNTDependencyInjection.h"
#import <objc/runtime.h>

inline BOOL DNTProtocolIsEqual(Protocol *a, Protocol *b) {
    return protocol_isEqual(a, b);
}

static Protocol * DNTDependencyContainerProtocol;
static Protocol * DNTDependencyInjectionDestinationProtocol;
static Protocol * DNTDependencyInjectionSourceProtocol;

@implementation UIViewController (DNTDependencyInjection)

+ (void)load {
    SEL original = @selector(prepareForSegue:sender:);
    SEL alternative = @selector(dnt_prepareForSegue:sender:);
    method_exchangeImplementations(class_getInstanceMethod(self, original), class_getInstanceMethod(self, alternative));
    
    DNTDependencyContainerProtocol = @protocol(DNTDependencyContainer);
    DNTDependencyInjectionDestinationProtocol = @protocol(DNTDependencyInjectionDestination);
    DNTDependencyInjectionSourceProtocol = @protocol(DNTDependencyInjectionSource);
}

#pragma mark - Storyboards

- (void)dnt_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destination = nil;
    
    if ( [segue.destinationViewController isKindOfClass:[UINavigationController class]] ) {
        destination = [(UINavigationController *)segue.destinationViewController topViewController];
    }
    else {
        destination = segue.destinationViewController;
    }
        
    if ( [self conformsToProtocol:DNTDependencyInjectionSourceProtocol] &&
        [destination conformsToProtocol:DNTDependencyInjectionDestinationProtocol] ) {
        
        [self injectDependenciesFromSource:(UIViewController <DNTDependencyInjectionSource> *)self
                             toDestination:(UIViewController <DNTDependencyInjectionDestination> *)destination
                                    sender:sender];
    }
}

- (void)injectDependenciesFromSource:(UIViewController <DNTDependencyInjectionSource> *)source toDestination:(UIViewController <DNTDependencyInjectionDestination> *)destination sender:(id)sender {
    
    Protocol *containerInterface = [[destination class] expectedDependencyContainerInterface];
    
    if ( !DNTProtocolIsEqual(containerInterface, DNTDependencyContainerProtocol) &&
        protocol_conformsToProtocol(containerInterface, DNTDependencyContainerProtocol)) {
        
        id <DNTDependencyContainer> container = [source dependencyContainerForProtocol:containerInterface sender:sender];
        if ( !container || ![container conformsToProtocol:containerInterface] ) {
            [NSException raise:NSInternalInconsistencyException format:@"Dependency injection container %@ does not conform to expected protocol %@ for destination controller: %@", container, NSStringFromProtocol(containerInterface), NSStringFromClass([destination class])];
        }
        else {
            [destination injectDependenciesFromContainer:container];
        }
    }
}


@end
