//
//  UIViewController+CustomTransitioningViewController.m
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "CustomTransitioningViewController.h"
#import "CustomTransitioningDelegate.h"

@interface CustomTransitioningViewController () {
    CustomTransitioningDelegate * _customTransitioningDelegate;
}

@end

@implementation CustomTransitioningViewController
@synthesize transition = _transition;

- (void)setTransitioningDelegate:(id <UIViewControllerTransitioningDelegate>)delegate {
    NSAssert(FALSE, @"This setter shouldn't be used! You should set the transition property instead.");
}

- (void)setTransition:(CustomTransition *)transition {
    _transition = transition;
    _customTransitioningDelegate = [[CustomTransitioningDelegate alloc] initWithTransition:transition];
    [super setTransitioningDelegate:_customTransitioningDelegate]; // don't call the setter of the current class
}
@end
