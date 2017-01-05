//
//  ViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/9/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitioningViewController.h"
#import "CustomTransitionController.h"


@interface ViewController : CustomTransitioningViewController
{
    IBOutletCollection(UIImageView) NSMutableArray* imageArray;
    CGFloat _duration;
    CustomTransitionOrientation _orientation;

}

-(IBAction)btn_loginClicked:(id)sender;
-(IBAction)btn_getStartedClicked:(id)sender;

-(void)serverResponce:(NSArray*)respDict;

@end

