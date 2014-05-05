//
//  DNTDebugSettingSelectOptionsControllerDependencies.h
//  Pods
//
//  Created by Daniel Thorpe on 01/05/2014.
//
//

#import <Foundation/Foundation.h>
#import "BSUIViewControllerDependencyInjection.h"

@class DNTSelectOptionSetting;

@protocol DNTDebugSettingSelectOptionsControllerDependencies <BSUIDependencyContainer>
@property (nonatomic, strong) DNTSelectOptionSetting *select;
@end

@interface DNTDebugSettingSelectOptionsControllerDependencies : NSObject <DNTDebugSettingSelectOptionsControllerDependencies>
@end
