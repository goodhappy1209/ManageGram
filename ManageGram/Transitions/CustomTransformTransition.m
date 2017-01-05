//
//  NSObject+CustomTransformTransition.m
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "CustomTransformTransition.h"

@interface CustomTransformTransition (Private)
- (void)_initCustomTransformTransitionTemplateCrossWithDuration:(CFTimeInterval)duration;
@end

@implementation CustomTransformTransition
@synthesize inLayerTransform = _inLayerTransform;
@synthesize outLayerTransform = _outLayerTransform;
@synthesize animation = _animation;

- (id)initWithAnimation:(CAAnimation *)animation inLayerTransform:(CATransform3D)inTransform outLayerTransform:(CATransform3D)outTransform {
    if (self = [super init]) {
        _animation = [animation copy]; // the instances should be different because we don't want them to have the same delegate
        _animation.delegate = self;
        _inLayerTransform = inTransform;
        _outLayerTransform = outTransform;
    }
    return self;
}

- (id)initWithDuration:(CFTimeInterval)duration {
    if (self = [super init]) {
        _inLayerTransform = CATransform3DIdentity;
        _outLayerTransform = CATransform3DIdentity;
    }
    return self;
}

- (id)initWithDuration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect {
    return [self initWithDuration:duration];
}

- (CustomTransition *)reverseTransition
{
    CustomTransformTransition * reversedTransition = [[CustomTransformTransition alloc] initWithAnimation:_animation inLayerTransform:_outLayerTransform outLayerTransform:_inLayerTransform];;
    reversedTransition.delegate = self.delegate; // Pointer assignment
    reversedTransition.animation.speed = - 1.0 * reversedTransition.animation.speed;
    reversedTransition.type = CustomTransitionTypeNull;
    if (self.type == CustomTransitionTypePush) {
        reversedTransition.type = CustomTransitionTypePop;
    } else if (self.type == CustomTransitionTypePop) {
        reversedTransition.type = CustomTransitionTypePush;
    }
    return reversedTransition;
}

- (NSTimeInterval)duration {
    return self.animation.duration;
}

@end