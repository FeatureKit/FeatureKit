//
//  DNTDebugSettingSelectOptionsController.h
//  Pods
//
//  Created by Daniel Thorpe on 01/05/2014.
//
//

#import <UIKit/UIKit.h>
#import "DNTDependencyInjection.h"

@class DNTSelectOptionSetting;

@interface DNTDebugSettingSelectOptionsController : UITableViewController <DNTDependencyInjectionDestination>
@property (nonatomic, strong) DNTSelectOptionSetting *select;
@end
