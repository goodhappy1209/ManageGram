//
//  ADGlueTransition.h
//  ADTransitionController
//
//  Created by Pierre Felgines on 29/05/13.
//  Copyright (c) 2013 Applidium. All rights reserved.
//

#import "CustomDualTransition.h"
#import <UIKit/UIKit.h>

@interface CustomGlueTransition : CustomDualTransition
- (id)initWithDuration:(CFTimeInterval)duration orientation:(CustomTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
@end
