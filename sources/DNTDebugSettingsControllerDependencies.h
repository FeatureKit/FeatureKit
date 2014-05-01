//
//  DNTDebugSettingsControllerDependencies.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 30/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BSPlatform/BSUIViewControllerDependencyInjection.h>

@class DNTFeature;

@protocol DNTDebugSettingsControllerDependencies <BSUIDependencyContainer>
@property (nonatomic, strong) DNTFeature *feature;
@end

@interface DNTDebugSettingsControllerDependencies : NSObject <DNTDebugSettingsControllerDependencies>
@end
