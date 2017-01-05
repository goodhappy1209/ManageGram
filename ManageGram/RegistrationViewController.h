//
//  UIViewController+RegistrationViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/10/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitioningViewController.h"
#import "CustomTransitionController.h"

@interface RegistrationViewController : CustomTransitioningViewController
{
    IBOutlet UITextField *edt_username;
    IBOutlet UITextField *edt_email;
    IBOutlet UITextField *edt_password;
    CGFloat _duration;
    CustomTransitionOrientation _orientation;
}

-(void)serverResponce:(NSArray*)respDict;
-(IBAction)btn_backClicked:(id)sender;
-(IBAction)btn_createUser:(id)sender;
-(IBAction)btn_signupWithFacebook:(id)sender;

@end
