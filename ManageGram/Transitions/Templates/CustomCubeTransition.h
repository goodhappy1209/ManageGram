//
//  ADCubeTransition.h
//  AppLibrary
//
//  Created by Patrick Nollet on 14/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomTransformTransition.h"

@interface CustomCubeTransition : CustomTransformTransition
- (id)initWithDuration:(CFTimeInterval)duration orientation:(CustomTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
@end
