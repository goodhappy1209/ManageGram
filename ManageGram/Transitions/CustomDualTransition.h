//
//  NSObject+CustomDualTransition.h
//  TransitionDemo
//
//  Created by YangGuo on 10/23/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomTransition.h"

@interface CustomDualTransition : CustomTransition
{
    CAAnimation * _inAnimation;
    CAAnimation * _outAnimation;
}

@property(nonatomic, readonly) CAAnimation *inAnimation;
@property(nonatomic, readonly) CAAnimation *outAnimation;

- (id)initWithDuration:(CFTimeInterval)duration;
- (id)initWithInAnimation:(CAAnimation *)inAnimation andOutAnimation:(CAAnimation *)outAnimation;
- (void)finishInit;

@end
