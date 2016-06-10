//
//  DNTDebugSettingSelectOptionsControllerDependencies.h
//  Pods
//
//  Created by Daniel Thorpe on 01/05/2014.
//
//

#import <Foundation/Foundation.h>
#import "DNTDependencyInjection.h"

@class DNTSelectOptionSetting;

@protocol DNTDebugSettingSelectOptionsControllerDependencies <DNTDependencyContainer>
@property (nonatomic, strong) DNTSelectOptionSetting *select;
@end

@interface DNTDebugSettingSelectOptionsControllerDependencies : NSObject <DNTDebugSettingSelectOptionsControllerDependencies>
@end
