//
//  NSObject+CustomTransformTransition.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomTransition.h"

@interface CustomTransformTransition : CustomTransition
{
    CATransform3D _inLayerTransform;
    CATransform3D _outLayerTransform;
    CAAnimation *_animation;
}

@property(readonly) CATransform3D inLayerTransform;
@property(readonly) CATransform3D outLayerTransform;
@property(readonly) CAAnimation* animation;

- (id)initWithAnimation:(CAAnimation *)animation inLayerTransform:(CATransform3D)inTransform outLayerTransform:(CATransform3D)outTransform;
- (id)initWithDuration:(CFTimeInterval)duration;
- (id)initWithDuration:(CFTimeInterval)duration sourceRect:(CGRect)sourceRect;

@end
