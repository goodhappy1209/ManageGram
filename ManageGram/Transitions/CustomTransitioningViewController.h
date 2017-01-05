//
//  UIViewController+CustomTransitioningViewController.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransition.h"

@interface CustomTransitioningViewController : UIViewController

@property (nonatomic, strong) CustomTransition * transition;
@end
