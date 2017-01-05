//
//  UIViewController+CustomTransitionController.m
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "UIViewController+CustomTransitionController.h"
#import <objc/runtime.h>

extern NSString * CustomTransitionControllerAssociationKey;

@implementation UIViewController (CustomTransitionController)

- (CustomTransitionController *)transitionController {
    return (CustomTransitionController *)objc_getAssociatedObject(self, (__bridge const void *)(CustomTransitionControllerAssociationKey));
    
}

@end
