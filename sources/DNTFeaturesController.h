//
//  DNTFeaturesController.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 25/04/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSUIViewControllerDependencyInjection.h"

@interface DNTFeaturesController : UITableViewController <BSUIDependencyInjectionSource>

/// @name Actions
- (IBAction)resetFeatures:(id)sender;

@end
