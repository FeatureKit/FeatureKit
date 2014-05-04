//
//  DNTDebugSettingSelectOptionsController.h
//  Pods
//
//  Created by Daniel Thorpe on 01/05/2014.
//
//

#import <UIKit/UIKit.h>
#import "BSUIViewControllerDependencyInjection.h"

@class DNTSelectOptionSetting;

@interface DNTDebugSettingSelectOptionsController : UITableViewController <BSUIDependencyInjectionDestination>
@property (nonatomic, strong) DNTSelectOptionSetting *select;
@end
