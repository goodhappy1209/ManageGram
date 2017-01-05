//
//  UIViewController+CustomTransitionController.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CustomTransitionController.h"
#import "CustomTransition.h"
#import "CustomDualTransition.h"
#import "CustomTransformTransition.h"

@interface CustomTransitionView : UIView

@end

@protocol CustomTransitionControllerDelegate;

@interface CustomTransitionController : UIViewController <CustomTransitionDelegate, UINavigationBarDelegate, UIToolbarDelegate> {
    NSMutableArray *  _viewControllers;
    NSMutableArray *  _transitions; // Transition stack, paired with the view controller stack
    BOOL              _isContainerViewTransitioning;
    BOOL              _isNavigationBarTransitioning;
    UINavigationBar * _navigationBar;
    UIToolbar *       _toolbar;
    UIView *          _containerView;
}

@property (nonatomic, copy) NSMutableArray * viewControllers;
@property (nonatomic, readonly, strong) UIViewController * topViewController;
@property (nonatomic, readonly, strong) UIViewController * visibleViewController;
@property(nonatomic, readonly) UINavigationBar * navigationBar;
@property (nonatomic, readonly) UIToolbar * toolbar;
@property (nonatomic, weak) id<CustomTransitionControllerDelegate> delegate;
@property(nonatomic, getter = isNavigationBarHidden, setter = setNavigationBarHidden:) BOOL navigationBarHidden;
@property(nonatomic, getter = isToolbarHidden, setter = setToolbarHidden:) BOOL toolbarHidden;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController withTransition:(CustomTransition *)transition;
- (UIViewController *)popViewController;
- (UIViewController *)popViewControllerWithTransition:(CustomTransition *)transition;
- (NSArray *)popToViewController:(UIViewController *)viewController;
- (NSArray *)popToViewController:(UIViewController *)viewController withTransition:(CustomTransition *)transition ;
- (NSArray *)popToRootViewController;
- (NSArray *)popToRootViewControllerWithTransition:(CustomTransition *)transition;
@end

@protocol CustomTransitionControllerDelegate <NSObject>
- (void)transitionController:(CustomTransitionController *)transitionController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)transitionController:(CustomTransitionController *)transitionController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end