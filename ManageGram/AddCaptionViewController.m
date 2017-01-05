//
//  UIViewController+AddCaptionViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/21/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "AddCaptionViewController.h"
#import "AppDelegate.h"
#import "SelectAccountViewController.h"

@interface AddCaptionViewController()



@end


@implementation AddCaptionViewController : UIViewController

-(void)viewDidLoad
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [postImage setImage: [UIImage imageWithData: appDelegate.selectedImageData]];
}

-(void)dealloc
{
    
}

-(IBAction)btn_cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated: NO completion: nil];
}

-(IBAction)btn_nextClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject: captionTextView.text forKey: @"postCaption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    SelectAccountViewController *selectaccountView = [self.storyboard instantiateViewControllerWithIdentifier: @"selectaccountView"];
    [self presentViewController: selectaccountView animated: NO completion: nil];
}

-(void)didReceiveMemoryWarning
{
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return (UIInterfaceOrientationMaskPortrait);
}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
