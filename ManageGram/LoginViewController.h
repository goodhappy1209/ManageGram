//
//  UIViewController+LoginViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/10/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitioningViewController.h"
#import "CustomTransitionController.h"

@interface LoginViewController : CustomTransitioningViewController
{
    IBOutlet UITextField *edt_username;
    IBOutlet UITextField *edt_password;
    CGFloat _duration;
    CustomTransitionOrientation _orientation;
}

-(void)serverResponce:(NSArray*)respDict;

-(IBAction)btn_loginClicked:(id)sender;
-(IBAction)btn_loginWithFacebookClicked:(id)sender;
-(IBAction)btn_backClicked:(id)sender;

@end
