//
//  DNTPlaceholderViewController.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 18/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStoryboardSegue+DNTPlaceholders.h"

@interface DNTPlaceholderViewController : UIViewController <DNTStoryboardViewController>

@property (nonatomic, strong) NSString *storyboardName;
@property (nonatomic, strong) NSString *storyboardIdentifier;

@end
