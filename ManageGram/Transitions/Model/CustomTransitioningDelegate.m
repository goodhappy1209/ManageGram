//
//  NSObject+TransitionDelegate.m
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "CustomTransitioningDelegate.h"
#import "CustomTransitionController.h"

#define AD_Z_DISTANCE 1000.0f

@interface CustomTransitioningDelegate () {
    id<UIViewControllerContextTransitioning> _currentTransitioningContext;
}

@end

@interface CustomTransitioningDelegate (Private)
- (void)_setupLayers:(NSArray *)layers;
- (void)_teardownLayers:(NSArray *)layers;
- (void)_completeTransition;
- (void)_transitionInContainerView:(UIView *)containerView fromView:(UIView *)viewOut toView:(UIView *)viewIn withTransition:(CustomTransition *)transition;
@end

@implementation CustomTransitioningDelegate
@synthesize transition = _transition;

- (id)initWithTransition:(CustomTransition *)transition {
    self = [self init];
    if (self) {
        _transition = transition;
        _transition.delegate = self;
    }
    return self;
}

#pragma mark - CustomTransitionDelegate
- (void)pushTransitionDidFinish:(CustomTransition *)transition {
    [self _completeTransition];
}

- (void)popTransitionDidFinish:(CustomTransition *)transition {
    [self _completeTransition];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _currentTransitioningContext = transitionContext;
    UIViewController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.transition.type == CustomTransitionTypeNull) {
        self.transition.type = CustomTransitionTypePush;
    }
    
    UIView * containerView = transitionContext.containerView;
    UIView * fromView = fromViewController.view;
    UIView * toView = toViewController.view;
    
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = 1.0 / -AD_Z_DISTANCE;
    containerView.layer.sublayerTransform = sublayerTransform;
    
    UIView * wrapperView = [[CustomTransitionView alloc] initWithFrame:fromView.frame];
    fromView.frame = fromView.bounds;
    toView.frame = toView.bounds;
    
    wrapperView.autoresizesSubviews = YES;
    wrapperView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [wrapperView addSubview:fromView];
    [wrapperView addSubview:toView];
    [containerView addSubview:wrapperView];
    
    CustomTransition * transition = nil;
    switch (self.transition.type) {
        case CustomTransitionTypePush:
            transition = self.transition;
            break;
        case CustomTransitionTypePop:
            transition = self.transition.reverseTransition;
            transition.type = CustomTransitionTypePop;
        default:
            break;
    }
    transition.delegate = self;
    [self _transitionInContainerView:wrapperView fromView:fromView toView:toView withTransition:transition];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transition.duration;
}
@end

@implementation CustomTransitioningDelegate (Private)
- (void)_transitionInContainerView:(UIView *)containerView fromView:(UIView *)viewOut toView:(UIView *)viewIn withTransition:(CustomTransition *)transition {
    viewIn.layer.doubleSided = NO;
    viewOut.layer.doubleSided = NO;
    
    [self _setupLayers:@[viewIn.layer, viewOut.layer]];
    [CATransaction setCompletionBlock:^{
        [self _teardownLayers:@[viewIn.layer, viewOut.layer]];
        viewIn.layer.transform = CATransform3DIdentity;
        viewOut.layer.transform = CATransform3DIdentity;
        containerView.layer.transform = CATransform3DIdentity;
        
        UIView * contextView = [_currentTransitioningContext containerView];
        viewOut.frame = containerView.frame;
        [contextView addSubview:viewOut];
        viewIn.frame = containerView.frame;
        [contextView addSubview:viewIn];
//        [containerView removeFromSuperview];
    }];
    
    if ([transition isKindOfClass:[CustomTransformTransition class]]) { // CustomTransformTransition
        CustomTransformTransition * transformTransition = (CustomTransformTransition *)transition;
        viewIn.layer.transform = transformTransition.inLayerTransform;
        viewOut.layer.transform = transformTransition.outLayerTransform;
        
        // We now balance viewIn.layer.transform by taking its invert and putting it in the superlayer of viewIn.layer
        // so that viewIn.layer appears ok in the final state.
        // (When pushing, viewIn.layer.transform == CATransform3DIdentity)
        containerView.layer.transform = CATransform3DInvert(viewIn.layer.transform);
        
        [containerView.layer addAnimation:transformTransition.animation forKey:nil];
    } else if ([transition isKindOfClass:[CustomDualTransition class]]) { // ADDualTransition
        CustomDualTransition * dualTransition = (CustomDualTransition *)transition;
        [viewIn.layer addAnimation:dualTransition.inAnimation forKey:nil];
        [viewOut.layer addAnimation:dualTransition.outAnimation forKey:nil];
    } else if (transition != nil) {
        NSAssert(FALSE, @"Unhandled CustomTransition subclass!");
    }
}

- (void)_setupLayers:(NSArray *)layers {
    for (CALayer * layer in layers) {
        layer.shouldRasterize = YES;
        layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
}

- (void)_teardownLayers:(NSArray *)layers {
    for (CALayer * layer in layers) {
        layer.shouldRasterize = NO;
    }
}

- (void)_completeTransition {
    UIView * containerView = _currentTransitioningContext.containerView;
    CATransform3D sublayerTransform = CATransform3DIdentity;
    containerView.layer.sublayerTransform = sublayerTransform;
    
    [_currentTransitioningContext completeTransition:YES];
    _currentTransitioningContext = nil;
}

@end
