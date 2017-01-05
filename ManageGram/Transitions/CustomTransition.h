//
//  NSObject+CustomTransition.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CoreAnimation.h>

@class CustomTransition;

extern NSString * CustomTransitionAnimationKey;
extern NSString * CustomTransitionAnimationInValue;
extern NSString * CustomTransitionAnimationOutValue;

@protocol CustomTransitionDelegate

@optional
- (void)pushTransitionDidFinish:(CustomTransition *)transition;
- (void)popTransitionDidFinish:(CustomTransition *)transition;
@end

typedef enum {
    CustomTransitionTypeNull,
    CustomTransitionTypePush,
    CustomTransitionTypePop
} CustomTransitionType;

typedef enum {
    CustomTransitionRightToLeft,
    CustomTransitionLeftToRight,
    CustomTransitionTopToBottom,
    CustomTransitionBottomToTop
} CustomTransitionOrientation;

@interface CustomTransition : NSObject
{
    id <CustomTransitionDelegate> __weak _delegate;
    CustomTransitionType _type;
}

@property (nonatomic, weak) id <CustomTransitionDelegate> delegate;
@property (nonatomic, assign) CustomTransitionType type;
@property (nonatomic, readonly) NSTimeInterval duration; // abstract

+ (CustomTransition *)nullTransition;
- (CustomTransition *)reverseTransition;
- (NSArray *)getCircleApproximationTimingFunctions;

@end
