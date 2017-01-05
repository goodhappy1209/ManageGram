//
//  UIViewController+SelectAccountViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/21/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "SelectAccountViewController.h"
#import "InstagramClient.h"
#import "AppDelegate.h"
#import "AccountCell.h"

@interface SelectAccountViewController() <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>

@property(nonatomic,strong) AppDelegate *appDelegate;

@property(nonatomic,strong) NSMutableArray *selectedAccounts;

@property(nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation SelectAccountViewController : UIViewController

-(void)viewDidLoad
{
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.selectedAccounts = [NSMutableArray array];
    
    for(int i = 0; i < [self.appDelegate.instaAccounts count]; i ++)
    {
        NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: i];
        NSString *active = [dict valueForKey: @"active"];
        NSString *username = [dict valueForKey: @"insta_username"];
        if([active isEqual: @"1"])
        {
            [self.selectedAccounts addObject: username];
        }
    }
}

-(void)dealloc
{
    self.appDelegate = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Cancel");
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"Yes");
        NSURL *url = [NSURL URLWithString:@"https://instagram.com/"];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSEnumerator *enumerator = [[cookieStorage cookiesForURL:url] objectEnumerator];
        NSHTTPCookie *cookie = nil;
        while ((cookie = [enumerator nextObject])) {
            [cookieStorage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        
        NSURL *logoutURL = [NSURL URLWithString: @"http://instagram.com/accounts/logout"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:logoutURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             
         }];
//
        

        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
        {
//            [[UIApplication sharedApplication] openURL:instagramURL];
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL: self.appDelegate.selectedFileURL];
            self.documentInteractionController.UTI = @"com.instagram.exclusivegram";
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        }
        
    }
    else
    {
        NSLog(@"Don't alert me");
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
        {
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.appDelegate.selectedFileURL];
            self.documentInteractionController.UTI = @"com.instagram.image";
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        }
    }
}

-(void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"Application: %@", @"OK");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSLog(@"Application: %@", application);
}

-(IBAction)btn_nextClicked:(id)sender
{
    if([self.selectedAccounts count] > 0)
    {
        NSLog(@"Good");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Post a Photo" message: @"As Instagram hasn't opened photo uploading feature to third-party apps yet, we need to launch offical Instagram app to post a photo." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Yes, let's go ahead", @"Don't alert me again", nil];
        [alertView show];
    }
    else
    {
        [self showMessage: @"No found selected account(s)" withTitle: @"Warning"];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.appDelegate.instaAccounts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"accountCell";
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *userDict = [self.appDelegate.instaAccounts objectAtIndex: indexPath.row];
    NSString *pictureUrl = [userDict valueForKey: @"insta_userprofilepictureurl"];
    NSString *fullname = [userDict valueForKey: @"insta_userfullname"];
    NSString *username = [userDict valueForKey: @"insta_username"];
    NSString *activate = [userDict valueForKey: @"active"];
    cell.profileImageView.imageURL = [NSURL URLWithString: pictureUrl];
    [cell.fullnameLabel setText: fullname];
    [cell.usernameLabel setText: username];
    cell.profileImageView.layer.masksToBounds = YES;
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    [cell.btn_check setFrame: CGRectMake(tableView.frame.size.width - 60, 5, cell.btn_check.frame.size.width, cell.btn_check.frame.size.height)];
    if([self.selectedAccounts containsObject: username])
    {
        [cell.btn_check setImage:[UIImage imageNamed: @"ic_check_in.png"] forState: UIControlStateNormal];
    }
    else
    {
        [cell.btn_check setImage:[UIImage new] forState: UIControlStateNormal];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    NSDictionary *userDict = [self.appDelegate.instaAccounts objectAtIndex: indexPath.row];
    NSString *username = [userDict valueForKey: @"insta_username"];
    if([self.selectedAccounts containsObject: username])
    {
        NSInteger index = [self.selectedAccounts indexOfObject: username];
        [self.selectedAccounts removeObjectAtIndex: index];
        [tableView reloadData];
    }
    else
    {
        [self.selectedAccounts addObject: username];
        [tableView reloadData];
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
