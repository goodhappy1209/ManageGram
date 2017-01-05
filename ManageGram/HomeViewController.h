//
//  UIViewController+HomeViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/11/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitioningViewController.h"
#import "CustomTransitionController.h"

@interface HomeViewController : CustomTransitioningViewController
{
    IBOutlet UIButton *btn_menu;
    IBOutlet UIButton *btn_search;
    IBOutlet UIView *top_view;
    CGFloat _duration;
    CustomTransitionOrientation _orientation;

}

-(IBAction)btn_menuClicked:(id)sender;
-(IBAction)btn_searchClicked:(id)sender;

-(void)serverResponce:(NSArray*)respDict;

@end
