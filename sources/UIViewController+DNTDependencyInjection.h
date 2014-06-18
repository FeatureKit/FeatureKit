//
//  UIViewController+DNTDependencyInjection.h
//  DNTFeatures
//
//  Created by Daniel Thorpe on 18/06/2014.
//  Copyright (c) 2014 Daniel Thorpe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DNTDependencyInjection)

- (void)dnt_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
