//
//  UIViewController+CustomNavigationControllerDelegate.m
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "CustomNavigationControllerDelegate.h"
#import "CustomTransitioningDelegate.h"

@implementation CustomNavigationControllerDelegate

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    if ([animationController respondsToSelector:@selector(startInteractiveTransition:)]) {
        return (id <UIViewControllerInteractiveTransitioning>)animationController;
    }
    return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    switch (operation) {
        case UINavigationControllerOperationPush:
            if ([toVC.transitioningDelegate respondsToSelector:@selector(animationControllerForPresentedController:presentingController:sourceController:)]) {
                CustomTransitioningDelegate * delegate = (CustomTransitioningDelegate *)toVC.transitioningDelegate;
                delegate.transition.type = CustomTransitionTypePush;
                return delegate;
            } else {
                return nil;
            }
        case UINavigationControllerOperationPop:
            if ([fromVC.transitioningDelegate respondsToSelector:@selector(animationControllerForDismissedController:)]){
                CustomTransitioningDelegate * delegate = (CustomTransitioningDelegate *)fromVC.transitioningDelegate;
                delegate.transition.type = CustomTransitionTypePop;
                return delegate;
            } else {
                return nil;
            }
        default:
            return nil;
    }
}
@end
