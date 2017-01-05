//
//  NSObject+CustomDualTransition.m
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "CustomDualTransition.h"


@implementation CustomDualTransition

@synthesize inAnimation = _inAnimation;
@synthesize outAnimation = _outAnimation;

- (id)initWithInAnimation:(CAAnimation *)inAnimation andOutAnimation:(CAAnimation *)outAnimation {
    if (self = [self init]) {
        _inAnimation = inAnimation;
        _outAnimation = outAnimation;
        [self finishInit];
    }
    return self;
}

- (id)initWithDuration:(CFTimeInterval)duration {
    return nil;
}


- (void)finishInit {
    _delegate = nil;
    _inAnimation.delegate = self; // The delegate object is retained by the receiver. This is a rare exception to the memory management rules described in 'Memory Management Programming Guide'.
    [_inAnimation setValue:CustomTransitionAnimationInValue forKey:CustomTransitionAnimationKey]; // See 'Core Animation Extensions To Key-Value Coding' : "while the key “someKey” is not a declared property of the CALayer class, however you can still set a value for the key “someKey” "
    _outAnimation.delegate = self;
    [_outAnimation setValue:CustomTransitionAnimationOutValue forKey:CustomTransitionAnimationKey];
}

- (CustomTransition *)reverseTransition {
    CAAnimation * inAnimationCopy = [self.inAnimation copy];
    CAAnimation * outAnimationCopy = [self.outAnimation copy];
    CustomDualTransition * reversedTransition = [[CustomDualTransition alloc] initWithInAnimation:outAnimationCopy andOutAnimation:inAnimationCopy];
    reversedTransition.delegate = self.delegate; // Pointer assignment
    reversedTransition.inAnimation.speed = -1.0 * reversedTransition.inAnimation.speed;
    reversedTransition.outAnimation.speed = -1.0 * reversedTransition.outAnimation.speed;
    reversedTransition.type = CustomTransitionTypeNull;
    if (self.type == CustomTransitionTypePush) {
        reversedTransition.type = CustomTransitionTypePop;
    } else if (self.type == CustomTransitionTypePop) {
        reversedTransition.type = CustomTransitionTypePush;
    }
    return reversedTransition;
}

- (NSTimeInterval)duration {
    return MAX(self.inAnimation.duration, self.outAnimation.duration);
}

#pragma mark -
#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if ([[animation valueForKey:CustomTransitionAnimationKey] isEqualToString:CustomTransitionAnimationInValue])
    {
        [super animationDidStop:animation finished:flag];
    }
}

@end
