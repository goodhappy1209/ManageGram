//
//  UIViewController+CustomTransitionController.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitionController.h"

@class CustomTransitionController;

@interface UIViewController (CustomTransitionController)

- (CustomTransitionController *)transitionController;

@end
