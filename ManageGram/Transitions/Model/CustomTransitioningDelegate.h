//
//  NSObject+TransitionDelegate.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomTransition.h"
#import <UIKit/UIKit.h>

@interface CustomTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, CustomTransitionDelegate>

@property (nonatomic, strong) CustomTransition * transition;

- (id)initWithTransition:(CustomTransition *)transition;

@end
