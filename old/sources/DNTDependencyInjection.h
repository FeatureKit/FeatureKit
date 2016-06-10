//
//  DNTDependencyInjection.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 18/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//


@protocol DNTDependencyContainer <NSObject>
@end

@protocol DNTDependencyInjectionDestination <NSObject>

/**
 * @discussion Destination controllers must override
 * this method tp return a protocol which
 * extends DNTDependencyContainer, and defines the
 * dependencies for the controller.
 */
+ (Protocol *)expectedDependencyContainerInterface;

/**
 * @discussion Destination controllers will receive
 * this message after they have been initialized, and
 * before viewDidLoad is called.
 * They are responsible for configuring their own
 * dependencies received from the container.
 */
- (void)injectDependenciesFromContainer:(id <DNTDependencyContainer>)container;

@end

@protocol DNTDependencyInjectionSource <NSObject>

/**
 * @discussion Controllers which have segues to controllers
 * which have dependencies must implement this method to
 * return the expected container. Typically, they would need
 * to check the protocol kind.
 */
- (id <DNTDependencyContainer>)dependencyContainerForProtocol:(Protocol *)protocol sender:(id)sender;

@end

/// @name Functions
extern BOOL DNTProtocolIsEqual(Protocol *a, Protocol *b);
