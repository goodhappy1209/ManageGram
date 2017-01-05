//
//  UIViewController+SettingsViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/16/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "SettingsViewController.h"
#import "AsyncImageView.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface SettingsViewController() <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,strong) AppDelegate *appDelegate;
@property(nonatomic,strong) NSMutableArray *activedUsers;
@property(nonatomic,strong) NSMutableArray *deactivedUsers;

@end

@implementation SettingsViewController

-(void)viewDidLoad
{
    self.appDelegate = [UIApplication sharedApplication].delegate;
//    [settingsTable setBackgroundColor: [UIColor grayColor]];
//    [titleLabel setBackgroundColor: [UIColor grayColor]];
    NSNumber *feedCycle = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
    if(feedCycle == nil)
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: 5] forKey: @"feedCycle"];

}

-(void)dealloc
{
    
}

-(IBAction)btn_backClicked:(id)sender
{
    NSString *activeUsers = @"";
    NSString *deactiveUsers = @"";
    for(int i = 0; i < [self.appDelegate.instaAccounts count]; i ++)
    {
        NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: i];
        NSString *active = [dict valueForKey: @"active"];
        NSString *insta_username = [dict valueForKey: @"insta_username"];
        if([active isEqualToString: @"1"])
        {
            activeUsers = [activeUsers stringByAppendingString: insta_username];
            activeUsers = [activeUsers stringByAppendingString: @"!~@bouncer"];
        }
        else
        {
            deactiveUsers = [deactiveUsers stringByAppendingString: insta_username];
            deactiveUsers = [deactiveUsers stringByAppendingString: @"!~@bouncer"];
        }
    }
    if(![activeUsers isEqual: @""])
        activeUsers = [activeUsers substringToIndex: activeUsers.length - 10];
    else
    {
        [self showMessage: @"You should select at least one account." withTitle: @"Warning"];
        return;
    }
    if(![deactiveUsers isEqual: @""])
        deactiveUsers = [deactiveUsers substringToIndex: deactiveUsers.length - 10];
    

    [self.appDelegate callURL: manageInstaUser action: [NSString stringWithFormat: @"action=set_users_status&username=%@&password=%@&active_users=%@&deactive_users=%@", self.appDelegate.userName, self.appDelegate.userPassword, activeUsers, deactiveUsers] delegate: self];
    
//    [self dismissViewControllerAnimated: NO completion: nil];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return [self.appDelegate.instaAccounts count];
    }
    else
    {
        return 3;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.frame.size.width, 50)];
    [view setBackgroundColor: [UIColor grayColor]];
    if(section == 0)
    {
        UILabel *titleLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 150, 30)];
        [titleLabel1 setText: @"Feed Accounts"];
        [titleLabel1 setTextColor: [UIColor whiteColor]];
        [view addSubview: titleLabel1];
        return view;
    }
    else if(section == 1)
    {
        UILabel *titleLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 150, 30)];
        [titleLabel1 setText: @"Feed Cycle"];
        [titleLabel1 setTextColor: [UIColor whiteColor]];
        [view addSubview: titleLabel1];
        return view;
    }
    else
        return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"accountCell"];
        NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: indexPath.row];
        NSString *insta_username = [dict valueForKey: @"insta_username"];
        NSString *insta_fullname = [dict valueForKey: @"insta_userfullname"];
        NSString *profilepictureurl = [dict valueForKey: @"insta_userprofilepictureurl"];
        NSString *active = [dict valueForKey: @"active"];
        AsyncImageView *profileImg = [[AsyncImageView alloc] initWithFrame: CGRectMake(30, 10, 30, 30)];
        profileImg.layer.cornerRadius = 15;
        profileImg.layer.masksToBounds = YES;

        UILabel *fullnameLabel = [[UILabel alloc] initWithFrame: CGRectMake(75, 7, 250, 20)];
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake(75, 25, 250, 20)];
        UIButton *btn_select = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width-50, 12, 25, 25)];
        [btn_select setImage: [UIImage imageNamed: @"ic_check_out.png"] forState: UIControlStateNormal];
        [btn_select setImage: [UIImage imageNamed: @"ic_check_in.png"] forState: UIControlStateSelected];
        [btn_select addTarget: self action: @selector(btn_selectClickedForAccount:) forControlEvents: UIControlEventTouchUpInside];
        btn_select.tag = indexPath.row;
        [fullnameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 13.0]];
        [usernameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 13.0]];
        [fullnameLabel setText: insta_fullname];
        [usernameLabel setText: insta_username];
        profileImg.imageURL = [NSURL URLWithString: profilepictureurl];
        [cell addSubview: profileImg];
        [cell addSubview: fullnameLabel];
        [cell addSubview: usernameLabel];
        [cell addSubview: btn_select];
        if([active isEqual: @"1"])
            [btn_select setSelected: true];
        else
            [btn_select setSelected: false];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;
        
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        
        if(indexPath.row == 0)
        {
            UILabel *item1 = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, tableView.frame.size.width-30,25)];
            [item1 setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [item1 setText: @"5 status for each account."];
            UIButton *btn_select = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width-50, 12, 25, 25)];
            [btn_select setImage: [UIImage imageNamed: @"ic_check_in.png"] forState: UIControlStateSelected];
            [btn_select setImage: [UIImage imageNamed: @"ic_check_out.png"] forState: UIControlStateNormal];
            btn_select.tag = indexPath.row;
            [cell addSubview: item1];
            [cell addSubview: btn_select];
            NSNumber *feedCycle = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
            NSInteger feedCycleVal = [feedCycle integerValue];
            if(feedCycleVal == 5)
                [btn_select setSelected: true];
            else
                [btn_select setSelected: false];
            
        }
        else if(indexPath.row == 1)
        {
            UILabel *item1 = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, tableView.frame.size.width-30,25)];
            [item1 setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [item1 setText: @"10 status for each account."];
            UIButton *btn_select = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width-50, 10, 25, 25)];
            [btn_select setImage: [UIImage imageNamed: @"ic_check_in.png"] forState: UIControlStateSelected];
            [btn_select setImage: [UIImage imageNamed: @"ic_check_out.png"] forState: UIControlStateNormal];
            btn_select.tag = indexPath.row;
            [cell addSubview: item1];
            [cell addSubview: btn_select];
            NSNumber *feedCycle = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
            NSInteger feedCycleVal = [feedCycle integerValue];
            if(feedCycleVal == 10)
                [btn_select setSelected: true];
            else
                [btn_select setSelected: false];

        }
        else
        {
            UILabel *item1 = [[UILabel alloc] initWithFrame: CGRectMake(30, 10, tableView.frame.size.width-30,25)];
            [item1 setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
            [item1 setText: @"20 status for each account."];
            UIButton *btn_select = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width-50, 10, 25, 25)];
            [btn_select setImage: [UIImage imageNamed: @"ic_check_in.png"] forState: UIControlStateSelected];
            [btn_select setImage: [UIImage imageNamed: @"ic_check_out.png"] forState: UIControlStateNormal];
            btn_select.tag = indexPath.row;
            [cell addSubview: item1];
            [cell addSubview: btn_select];
            NSNumber *feedCycle = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
            NSInteger feedCycleVal = [feedCycle integerValue];
            if(feedCycleVal == 20)
                [btn_select setSelected: true];
            else
                [btn_select setSelected: false];

        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;
    }
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        
        NSInteger selected = indexPath.row;
        NSMutableDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: selected];
        NSString *active = [dict valueForKey: @"active"];
        if([active isEqual: @"1"])
            [dict setObject: @"0" forKey: @"active"];
        else
            [dict setObject: @"1" forKey: @"active"];
        [tableView reloadData];
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: 5] forKey: @"feedCycle"];
            [settingsTable reloadData];

        }
        else if(indexPath.row == 1)
        {
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: 10] forKey: @"feedCycle"];
            [settingsTable reloadData];

        }
        else if(indexPath.row == 2)
        {
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: 20] forKey: @"feedCycle"];
            [settingsTable reloadData];
        }
    }
}

-(void)btn_selectClickedForAccount:(id)sender
{
}


-(void)serverResponce:(NSArray*)respDict
{
    if(respDict)
    {
        NSString *info = [respDict valueForKey: @"info"];
        NSString *result = [respDict valueForKey: @"result"];
        NSString *request = [respDict valueForKey: @"request"];
        NSString *type = [respDict valueForKey: @"type"];
        if([result isEqual: @"success"])
        {
            if([type isEqual: @"setactive"])
            {
                [self dismissViewControllerAnimated: YES completion: nil];
            }
        }
        else
        {
            [self showMessage: [NSString stringWithFormat: @"Failed in saving settings. %@", info] withTitle: @"Warning"];
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
