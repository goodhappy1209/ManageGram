//
//  UIViewController+LoginViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/10/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "HomeViewController.h"
#import "SVProgressHUD.h"
#import "CustomTransition.h"
#import "CustomDualTransition.h"
#import "CustomTransformTransition.h"
#import "CustomFlipTransition.h"

@interface LoginViewController (Private)
- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController:(CustomTransitioningViewController*)viewController;
@end

@interface LoginViewController() <UITextFieldDelegate>
{
    
}

@property(nonatomic,strong) AppDelegate *appDelegate;

@end

@implementation LoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [UIApplication sharedApplication].delegate;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [edt_password setText: @""];
    [edt_username setText: @""];
}
-(void)dealloc
{
    
}

-(void)didReceiveMemoryWarning
{
    
}

-(IBAction)btn_loginClicked:(id)sender
{
    [edt_username resignFirstResponder];
    [edt_password resignFirstResponder];
    NSString *username = edt_username.text;
    NSString *password = edt_password.text;
    if([username isEqual:@""]||[password isEqual: @""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Please input the fields." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
        [alertView show];
        return;
    }

    [self contentViewMoveDown: self.view];
    
    NSRange emailRange = NSMakeRange(0, username.length);
    NSRange foundRange = [username rangeOfString: @"@" options: 0 range:emailRange];
    if (foundRange.length > 0)
    {
        NSString *str = [username substringFromIndex: foundRange.location];
        if([str isEqual: @""])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"ManageGram" message: @"Please input the valid email address." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
            [alert show];
        }
        else
        {
            if(![password isEqual: @""])
            {
                [self.appDelegate callURL: loginLink action: [NSString stringWithFormat: @"username=%@&email=%@&password=%@", @"", username, password] delegate: self];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"ManageGram" message: @"Please input the password." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
                [alert show];
            }
        }
    }
    else
    {
        if(![password isEqual: @""])
        {
            [self.appDelegate callURL: loginLink action: [NSString stringWithFormat: @"username=%@&email=%@&password=%@", username, @"", password] delegate: self];
           
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"ManageGram" message: @"Please input the password." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
            [alert show];

        }
    }

    
}


-(IBAction)btn_loginWithFacebookClicked:(id)sender
{
    [SVProgressHUD showWithStatus: @"Login with Facebook..."];
    
    
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        //[FBSession.activeSession closeAndClearTokenInformation];
        
        NSLog(@"Session opened");
        
        NSLog(@"User logged in through Facebook!");
        FBAccessTokenData *tokenData = [[FBSession activeSession] accessTokenData];
        NSString* username = tokenData.accessToken;
        
        
        
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                
                NSLog(@"request did load successfully....");
                
                if ([result isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary* json = result;
                    NSLog(@"email id is %@",[json valueForKey:@"email"]);
                    NSLog(@"json is %@",json);
                    
                    NSString *uid = [json objectForKey: @"id"];
                    NSString *first_name = [json objectForKey:@"first_name"];
                    NSString *last_name = [json objectForKey:@"last_name"];
                    NSString *email = [json objectForKey:@"email"];
                    //                        NSString *gender = [json objectForKey: @"gender"];
                    NSString *locale = [json objectForKey: @"locale"];
                    
                    NSArray *locations = [locale componentsSeparatedByString: @"_"];
                    NSString *location;
                    if(locations.count > 1)
                    {
                        location = [locations objectAtIndex: 1];
                    }
                    else
                        location = [locations objectAtIndex: 0];
                    
                    NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: location forKey: NSLocaleCountryCode]];
                    //                        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
                    
                    self.appDelegate.userProfileImage = nil;
                    self.appDelegate.userEmail = email;
                    self.appDelegate.userFirstName = first_name;
                    self.appDelegate.userLastName = last_name;
                    //                        self.appDelegate.userGender = gender;
                    
                    NSString *url = [NSString stringWithFormat: @"http://graph.facebook.com/%@/picture?type=large", uid];
                    self.appDelegate.userProfileImageUrl = url;
                    
                    if(email == nil)
                        email = @"";
                    [self.appDelegate callURL: loginLink action: [NSString stringWithFormat: @"username=%@&email=%@&password=%@", username, @"", username] delegate: self];
                }
            }
            else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Facebook Authentication Failed." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
                [alertView show];
            }
            else
            {
                NSLog(@"Some other error: %@", error);
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Facebook Authentication Failed." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
                [alertView show];
            }
        }];
        
    }
    else
    {
        
        [FBSession openActiveSessionWithReadPermissions: @[@"public_profile", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             if (!error && state == FBSessionStateOpen){
                 
                 NSLog(@"Session opened");
                 
                 NSLog(@"User logged in through Facebook!");
                 FBAccessTokenData *tokenData = [session accessTokenData];
                 NSString* username = tokenData.accessToken;
                 self.appDelegate.loginType = LOGIN_WITH_FACEBOOK;
                 [SVProgressHUD dismiss];
                 
                 
                 FBRequest *request = [FBRequest requestForMe];
                 [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         
                         NSLog(@"request did load successfully....");
                         
                         if ([result isKindOfClass:[NSDictionary class]]) {
                             
                             NSDictionary* json = result;
                             NSLog(@"email id is %@",[json valueForKey:@"email"]);
                             NSLog(@"json is %@",json);
                             
                             NSString *uid = [json objectForKey: @"id"];
                             NSString *first_name = [json objectForKey:@"first_name"];
                             NSString *last_name = [json objectForKey:@"last_name"];
                             NSString *email = [json objectForKey:@"email"];
                             //                        NSString *gender = [json objectForKey: @"gender"];
                             NSString *locale = [json objectForKey: @"locale"];
                             
                             NSArray *locations = [locale componentsSeparatedByString: @"_"];
                             NSString *location;
                             if(locations.count > 1)
                             {
                                 location = [locations objectAtIndex: 1];
                             }
                             else
                                 location = [locations objectAtIndex: 0];
                             
                             NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: location forKey: NSLocaleCountryCode]];
                             //                        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
                             
                             self.appDelegate.userProfileImage = nil;
                             self.appDelegate.userEmail = email;
                             self.appDelegate.userFirstName = first_name;
                             self.appDelegate.userLastName = last_name;
                             //                        self.appDelegate.userGender = gender;
                             
                             NSString *url = [NSString stringWithFormat: @"http://graph.facebook.com/%@/picture?type=large", uid];
                             self.appDelegate.userProfileImageUrl = url;
                             
                             if(email == nil)
                                 email = @"";
                             [self.appDelegate callURL: loginLink action: [NSString stringWithFormat: @"username=%@&email=%@&password=%@", username, @"", username] delegate: self];
                         }
                     }
                     else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                         NSLog(@"The facebook session was invalidated");
                         [SVProgressHUD dismiss];
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Facebook Authentication Failed." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
                         [alertView show];
                     }
                     else
                     {
                         NSLog(@"Some other error: %@", error);
                         [SVProgressHUD dismiss];
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Facebook Authentication Failed." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
                         [alertView show];
                     }
                 }];
                 
                 return;
             }
             if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
                 NSLog(@"Session closed");
                 [SVProgressHUD dismiss];
             }
             
             if (error)
             {
                 NSLog(@"Error");
                 NSString *alertText;
                 NSString *alertTitle;
                 [SVProgressHUD dismiss];
                 
                 if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
                 {
                     alertTitle = @"Warning";
                     alertText = [FBErrorUtility userMessageForError:error];
                     [self showMessage:alertText withTitle: @"Warning"];
                 }
                 else
                 {
                     
                     if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
                     {
                         NSLog(@"User cancelled login");
                         [self showMessage: @"User cancelled login." withTitle: @"Warning"];
                     }
                     else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
                     {
                         alertTitle = @"Warning";
                         alertText = @"Authentication Failed. Please try again.";
                         [self showMessage:alertText withTitle:alertTitle];
                     }
                     else
                     {
                         NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                         
                         alertTitle = @"Warning";
                         alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                         [self showMessage:alertText withTitle:alertTitle];
                     }
                 }
                 
                 [FBSession.activeSession closeAndClearTokenInformation];
                 
             }
             
         }];
    }

}


-(IBAction)btn_backClicked:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

-(void)serverResponce:(NSArray*)respDict
{
    if(respDict)
    {
        NSString *info = [respDict valueForKey: @"info"];
        NSString *result = [respDict valueForKey: @"result"];
        NSString *request = [respDict valueForKey: @"request"];
        NSString *username = [respDict valueForKey: @"username"];
        NSString *email = [respDict valueForKey: @"email"];
        NSString *password = [respDict valueForKey: @"password"];
        self.appDelegate.userName = username;
        self.appDelegate.userEmail = email;
        self.appDelegate.userPassword = edt_password.text;
        NSLog(@"Result:%@", result);
        NSLog(@"Info:%@", info);
        NSLog(@"Request:%@", request);
        NSLog(@"Username:%@", username);
        NSLog(@"Email:%@", email);
        NSLog(@"Password:%@",password);
        if([result isEqual: @"success"])
        {
            CustomDualTransition *transition = [[CustomFlipTransition alloc] initWithDuration: 0.7f orientation:_orientation sourceRect: self.view.frame];
            HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier: @"homeView"];
            [self _pushViewControllerWithTransition: transition nextViewController:homeView];
//            [self presentViewController: homeView animated: NO completion: nil];
        }
        else
        {
            [self showMessage: [NSString stringWithFormat: @"User Login failed. %@", info] withTitle: @"Warning"];
        }
    }
    
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


-(void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
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


@implementation LoginViewController (Private)

- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController: (CustomTransitioningViewController*)viewController{
    
    if (SYSTEM_VERSION_GREATER_THAN_7) {
        viewController.transition = transition;
        [self presentViewController: viewController animated: YES completion: nil];
    } else {
        [self.transitionController pushViewController:viewController withTransition:transition];
    }
}
@end

