//
//  AppDelegate.m
//  ManageGram
//
//  Created by YangGuo on 10/9/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "RegistrationViewController.h"
#import "AddInstagramACViewController.h"
#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "MyProfileViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [UIApplication sharedApplication].statusBarHidden = YES;

    self.accessTokenArray = [NSMutableArray array];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    [FBAppCall handleDidBecomeActive];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    self.activatedAccounts = nil;
    self.instaAccounts = nil;
    self.selectedImageData = nil;
    self.selectedFileURL = nil;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
             
//     [FBSession.activeSession setStateChangeHandler:
//      ^(FBSession *session, FBSessionState state, NSError *error) {
//          
//          // Retrieve the app delegate
//          AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//          // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
//          [appDelegate sessionStateChanged:session state:state error:error];
//      }];
     return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];

}


-(void)callURL:(NSString*)postURL action:(NSString*)postStr delegate:(id)delegate
{
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",postURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:imgURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [request setURL:imgURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(data)
             {
                 NSLog(@"%@",response);
                 NSArray *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 [delegate serverResponce:resp];
             }
             else
             {
                 
             }
             
         }];
         
     }];
    
}

    
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
//        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        NSLog(@"Session closed");
//        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Warning";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }

        [FBSession.activeSession closeAndClearTokenInformation];

//        [self userLoggedOut];
    }
}

//-(void)userLoggedIn
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"kUserLoggedInWithFacebook" object: self userInfo: nil];
//}
//
//-(void)userLoggedOut
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"kUserLoggedOutWithFacebook" object: self userInfo: nil];
//}

-(void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

#pragma mark - Backgrounding Methods -
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}

@end

