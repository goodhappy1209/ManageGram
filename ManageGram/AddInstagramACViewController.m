//
//  UIViewController+AddInstagramACViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/10/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "AddInstagramACViewController.h"
#import "HomeViewController.h"
#import "InstagramAuthViewController.h"
#import "InstagramClient.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SVProgressHUD.h"
#import "CustomTransition.h"
#import "CustomDualTransition.h"
#import "CustomTransformTransition.h"
#import "CustomFlipTransition.h"

@interface AddInstagramACViewController (Private)
- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController:(CustomTransitioningViewController*)viewController;
@end

@interface AddInstagramACViewController() <UITextFieldDelegate>

@property(nonatomic, strong) InstagramAuthViewController *instaAuthView;
@property(nonatomic, strong) AppDelegate *appDelegate;
@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, assign) int accounts_created_count;
@end

@implementation AddInstagramACViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.accounts_created_count = 0;
}

-(void)dealloc
{
    
}

-(IBAction)btn_backClicked:(id)sender
{

}

-(IBAction)btn_skipClicked:(id)sender
{
    if(self.accounts_created_count > 0)
    {
        CustomDualTransition *transition = [[CustomFlipTransition alloc] initWithDuration: 0.7f orientation:_orientation sourceRect: self.view.frame];
        HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier: @"homeView"];
        [self _pushViewControllerWithTransition: transition nextViewController:homeView];
    }
    else
    {
        [self showMessage: @"You need to add at least one Instagram account so that you can use the ManageGram app." withTitle: @"Warning"];
    }
}

-(IBAction)btn_addClicked:(id)sender
{
    
//    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString: @"https://instagram.com/"]];
//    
//    for (NSHTTPCookie* cookie in instagramCookies) {
//        [cookies deleteCookie:cookie];
//    }
    
    NSURL *url = [NSURL URLWithString:@"https://instagram.com/"];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSEnumerator *enumerator = [[cookieStorage cookiesForURL:url] objectEnumerator];
    NSHTTPCookie *cookie = nil;
    while ((cookie = [enumerator nextObject])) {
        [cookieStorage deleteCookie:cookie];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SVProgressHUD showWithStatus: @"Signup with Instagram..."];
    self.instaAuthView = [[InstagramAuthViewController alloc] init];
    self.instaAuthView.instagramAuthDelegate = self;
    [self.instaAuthView.view setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self presentViewController: self.instaAuthView animated: NO completion: nil];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self contentViewMoveUp: self.view];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self contentViewMoveDown: self.view];
    return YES;
}

-(void)viewMoveUp:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:textField cache:YES];
    [textField setFrame: CGRectMake(10, 70, textField.frame.size.width,textField.frame.size.height)];
    [UIView commitAnimations];
}
-(void)viewMoveDown:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:textField cache:YES];
    [textField setFrame: CGRectMake(10, 85, textField.frame.size.width,textField.frame.size.height)];
    [UIView commitAnimations];
}

-(void)contentViewMoveUp:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:view cache:YES];
    [view setFrame: CGRectMake(0, -65, view.frame.size.width,view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)contentViewMoveDown:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:view cache:YES];
    [view setFrame: CGRectMake(0, 0, view.frame.size.width,view.frame.size.height)];
    [UIView commitAnimations];
}


- (void)instagramAuthLoadFailed:(NSError *)error
{
    [SVProgressHUD dismiss];
    [self showMessage: @"Failed in authentication to Instagram." withTitle: @"Warning"];
    [self.instaAuthView dismissViewControllerAnimated: NO completion: nil];
    
}


- (void)instagramAuthSucceeded:(NSString *)token
{
    [SVProgressHUD dismiss];
    [self.instaAuthView dismissViewControllerAnimated: NO completion: nil];
    
    self.appDelegate.lastaccessToken = token;
    [self.appDelegate.accessTokenArray addObject: token];
    
    [[NSUserDefaults standardUserDefaults] setObject: token forKey: @"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    InstagramClient *instagramClient = [InstagramClient clientWithToken: token];
    [instagramClient getUser: @"self" success:^(InstagramUser *user) {
        
        NSLog(@"User name: %@", user.username);
        NSLog(@"User Fullname: %@", user.fullname);
        NSLog(@"User Profile Picture URL:%@", user.profilePictureUrl);
        [self.appDelegate callURL: manageInstaUser action: [NSString stringWithFormat: @"action=reg_user&username=%@&password=%@&insta_username=%@&accessToken=%@&insta_userfullname=%@&insta_userprofilepictureurl=%@", self.appDelegate.userName, self.appDelegate.userPassword, user.username, token, user.fullname, user.profilePictureUrl] delegate: self];

    } failure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"%@", [error userInfo]);
    }];
}


- (void)instagramAuthFailed:(NSString *)error
                errorReason:(NSString *)errorReason
           errorDescription:(NSString *)errorMessage
{
    [SVProgressHUD dismiss];
    [self showMessage: @"Failed in authentication to Instagram." withTitle: @"Warning"];
    [self.instaAuthView dismissViewControllerAnimated: NO completion: nil];
    
}


-(void)serverResponce:(NSArray*)respDict
{
    if(respDict)
    {
        NSString *info = [respDict valueForKey: @"info"];
        NSString *result = [respDict valueForKey: @"result"];
        NSString *request = [respDict valueForKey: @"request"];
        NSLog(@"Result:%@", result);
        NSLog(@"Info:%@", info);
        NSLog(@"Request:%@", request);
        
        if([result isEqual: @"success"])
        {
            [self showMessage: @"Congratulation! Your Instagram account has successfully been registered. If you want to register another, click the button again." withTitle: @"ManageGram"];
            self.accounts_created_count ++;
        }
        else
        {
            [self showMessage: [NSString stringWithFormat: @"%@", info] withTitle: @"Warning"];
        }
    }
    
}


-(void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
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

@implementation AddInstagramACViewController (Private)

- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController: (CustomTransitioningViewController*)viewController{
    
    if (SYSTEM_VERSION_GREATER_THAN_7) {
        viewController.transition = transition;
        //        [self.navigationController pushViewController:viewController animated: YES];
        [self presentViewController: viewController animated: YES completion: nil];
    } else {
        [self.transitionController pushViewController:viewController withTransition:transition];
    }
}
@end

