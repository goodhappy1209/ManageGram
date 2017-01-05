//
//  UIViewController+MyProfileViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/17/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "MyProfileViewController.h"
#import "AppDelegate.h"
#import "InstagramAuthViewController.h"
#import "InstagramClient.h"
#import "SVProgressHUD.h"
#import "Constants.h"

@interface MyProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,strong) AppDelegate *appDelegate;
@property(nonatomic, strong) InstagramAuthViewController *instaAuthView;

@end

@implementation MyProfileViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = [UIApplication sharedApplication].delegate;
    
    profileTable.delegate = self;
    profileTable.dataSource = self;
    
}

-(void)dealloc
{
    
}

-(IBAction)btn_backClicked:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 2;
    else
        return [self.appDelegate.instaAccounts count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.frame.size.width, 50)];
    [view setBackgroundColor: [UIColor grayColor]];
    if(section == 0)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, tableView.frame.size.width-20, 30)];
        [titleLabel setText: @"User Account"];
        [titleLabel setTextColor: [UIColor whiteColor]];
        [view addSubview: titleLabel];
        return view;
    }
    else
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, tableView.frame.size.width-20, 30)];
        [titleLabel setText: @"Instagram Accounts"];
        [titleLabel setTextColor: [UIColor whiteColor]];
        [titleLabel setBackgroundColor: [UIColor grayColor]];
        [view addSubview: titleLabel];
        return view;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {

        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"userInfoCell"];
        if(indexPath.row == 0)
        {
            UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, 90, 25)];
            UILabel *usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake(120, 10, tableView.frame.size.width-90, 25)];
            [label setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [label setText: @"Username:"];
            [usernameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [usernameLabel setText: self.appDelegate.userName];
            [cell addSubview: label];
            [cell addSubview: usernameLabel];
        }
        else if(indexPath.row == 1)
        {
            UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, 90, 25)];
            UILabel *emailLabel = [[UILabel alloc] initWithFrame: CGRectMake(120, 10, tableView.frame.size.width-30, 25)];
            [label setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [label setText: @"Email:"];
            [emailLabel setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [emailLabel setText: self.appDelegate.userEmail];
            [cell addSubview: label];
            [cell addSubview: emailLabel];
        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"instaCell"];
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"instaCell"];

        if(indexPath.row <= [self.appDelegate.instaAccounts count] - 1)
        {
            NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: indexPath.row];
            NSString *insta_username = [dict valueForKey: @"insta_username"];
            UILabel *insta_usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, tableView.frame.size.width-90, 25)];
            [insta_usernameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 13.0]];
            [insta_usernameLabel setText: insta_username];
            UIButton *btn_delete = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width-60, 10, 25, 25)];
            [btn_delete setImage: [UIImage imageNamed: @"btn_remove.png"] forState: UIControlStateNormal];
            [btn_delete addTarget: self action: @selector(btn_deleteAccountClicked:) forControlEvents: UIControlEventTouchUpInside];
            btn_delete.tag = indexPath.row;
            [cell addSubview: insta_usernameLabel];
            [cell addSubview: btn_delete];
        }
        else
        {
            UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, tableView.frame.size.width-90, 25)];
            [label setFont: [UIFont fontWithName: @"OpenSans" size: 13.0]];
            [label setText: @"Add new account"];
            UIButton *btn_addNew = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width-62, 7, 30, 30)];
            [btn_addNew setImage: [UIImage imageNamed: @"btn_add.png"] forState: UIControlStateNormal];
            [btn_addNew addTarget: self action: @selector(btn_addNewAccountClicked) forControlEvents: UIControlEventTouchUpInside];
            [cell addSubview: label];
            [cell addSubview: btn_addNew];
        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;

    }
    else
        return nil;
}

-(void)btn_addNewAccountClicked
{
    NSLog(@"%@", @"Add new account");
    
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

-(void)btn_deleteAccountClicked:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSLog(@"%ld", btn.tag);
    NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: btn.tag];
    NSString *insta_username = [dict valueForKey: @"insta_username"];
    [self.appDelegate callURL: manageInstaUser action: [NSString stringWithFormat: @"action=delete_user&username=%@&password=%@&insta_username=%@", self.appDelegate.userName, self.appDelegate.userPassword, insta_username] delegate: self];

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
        id et = [respDict valueForKey: @"info"];
        if([et isKindOfClass: [NSArray class]])
        {
            NSDictionary *dict = [respDict objectAtIndex: 0];
            NSString *info = [dict valueForKey: @"info"];
            NSString *result = [dict valueForKey: @"result"];
            NSString *request = [dict valueForKey: @"request"];
            NSString *type = [dict valueForKey: @"type"];
            NSLog(@"Result:%@", result);
            NSLog(@"Info:%@", info);
            NSLog(@"Request:%@", request);
            if([type isEqual: @"getall"])
            {
                self.appDelegate.instaAccounts = nil;
                self.appDelegate.instaAccounts = [NSMutableArray array];
                for(int i = 1; i < respDict.count; i ++)
                {
                    NSMutableDictionary *accountDict = [respDict objectAtIndex: i];
                    [self.appDelegate.instaAccounts addObject: accountDict];
                }
                
                if([self.appDelegate.instaAccounts count] > 0)
                    [profileTable reloadData];
            }

        }
        else
        {
            NSString *info = [respDict valueForKey: @"info"];
            NSString *result = [respDict valueForKey: @"result"];
            NSString *request = [respDict valueForKey: @"request"];
            NSString *type = [respDict valueForKey: @"type"];
            NSLog(@"Result:%@", result);
            NSLog(@"Info:%@", info);
            NSLog(@"Request:%@", request);
            
            if([type isEqual: @"registration"])
            {
                if([result isEqual: @"success"])
                {
                    [self.appDelegate callURL: manageInstaUser action: [NSString stringWithFormat: @"action=get_all&username=%@&password=%@", self.appDelegate.userName, self.appDelegate.userPassword] delegate: self];
                }
                else
                {
                    [self showMessage: [NSString stringWithFormat: @"%@", info] withTitle: @"Warning"];
                }
            }
            else if([type isEqual: @"getall"])
            {
                [self showMessage: [NSString stringWithFormat: @"%@", info] withTitle: @"Warning"];
            }
            else if([type isEqual: @"delete"])
            {
                NSString *deleted_username = [respDict valueForKey: @"deleted_user"];
                int foundIndex = -1;
                for(int i = 0; i < [self.appDelegate.instaAccounts count]; i ++)
                {
                    NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: i];
                    NSString *insta_username = [dict valueForKey: @"insta_username"];
                    if([insta_username isEqual: deleted_username])
                    {
                        foundIndex = i;
                        break;
                    }
                }
                if(foundIndex != -1)
                {
                    [self.appDelegate.instaAccounts removeObjectAtIndex: foundIndex];
                    [profileTable reloadData];
                }
            }
        }


    }
}


-(void)didReceiveMemoryWarning
{
    
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
