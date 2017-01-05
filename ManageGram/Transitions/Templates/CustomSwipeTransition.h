//
//  ADSwipeTransition.h
//  AppLibrary
//
//  Created by Patrick Nollet on 15/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomDualTransition.h"

@interface CustomSwipeTransition : CustomDualTransition
- (id)initWithDuration:(CFTimeInterval)duration orientation:(CustomTransitionOrientation)orientation sourceRect:(CGRect)sourceRect;
@end
