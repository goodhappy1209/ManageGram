//
//  UIViewController+HomeViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/11/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "MyProfileViewController.h"
#import "AppDelegate.h"
#import "InstagramClient.h"
#import "AsyncImageView.h"
#import "Constants.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "DownloadManageViewController.h"
#import "SelectPhotoViewController.h"
#import "MyProfileViewController.h"
#import "MZUtility.h"
#import "CustomDualTransition.h"
#import "CustomCubeTransition.h"
#import "CustomTransformTransition.h"

@interface HomeViewController (Private)
- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController:(CustomTransitioningViewController*)viewController;
@end

@interface HomeViewController() <UITableViewDataSource, UITableViewDelegate, DownloadDelegate>

@property(nonatomic,strong) UIView *menuViewTop;
@property(nonatomic,strong) UIView *menuBar;
@property(nonatomic,strong) UITableView *feedTable;
@property(nonatomic,strong) UITableView *menuTable;
@property(nonatomic,assign) float leftAlign;
@property(nonatomic,strong) AppDelegate *appDelegate;
@property(nonatomic,strong) NSMutableArray *activedAccounts;

@property(nonatomic,strong) NSMutableArray *feedArray;
@property(nonatomic,strong) NSMutableArray *likedArray;
@property(nonatomic,strong) NSMutableArray *mediaArray;

@property(nonatomic,assign) NSInteger accountPointer;
@property(nonatomic,assign) NSInteger accountPointerForLike;
@property(nonatomic,assign) BOOL is_menu_shown;
@property(nonatomic,assign) BOOL is_menu_expanded;
@property(nonatomic,strong) AsyncImageView *accountImageView;
@property(nonatomic,strong) UILabel *fullnameLabel;
@property(nonatomic,strong) UILabel *usernameLabel;

@property(nonatomic,strong) NSString *next_feed_max_id;
@property(nonatomic,strong) NSString *next_like_max_id;
@property(nonatomic,strong) NSString *next_media_max_id;

@property(nonatomic,strong) DownloadManageViewController *downloadingViewObj;

@end



@implementation HomeViewController

-(void)viewDidLoad
{

    self.appDelegate = [UIApplication sharedApplication].delegate;

    self.leftAlign = 0;
    
    self.feedArray = nil;
    self.likedArray = nil;
    self.mediaArray = nil;
    
    self.feedTable = [[UITableView alloc] initWithFrame: CGRectMake(0, top_view.frame.origin.y + top_view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - top_view.frame.size.height)];
    self.feedTable.delegate = self;
    self.feedTable.dataSource = self;
    self.feedTable.tag = FEEDS_TABLE;
    self.feedTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: self.feedTable];
    [self setupMenu];
    
    
    [SVProgressHUD showWithStatus: @"Loading..."];
    

    __weak HomeViewController *weakSelf = self;
    
    // setup infinite scrolling
    [self.feedTable addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowsAtBottom];
    }];
    

    self.downloadingViewObj = [self.storyboard instantiateViewControllerWithIdentifier: @"downloadView"];
    [self.downloadingViewObj setDelegate:self];
    
    self.downloadingViewObj.downloadingArray = [[NSMutableArray alloc] init];
    self.downloadingViewObj.sessionManager = [self.downloadingViewObj backgroundSession];
    [self.downloadingViewObj populateOtherDownloadTasks];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.appDelegate callURL: manageInstaUser action: [NSString stringWithFormat: @"action=get_all&username=%@&password=%@", self.appDelegate.userName, self.appDelegate.userPassword] delegate: self];
}


- (void)insertRowsAtBottom
{
    __weak HomeViewController *weakSelf = self;
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf beginUpdates];
        [self.feedTable.infiniteScrollingView stopAnimating];
    });
    
}

- (void)beginUpdates
{
    if(self.accountPointer >= [self.activedAccounts count])
        self.accountPointer = 0;
    NSDictionary *dict = [self.appDelegate.instaAccounts objectAtIndex: self.accountPointer];
    NSString *accessToken = [dict valueForKey: @"accessToken"];
    
    if(self.feedTable.tag == FEEDS_TABLE)
    {
        NSString *next_max_id = self.next_feed_max_id;
        if([next_max_id isEqual: [NSNull null]])
        {
            next_max_id = @"";
        }
        if((next_max_id == nil)||([next_max_id isEqual: @""]))
        {
            [self showFeed: accessToken];
        }
        else if([next_max_id isEqual: @"nomore"])
        {
            NSLog(@"nothing more");
        }
        else
        {
            [self showNextFeed: accessToken nextmaxid: next_max_id];
        }
    }
    else if(self.feedTable.tag == LIKED_TABLE)
    {
        NSString *next_max_id = self.next_like_max_id;
        if([next_max_id isEqual: [NSNull null]])
        {
            next_max_id = @"";
        }

        if((next_max_id == nil)||([next_max_id isEqual: @""]))
        {
            [self showLikedStatus];
        }
        else if([next_max_id isEqual: @"nomore"])
        {
            NSLog(@"nothing more");
        }
        else
        {
            [self showNextLikedStatus: accessToken nextmaxid: next_max_id];
        }
    }
    else if(self.feedTable.tag == MEDIA_TABLE)
    {
        NSString *next_max_id = self.next_media_max_id;
        if([next_max_id isEqual: [NSNull null]])
        {
            next_max_id = @"";
        }

        if((next_max_id == nil)||([next_max_id isEqual: @""]))
        {
            [self showUserMedia];
        }
        else if([next_max_id isEqual: @"nomore"])
        {
            NSLog(@"nothing more");
        }
        else
        {
            [self showUserNextMedia: accessToken nextmaxid: next_max_id];
        }
    }

}

-(void)showNextFeed:(NSString*)accessToken nextmaxid: (NSString*)next_max_id
{
    NSLog(@"AccessToken: %@", accessToken);
    
    NSNumber *feedCountVal = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
    int feedCount = [feedCountVal intValue];
    InstagramClient *instaClient = [InstagramClient clientWithToken: accessToken];
    if(feedCount != -1)
    {
        [instaClient getUserNextFeed: feedCount minId: -1 maxId: next_max_id success:^(NSArray *medias) {
            
            [SVProgressHUD dismiss];
            if(medias.count > 0)
            {
                
                for(int i = 0; i < medias.count; i ++)
                {
                    InstagramMedia *media = [medias objectAtIndex: i];
                    [self.feedArray addObject: media];
                }
                self.feedTable.tag = FEEDS_TABLE;
                [self.feedTable reloadData];
                
                NSString *next_max_id = [[NSUserDefaults standardUserDefaults] objectForKey: @"next_max_id"];
                self.next_feed_max_id = next_max_id;
            }
            else
            {
                NSLog(@"Nothing to feed");
                self.next_feed_max_id = @"nomore";
            }
            
            
        } failure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    }

}

-(void)showFeed:(NSString*)accessToken
{
    NSLog(@"AccessToken: %@", accessToken);
    
    self.feedArray = nil;
    self.feedArray = [NSMutableArray array];
    NSNumber *feedCountVal = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
    int feedCount = [feedCountVal intValue];
    InstagramClient *instaClient = [InstagramClient clientWithToken: accessToken];
    if(feedCount != -1)
    {
        [instaClient getUserFeed: feedCount minId: -1 maxId: -1 success:^(NSArray *medias) {
            
            [SVProgressHUD dismiss];
            if(medias.count > 0)
            {
                for(int i = 0; i < medias.count; i ++)
                {
                    InstagramMedia *media = [medias objectAtIndex: i];
                    [self.feedArray addObject: media];
                }
                self.feedTable.tag = FEEDS_TABLE;
                [self.feedTable reloadData];
                NSString *next_max_id = [[NSUserDefaults standardUserDefaults] objectForKey: @"next_max_id"];
                self.next_feed_max_id = next_max_id;
            }
            else
            {
                NSLog(@"Nothing to feed");
                self.next_feed_max_id = @"nomore";
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            
        }];

    }
    
}

-(void)showAllFeeds
{
    if([self.activedAccounts count] > 0)
    {
        self.feedArray = nil;
        self.feedArray = [NSMutableArray array];
            
        NSString *last_insta_username = [[NSUserDefaults standardUserDefaults] objectForKey: @"last_insta_username"];
        if(last_insta_username == nil)
        {
            self.accountPointer = 0;
            NSDictionary *dict = [self.activedAccounts objectAtIndex: 0];
            NSString *insta_username = [dict valueForKey: @"insta_username"];
            [[NSUserDefaults standardUserDefaults] setObject: insta_username forKey: @"last_insta_username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *accessToken = [dict valueForKey: @"accessToken"];
            [self showFeed: accessToken];
            [self setInstaAccountInfo: self.accountPointer];

        }
        else
        {
            NSInteger foundIndex = -1;
            for(int i = 0; i < [self.activedAccounts count]; i ++)
            {
                NSDictionary *userDict = [self.activedAccounts objectAtIndex: i];
                NSString *name = [userDict valueForKey: @"insta_username"];
                if([name isEqual: last_insta_username])
                {
                    foundIndex = i;
                    break;
                }
            }
            if(foundIndex != -1)
            {
                self.accountPointer = foundIndex;
                NSDictionary *dict = [self.activedAccounts objectAtIndex: self.accountPointer];
                NSString *accessToken = [dict valueForKey: @"accessToken"];
                [self showFeed: accessToken];
                [self setInstaAccountInfo: self.accountPointer];
            }
            else
            {
                self.accountPointer = 0;
                NSDictionary *dict = [self.activedAccounts objectAtIndex: 0];
                NSString *insta_username = [dict valueForKey: @"insta_username"];
                [[NSUserDefaults standardUserDefaults] setObject: insta_username forKey: @"last_insta_username"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *accessToken = [dict valueForKey: @"accessToken"];
                [self showFeed: accessToken];
                [self setInstaAccountInfo: self.accountPointer];
            }
        }
    }
}

-(void)showLikedStatus
{
    
    if([self.activedAccounts count] > 0)
    {
        self.likedArray = nil;
        self.likedArray = [NSMutableArray array];
        
        NSDictionary *dict = [self.activedAccounts objectAtIndex: self.accountPointer];
        NSString *accessToken = [dict valueForKey: @"accessToken"];
        InstagramClient *instaClient = [InstagramClient clientWithToken: accessToken];
        NSNumber *feedCycleVal = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
        int feedCycle = [feedCycleVal intValue];
        if(feedCycle != -1)
        {
            [instaClient getUserLikes: feedCycle * 2 maxId: -1 success:^(NSArray *medias) {
                [SVProgressHUD dismiss];
                if(medias.count > 0)
                {
                    self.likedArray = [NSMutableArray array];
                    for(int i = 0; i < medias.count; i ++)
                    {
                        InstagramMedia *media = [medias objectAtIndex: i];
                        [self.likedArray addObject: media];
                    }
                    self.feedTable.tag = LIKED_TABLE;
                    [self.feedTable reloadData];
                    
                    NSString *next_max_id = [[NSUserDefaults standardUserDefaults] objectForKey: @"next_max_id"];
                    self.next_like_max_id = next_max_id;
                }
                else
                {
                    NSLog(@"Nothing to show");
                    self.next_like_max_id = @"nomore";
                }
                
            } failure:^(NSError *error, NSInteger statusCode) {
                
            }];
            
        }
            
        
    }
    else
    {
        [self showMessage: @"No Activated account" withTitle:@"Warning"];
    }
    
}


-(void)showNextLikedStatus:(NSString*)accessToken nextmaxid:(NSString*)next_max_id
{
    NSLog(@"AccessToken: %@", accessToken);
    
    NSNumber *feedCountVal = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
    int feedCount = [feedCountVal intValue];
    InstagramClient *instaClient = [InstagramClient clientWithToken: accessToken];
    if(feedCount != -1)
    {
        [instaClient getUserNextLikes: feedCount * 2 maxId: next_max_id success:^(NSArray *medias) {
            [SVProgressHUD dismiss];
            if(medias.count > 0)
            {
                
                for(int i = 0; i < medias.count; i ++)
                {
                    InstagramMedia *media = [medias objectAtIndex: i];
                    [self.likedArray addObject: media];
                }
                self.feedTable.tag = LIKED_TABLE;
                [self.feedTable reloadData];
                
                NSString *next_max_id = [[NSUserDefaults standardUserDefaults] objectForKey: @"next_max_id"];
                self.next_like_max_id = next_max_id;
            }
            else
            {
                NSLog(@"Nothing to feed");
                self.next_like_max_id = @"nomore";
            }
        } failure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    }

}

-(void)showUserMedia
{
    if([self.activedAccounts count] > 0)
    {
        self.mediaArray = nil;
        self.mediaArray = [NSMutableArray array];
        NSDictionary *dict = [self.activedAccounts objectAtIndex: self.accountPointer];
        NSString *accessToken = [dict valueForKey: @"accessToken"];
        InstagramClient *instaClient = [InstagramClient clientWithToken: accessToken];
        NSNumber *feedCycleVal = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
        int feedCycle = [feedCycleVal intValue];
        if(feedCycle != -1)
        {
            [instaClient getUserMedia: @"self" count: feedCycle minId: -1 maxId: -1 success:^(NSArray *medias) {
                [SVProgressHUD dismiss];
                if(medias.count > 0)
                {
                    self.mediaArray = [NSMutableArray array];
                    for(int i = 0; i < medias.count; i ++)
                    {
                        InstagramMedia *media = [medias objectAtIndex: i];
                        [self.mediaArray addObject: media];
                    }
                    self.feedTable.tag = MEDIA_TABLE;
                    [self.feedTable reloadData];
                    
                    NSString *next_max_id = [[NSUserDefaults standardUserDefaults] objectForKey: @"next_max_id"];
                    self.next_media_max_id = next_max_id;
                }
                else
                {
                    NSLog(@"Nothing to show");
                    self.next_media_max_id = @"nomore";
                }

            } failure:^(NSError *error, NSInteger statusCode) {
                
            }];
            
        }
            
        
    }
    else
    {
        [self showMessage: @"No Activated account" withTitle:@"Warning"];
    }

}

-(void)showUserNextMedia:(NSString*)accessToken nextmaxid:(NSString*)next_max_id
{
    NSLog(@"AccessToken: %@", accessToken);
    
    NSNumber *feedCountVal = [[NSUserDefaults standardUserDefaults] objectForKey: @"feedCycle"];
    int feedCount = [feedCountVal intValue];
    InstagramClient *instaClient = [InstagramClient clientWithToken: accessToken];
    if(feedCount != -1)
    {
        [instaClient getUserNextMedia: @"self" count: feedCount minId: -1 maxId: next_max_id success:^(NSArray *medias) {
            [SVProgressHUD dismiss];
            if(medias.count > 0)
            {
                
                for(int i = 0; i < medias.count; i ++)
                {
                    InstagramMedia *media = [medias objectAtIndex: i];
                    [self.mediaArray addObject: media];
                }
                self.feedTable.tag = MEDIA_TABLE;
                [self.feedTable reloadData];
                
                NSString *next_max_id = [[NSUserDefaults standardUserDefaults] objectForKey: @"next_max_id"];
                self.next_media_max_id = next_max_id;
            }
            else
            {
                NSLog(@"Nothing to feed");
                self.next_media_max_id = @"nomore";
            }
        } failure:^(NSError *error, NSInteger statusCode) {
            
        }];

    }
    

}

-(void)showDownloadView
{
    [self presentViewController: self.downloadingViewObj animated: NO completion: nil];
}

-(void)postPicture
{
//    NSString* filename = [NSString stringWithFormat:@"myimage.igo"];
//    NSString* savePath = [imagesPath stringByAppendingPathComponent:filename];
//    [UIImagePNGRepresentation(myImage) writeToFile:savePath atomically:YES];
//    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
//    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
//    {
//        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
//        self.documentInteractionController.UTI = @"com.instagram.image";
//        self.documentInteractionController.delegate = self;
//        [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
//    }
    [SVProgressHUD dismiss];
    self.appDelegate.activatedAccounts = self.activedAccounts;
    SelectPhotoViewController *selectPhotoView = [self.storyboard instantiateViewControllerWithIdentifier: @"selectPhotoView"];
    [self presentViewController: selectPhotoView animated: NO completion: nil];
}

-(void)showAccountsView
{
    MyProfileViewController *profileView = [self.storyboard instantiateViewControllerWithIdentifier: @"myprofileView"];
    [self presentViewController: profileView animated: NO completion: nil];
}

-(void)setInstaAccountInfo:(NSInteger)selectedAccount
{
    self.accountPointer = selectedAccount;
    NSDictionary *dict = [self.activedAccounts objectAtIndex: selectedAccount];
    NSString *insta_fullname = [dict valueForKey: @"insta_userfullname"];
    NSString *insta_username = [dict valueForKey: @"insta_username"];
    [[NSUserDefaults standardUserDefaults] setObject: insta_username forKey: @"last_insta_username"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *userprofilepictureurl = [dict valueForKey: @"insta_userprofilepictureurl"];
    NSString *accessToken = [dict valueForKey: @"accessToken"];
    [self.fullnameLabel setText: insta_fullname];
    [self.usernameLabel setText: insta_username];
    self.accountImageView.imageURL = [NSURL URLWithString: userprofilepictureurl];
    NSLog(@"%@", dict);

    [self showFeed: accessToken];
    
    InstagramClient *instagramClient = [InstagramClient clientWithToken: accessToken];
    [instagramClient getUser: @"self" success:^(InstagramUser *user) {
        
        NSLog(@"User name: %ld", user.mediaCount);
        
    } failure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"%@", [error userInfo]);
    }];

}


-(void)dealloc
{
    self.menuBar = nil;
    self.menuViewTop = nil;
    self.feedTable = nil;
    self.feedArray = nil;
    self.likedArray = nil;

}

-(void)setupMenu
{
    [btn_menu setImage: [UIImage imageNamed: @"btn_title_menu_st.png"] forState: UIControlStateSelected];
    
    self.menuBar = [[UIView alloc] initWithFrame: CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.menuBar setBackgroundColor: [UIColor colorWithRed: 0.37 green: 0.38 blue: 0.4 alpha: 1]];
    [self.view addSubview: self.menuBar];
    [self.view bringSubviewToFront: top_view];
    self.is_menu_shown = false;
    
    NSArray *btnNames = @[@"A", @"ic_activity_feed.png", @"ic_activity_liked.png", @"ic_activity_myfeed.png", @"ic_activity_download.png", @"ic_activity_post.png", @"ic_activity_schedule.png", @"ic_activity_setting.png", @"ic_account_info.png", @"ic_activity_logout.png"];
    
    for(int i = 0; i < 10; i ++)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame: CGRectMake(self.view.frame.size.width-50, top_view.frame.size.height + i * 50, 50, 50)];
        btn.tag = i;
        [btn setImage: [UIImage imageNamed: btnNames[i]] forState: UIControlStateNormal];
        [btn addTarget: self action: @selector(btn_menuitemsClicked:) forControlEvents: UIControlEventTouchUpInside];
        [self.menuBar addSubview: btn];
    }
    
    //Swipe left Gesture
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeLeft:)] ;
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:oneFingerSwipeLeft];
    
    //Swipe right Gesture
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.menuBar addGestureRecognizer:oneFingerSwipeRight];
    [self.view addGestureRecognizer:oneFingerSwipeRight];

    
    //Swip top Gesture
    UISwipeGestureRecognizer *oneFingerSwipeTop = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeTop:)] ;
    [oneFingerSwipeTop setDirection: UISwipeGestureRecognizerDirectionUp];
    [self.menuBar addGestureRecognizer:oneFingerSwipeTop];
    
    //Swip down Gesture
    UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeDown:)];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.menuBar addGestureRecognizer:oneFingerSwipeDown];
    
    self.is_menu_shown = false;
    self.is_menu_expanded = false;
    
    
    self.menuViewTop = [[UIView alloc] initWithFrame: CGRectMake(0, 0, top_view.frame.size.width, top_view.frame.size.height)];
    [self.menuViewTop setBackgroundColor: [UIColor colorWithRed: 0.37 green: 0.38 blue: 0.4 alpha: 1]];
    [self.menuBar addSubview: self.menuViewTop];
 
    //Put Instagram account picture & info
    UIButton *btn_setting = [[UIButton alloc] initWithFrame: CGRectMake(self.menuBar.frame.size.width-50, 32, 25, 25)];

    [btn_setting setImage: [UIImage imageNamed: @"ic_feed_setting.png"] forState: UIControlStateNormal];
    
//    self.selectedAccountIndex = 0;
    self.accountImageView = [[AsyncImageView alloc] initWithFrame: CGRectMake((self.menuBar.frame.size.width-100)/2, 50, 100, 100)];
    self.accountImageView.layer.cornerRadius = 50;
    self.accountImageView.layer.masksToBounds = YES;

    UIButton *btn_prev_account = [[UIButton alloc] initWithFrame: CGRectMake(self.accountImageView.frame.origin.x-25, self.accountImageView.frame.origin.y+50, 25, 25)];
    UIButton *btn_next_account = [[UIButton alloc] initWithFrame: CGRectMake(self.accountImageView.frame.origin.x+self.accountImageView.frame.size.width, self.accountImageView.frame.origin.y+50, 25, 25)];
    [btn_prev_account setTitle: @"<" forState: UIControlStateNormal];
    [btn_next_account setTitle: @">" forState: UIControlStateNormal];
    [btn_setting addTarget: self action: @selector(btn_settingsClicked) forControlEvents: UIControlEventTouchUpInside];
    [btn_prev_account addTarget: self action: @selector(btn_prevAccountClicked) forControlEvents: UIControlEventTouchUpInside];
    [btn_next_account addTarget: self action: @selector(btn_nextAccountClicked) forControlEvents: UIControlEventTouchUpInside];

    
    self.fullnameLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 160, self.menuBar.frame.size.width, 20)];
    self.usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 175, self.menuBar.frame.size.width, 20)];
    

//    [self.fullnameLabel setFont: [UIFont systemFontOfSize: 14.0]];
    [self.fullnameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 14.0]];
    [self.fullnameLabel setTextColor: [UIColor whiteColor]];
    [self.fullnameLabel setTextAlignment: NSTextAlignmentCenter];
//    [self.usernameLabel setFont: [UIFont systemFontOfSize: 12.0]];
    [self.usernameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 12.0]];
    [self.usernameLabel setTextColor: [UIColor lightGrayColor]];
    [self.usernameLabel setTextAlignment: NSTextAlignmentCenter];
    
    [self.menuBar addSubview: btn_setting];
    [self.menuBar addSubview: btn_prev_account];
    [self.menuBar addSubview: btn_next_account];
    [self.menuBar addSubview: self.accountImageView];
    [self.menuBar addSubview: self.fullnameLabel];
    [self.menuBar addSubview: self.usernameLabel];
    
    //Put menu table
    self.menuTable = [[UITableView alloc] initWithFrame: CGRectMake(30, 220, self.menuBar.frame.size.width-30, self.menuBar.frame.size.height-220)];
    self.menuTable.tag = MENU_TABLE;
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    [self.menuTable setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self.menuTable setBackgroundColor: [UIColor colorWithRed: 0.37 green: 0.38 blue: 0.4 alpha: 1]];
    [self.menuBar addSubview: self.menuTable];
    [self.menuTable setHidden: YES];
    
    
}

-(void)btn_settingsClicked
{

//    CustomTransition * animation = [[CustomCubeTransition alloc] initWithDuration: 0.7 orientation:CustomTransitionLeftToRight sourceRect:self.view.frame];
    
    SettingsViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier: @"settingsView"];
    
//    [self _pushViewControllerWithTransition: animation nextViewController: settingsView];
    [self presentViewController: settingsView animated: NO completion: nil];
}

-(void)btn_prevAccountClicked
{
    if(self.accountPointer == 0)
        self.accountPointer = [self.activedAccounts count] - 1;
    else
        self.accountPointer --;
    [self setInstaAccountInfo: self.accountPointer];
}

-(void)btn_nextAccountClicked
{
    if(self.accountPointer == [self.activedAccounts count] - 1)
        self.accountPointer = 0;
    else
        self.accountPointer ++;
    [self setInstaAccountInfo: self.accountPointer];

}

-(void)oneFingerSwipeLeft:(UITapGestureRecognizer*)recog
{
    [self hideMenu];
}


-(void)oneFingerSwipeRight:(UITapGestureRecognizer*)recog
{
    if(!self.is_menu_shown)
        [self showMenu];
    else
        [self expandMenu];
}


-(void)oneFingerSwipeTop:(UITapGestureRecognizer*)recog
{
    if(iPhone4S)
    {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
//                             [self.menuBar setFrame: CGRectMake(self.menuBar.frame.origin.x, -50, self.menuBar.frame.size.width, self.menuBar.frame.size.height)];
                             NSArray *btnMenyArray = [self.menuBar subviews];
                             if(btnMenyArray != nil)
                             {
                                 for(int i = 0; i < 10; i ++)
                                 {
                                     UIButton *btn = (UIButton*)[btnMenyArray objectAtIndex: i];
                                     [btn setFrame: CGRectMake(self.view.frame.size.width-50, top_view.frame.size.height + i * 50 - 50, 50, 50)];
                                 }
                                 
                             }
                         }
                         completion:^(BOOL finished) {

                         }];
    }
}

-(void)oneFingerSwipeDown:(UITapGestureRecognizer*)recog
{
    if(iPhone4S)
    {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
//                             [self.menuBar setFrame: CGRectMake(self.menuBar.frame.origin.x, 0, self.menuBar.frame.size.width, self.menuBar.frame.size.height)];
                             NSArray *btnMenyArray = [self.menuBar subviews];
                             if(btnMenyArray != nil)
                             {
                                 for(int i = 0; i < 10; i ++)
                                 {
                                     UIButton *btn = (UIButton*)[btnMenyArray objectAtIndex: i];
                                     [btn setFrame: CGRectMake(self.view.frame.size.width-50, top_view.frame.size.height + i * 50, 50, 50)];
                                 }
                                 
                             }

                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }

}


-(void)btn_menuitemsClicked:(id)sender
{
    for(id child in [self.menuBar subviews])
    {

        if([child isKindOfClass: [UIButton class]])
        {
            UIButton *btn = (UIButton*)child;
            [[btn titleLabel] setTextColor: [UIColor whiteColor]];
            btn.layer.borderWidth = 0;
        }
    }
    UIButton *btnClicked = (UIButton*)sender;
    [[btnClicked titleLabel] setTextColor: [UIColor redColor]];
    
    [self hideMenu];
//    btnClicked.layer.borderColor = [UIColor redColor].CGColor;
//    btnClicked.layer.borderWidth = 1;
    
    switch (btnClicked.tag) {
        case 0:
            //Go to user profile screen
            break;
        case 1:
            //Feeds screen
//            self.likedArray = nil;
            [self showAllFeeds];
            break;
        case 2:
            //Liked feeds
//            self.feedArray = nil;
            [self showLikedStatus];
            break;
        case 3://My Photo screen
            [self showUserMedia];
            break;
        case 4:
            //Download
            [self showDownloadView];
            break;
        case 5:
            //Post picture
            [self postPicture];
            break;
        case 6://Schedule picture
            break;
        case 7://Go to Settings screen
        {
            _duration = 0.7;
            CustomTransformTransition * animation = [[CustomCubeTransition alloc] initWithDuration: _duration orientation:CustomTransitionRightToLeft sourceRect:self.view.frame];
            
            SettingsViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier: @"settingsView"];
            
            [self _pushViewControllerWithTransition: animation nextViewController: settingsView];
            break;
        }
        case 8://Account
        {
            MyProfileViewController *myprofileView = [self.storyboard instantiateViewControllerWithIdentifier: @"myprofileView"];
            [self presentViewController: myprofileView animated: YES completion: nil];
            break;
        }
        case 9://Logout
            
            [self dismissViewControllerAnimated: YES completion: nil];
            break;
        default:
            break;
    }
}

-(IBAction)btn_menuClicked:(id)sender
{
    if(!self.is_menu_shown)
    {
        [self showMenu];
    }
    else
    {
        [self hideMenu];
    }
}

-(void)showMenu
{
    [self.menuTable setHidden: YES];
    [btn_menu setSelected: true];

    [UIView animateWithDuration: 0.2
                        delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.menuBar setFrame: CGRectMake(-self.view.frame.size.width+50, self.menuBar.frame.origin.y, self.menuBar.frame.size.width, self.menuBar.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         self.is_menu_shown = true;
                         [self.menuBar setHidden: NO];
                         [self.menuViewTop setHidden: NO];
                     }];

    if((iPhone6)||(iPhone6P))
    {
        self.leftAlign = 50;
        [self.feedTable reloadData];
    }
    else
    {
        self.leftAlign = 0;
        [self.feedTable reloadData];
    }
}

-(void)hideMenu
{
    [btn_menu setSelected: false];

    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.feedTable setFrame: CGRectMake(0, self.feedTable.frame.origin.y, self.feedTable.frame.size.width, self.feedTable.frame.size.height)];
                         [self.menuBar setFrame: CGRectMake(-self.view.frame.size.width, self.menuBar.frame.origin.y, self.menuBar.frame.size.width, self.menuBar.frame.size.height)];
                         [top_view setFrame: CGRectMake(0, 0, top_view.frame.size.width, top_view.frame.size.height)];

                     }
                     completion:^(BOOL finished) {
                         [btn_menu setUserInteractionEnabled: true];
                         [self.view bringSubviewToFront: self.menuBar];
                         [self.view bringSubviewToFront: top_view];
                         self.is_menu_shown = false;
                         self.is_menu_expanded = false;
                         [self.menuBar setHidden: YES];
                         [self.feedTable setHidden: NO];
                         [top_view setHidden: NO];

//                         [self.menuViewTop setHidden: YES];
                         for(int i = 0; i < 9; i ++)
                         {
                             UIButton *btn = [[self.menuBar subviews] objectAtIndex: i];
                             [btn setHidden: NO];
                         }

                     }];
    
    self.leftAlign = 0;
    [self.feedTable reloadData];


}

-(void)expandMenu
{
    NSLog(@"ExpandMenu");
    if(!self.is_menu_expanded)
    {
        [UIView animateWithDuration: 0.25
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.feedTable setFrame: CGRectMake(self.view.frame.size.width, self.feedTable.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
                             [self.menuBar setFrame: CGRectMake(0, self.menuBar.frame.origin.y, self.menuBar.frame.size.width, self.menuBar.frame.size.height)];
                             [top_view setFrame: CGRectMake(self.view.frame.size.width, 0, top_view.frame.size.width, top_view.frame.size.height)];
                             [self.menuTable setHidden: NO];
                         }
                         completion:^(BOOL finished) {
                             [self.feedTable setHidden: YES];
                             [top_view setHidden: YES];
                             [btn_menu setUserInteractionEnabled: false];
                             self.is_menu_shown = true;
                             self.is_menu_expanded = true;
                             [btn_menu setSelected: true];
                             for(int i = 0; i < 9; i ++)
                             {
                                 UIButton *btn = [[self.menuBar subviews] objectAtIndex: i];
                                 [btn setHidden: YES];
                             }
                             
                             [UIView animateWithDuration: 0.5
                                                   delay: 1
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  [self.view bringSubviewToFront: self.feedTable];
                                                  self.leftAlign = 0;
                                                  [self.feedTable reloadData];
                                                  
                                                 
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                              }];

                         }];
        

        
    }

}

-(IBAction)btn_searchClicked:(id)sender
{
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == FEEDS_TABLE)
    {
        return self.feedArray.count;
    }
    else if(tableView.tag == LIKED_TABLE)
    {
        if(self.likedArray.count % 2 == 0)
            return [self.likedArray count] / 2;
        else
            return ([self.likedArray count] / 2) + 1;
    }
    else if(tableView.tag == MEDIA_TABLE)
    {
        int groupCount = (int)[self.mediaArray count] / 3;
        int rest = [self.mediaArray count] % 3;
        int extrarow = (rest > 1)?2:1;
        int rowcount = groupCount * 2 + extrarow;
        return rowcount;
    }
    else if(tableView.tag == MENU_TABLE)
    {
        return 8;
    }
    else
    {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == FEEDS_TABLE)
    {
        return 400;
    }
    else if(tableView.tag == LIKED_TABLE)
    {
        return 155;
    }
    else if(tableView.tag == MEDIA_TABLE)
    {
        return (indexPath.row%2==0)?300:150;
    }
    else
    {
        return 50;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag == FEEDS_TABLE) //Feeds table
    {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"feedCell"];
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"feedCell"];
        UIView *contentView = [[UIView alloc] initWithFrame: CGRectMake(self.leftAlign + 10, 20, self.view.frame.size.width-(20+self.leftAlign), 380)];
        
        
        InstagramMedia *media = [self.feedArray objectAtIndex: indexPath.row];
        InstagramUser *user = media.user;
        NSString *userFullName = user.fullname;
        NSString *userProfilePictureURL = user.profilePictureUrl;
        NSInteger likeCount = media.likeCount;
        NSInteger commentCount = media.commentCount;
        NSDate *postDate = media.createdTime;
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [now timeIntervalSinceDate: postDate];
        float min = interval / 60.0;
        float hrs = interval / 3600.0;
        
        NSString *postDateStr;
        if(hrs >= 1.0)
            postDateStr = [NSString stringWithFormat: @"%d hour ago", (int)hrs];
        else
            postDateStr = [NSString stringWithFormat: @"%d min ago", (int)min];
        
        NSDictionary *feedImageDict = [media.images objectForKey: @"standard_resolution"];
        NSString *imageURL = [feedImageDict objectForKey: @"url"];
        NSString *text = media.text;
        if([text isEqual:[NSNull null]])
            text = @"";
        
        AsyncImageView *user_photo = [[AsyncImageView alloc] initWithFrame: CGRectMake(20, 20, 25, 25)];
        user_photo.imageURL = [NSURL URLWithString: userProfilePictureURL];
        UILabel *lbl_name = [[UILabel alloc] initWithFrame: CGRectMake(50, 15, 100, 25)];

        [lbl_name setFont: [UIFont fontWithName: @"OpenSans" size: 13.0]];
//        [lbl_name setFont: [UIFont systemFontOfSize: 13.0]];
        [lbl_name setText: userFullName];
        
        UIImageView *favor_icon = [[UIImageView alloc] initWithFrame: CGRectMake(145-self.leftAlign*1/3, 22, 12, 12)];
        [favor_icon setImage: [UIImage imageNamed: @"ic_activity_like.png"]];
        
        UILabel *lbl_favcount = [[UILabel alloc] initWithFrame: CGRectMake(160-self.leftAlign*1/3, 15, 60, 25)];
        [lbl_favcount setText: [NSString stringWithFormat: @"%ld", (long)likeCount]];
        [lbl_favcount setFont: [UIFont fontWithName: @"OpenSans" size: 12.0]];
        
        UIImageView *img_timer = [[UIImageView alloc] initWithFrame: CGRectMake(contentView.frame.size.width-93, 22, 12, 12)];
        [img_timer setImage: [UIImage imageNamed: @"ic_activity_clock.png"]];
        
        UILabel *lbl_post_time = [[UILabel alloc] initWithFrame: CGRectMake(contentView.frame.size.width-80, 15, 80, 25)];
        [lbl_post_time setText: postDateStr];
        [lbl_post_time setFont: [UIFont fontWithName: @"OpenSans" size: 12.0]];
        
        AsyncImageView *feedImage = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 65, contentView.frame.size.width, 200)];
        feedImage.imageURL = [NSURL URLWithString: imageURL];
        
        UILabel *imgDesc = [[UILabel alloc] initWithFrame: CGRectMake(15, feedImage.frame.origin.y + feedImage.frame.size.height, contentView.frame.size.width - 30, 60)];
        [imgDesc setText: text];
        [imgDesc setNumberOfLines: 2];
        [imgDesc setFont: [UIFont fontWithName: @"OpenSans" size: 12.0]];
        
        //        imgDesc.layer.borderColor = [UIColor grayColor].CGColor;
        //        imgDesc.layer.borderWidth = 1.0;
        UIView *bottm = [[UIView alloc] initWithFrame: CGRectMake(0, imgDesc.frame.origin.y + imgDesc.frame.size.height, contentView.frame.size.width,  55)];
        bottm.layer.borderColor = [UIColor grayColor].CGColor;
        bottm.layer.borderWidth = 1.0;
        UIButton *btn_comments = [[UIButton alloc] initWithFrame: CGRectMake(10, 10, 110, 35)];
        [btn_comments setTitle: [NSString stringWithFormat: @"%ld COMMENTS", (long)commentCount] forState: UIControlStateNormal];
        [btn_comments setBackgroundColor: [UIColor grayColor]];
        [[btn_comments titleLabel] setFont: [UIFont fontWithName: @"OpenSans" size: 12.0]];
        [[btn_comments titleLabel] setTextColor: [UIColor whiteColor]];
        
        UIButton *btn_download = [[UIButton alloc] initWithFrame: CGRectMake(contentView.frame.size.width-100, 10, 40, 35)];
        [btn_download setImage: [UIImage imageNamed: @"btn_activity_download.png"] forState: UIControlStateNormal];
        btn_download.tag = indexPath.row;
        [btn_download addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];
        UIButton *btn_favor = [[UIButton alloc] initWithFrame: CGRectMake(contentView.frame.size.width-50, 10, 40, 35)];
        [btn_favor setImage: [UIImage imageNamed: @"btn_activity_like.png"] forState: UIControlStateNormal];
        btn_favor.tag = indexPath.row;
        [btn_favor addTarget: self action: @selector(btn_likeClicked:) forControlEvents: UIControlEventTouchUpInside];

        [bottm addSubview: btn_comments];
        [bottm addSubview: btn_download];
        [bottm addSubview: btn_favor];
        
        [contentView addSubview: user_photo];
        [contentView addSubview: lbl_name];
        [contentView addSubview: favor_icon];
        [contentView addSubview: lbl_favcount];
        [contentView addSubview: img_timer];
        [contentView addSubview: lbl_post_time];
        [contentView addSubview: feedImage];
        [contentView addSubview: imgDesc];
        [contentView addSubview: bottm];
        contentView.tag = 100;
        [cell addSubview: contentView];
        contentView.layer.borderColor = [UIColor grayColor].CGColor;
        contentView.layer.borderWidth = 1.0;
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            
        return cell;
    }
    else if(tableView.tag == LIKED_TABLE) //Liked Status table
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"likedCell"];
        
        UIView *contentView = [[UIView alloc] initWithFrame: CGRectMake(self.leftAlign + 5, 5, (self.feedTable.frame.size.width-(15+self.leftAlign))/2, 150)];

        AsyncImageView *likedImageView = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
        UIButton *btn_download = [[UIButton alloc] initWithFrame: CGRectMake(7,7,20,15)];
        UIButton *btn_like = [[UIButton alloc] initWithFrame: CGRectMake(10, likedImageView.frame.size.height-20, 12, 12)];
        UILabel *likeCountLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, likedImageView.frame.size.height-22, 50, 15)];
        UIImageView *timerImage = [[UIImageView alloc] initWithFrame: CGRectMake(likedImageView.frame.size.width-50, likedImageView.frame.size.height-20, 10, 10)];
        UILabel *passedTime = [[UILabel alloc] initWithFrame: CGRectMake(likedImageView.frame.size.width-35, likedImageView.frame.size.height-22, 35, 15)];
        [likeCountLabel setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
        [passedTime setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
        [likeCountLabel setTextColor: [UIColor whiteColor]];
        [passedTime setTextColor: [UIColor whiteColor]];
        [btn_download setImage: [UIImage imageNamed: @"ic_feed_download.png"] forState: UIControlStateNormal];
        btn_download.tag = indexPath.row * 2;
        [btn_download addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];
        [btn_like setImage: [UIImage imageNamed: @"ic_feed_liked.png"] forState: UIControlStateNormal];
        btn_like.tag = indexPath.row * 2;
        [btn_like addTarget: self action: @selector(btn_likeClicked:) forControlEvents: UIControlEventTouchUpInside];
        [timerImage setImage: [UIImage imageNamed: @"ic_feed_schedule.png"]];
        
        [contentView addSubview: likedImageView];
        [contentView addSubview: btn_download];
        [contentView addSubview: btn_like];
        [contentView addSubview: likeCountLabel];
        [contentView addSubview: timerImage];
        [contentView addSubview: passedTime];
        [cell addSubview: contentView];

        if(indexPath.row * 2 < [self.likedArray count])
        {
            InstagramMedia *media = [self.likedArray objectAtIndex: indexPath.row * 2];
            InstagramUser *user = media.user;
            NSInteger likeCount = media.likeCount;
            NSDate *postDate = media.createdTime;
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate: postDate];
            float min = interval / 60.0;
            float hrs = interval / 3600.0;
            NSString *postDateStr;
            if(hrs >= 1.0)
                postDateStr = [NSString stringWithFormat: @"%d h", (int)hrs];
            else
                postDateStr = [NSString stringWithFormat: @"%d m", (int)min];
            
            NSDictionary *feedImageDict = [media.images objectForKey: @"standard_resolution"];
            NSString *imageURL = [feedImageDict objectForKey: @"url"];
            
            likedImageView.imageURL = [NSURL URLWithString: imageURL];
            [likeCountLabel setText: [NSString stringWithFormat: @"%ld", likeCount]];
            [passedTime setText: postDateStr];

        }
        

        UIView *contentView1 = [[UIView alloc] initWithFrame: CGRectMake(contentView.frame.origin.x + contentView.frame.size.width+5, contentView.frame.origin.y, contentView.frame.size.width, contentView.frame.size.height)];
        AsyncImageView *likedImageView1 = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, contentView1.frame.size.width, contentView1.frame.size.height)];
        UIButton *btn_download1 = [[UIButton alloc] initWithFrame: CGRectMake(7,7,20,15)];
        UIButton *btn_like1 = [[UIButton alloc] initWithFrame: CGRectMake(10, likedImageView1.frame.size.height-20, 12, 12)];
        UILabel *likeCountLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(25, likedImageView1.frame.size.height-22, 30, 15)];
        UIImageView *timerImage1 = [[UIImageView alloc] initWithFrame: CGRectMake(likedImageView1.frame.size.width-50, likedImageView1.frame.size.height-20, 10, 10)];
        UILabel *passedTime1 = [[UILabel alloc] initWithFrame: CGRectMake(likedImageView1.frame.size.width-35, likedImageView1.frame.size.height-22, 35, 15)];
        [likeCountLabel1 setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
        [passedTime1 setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
        [likeCountLabel1 setTextColor: [UIColor whiteColor]];
        [passedTime1 setTextColor: [UIColor whiteColor]];
        [btn_download1 setImage: [UIImage imageNamed: @"ic_feed_download.png"] forState: UIControlStateNormal];
        btn_download1.tag = indexPath.row * 2 + 1;
        [btn_download1 addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];

        [btn_like1 setImage: [UIImage imageNamed: @"ic_feed_liked.png"] forState: UIControlStateNormal];
        btn_like1.tag = indexPath.row * 2 + 1;
        [btn_like1 addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];

        [timerImage1 setImage: [UIImage imageNamed: @"ic_feed_schedule.png"]];
        [contentView1 addSubview: likedImageView1];
        [contentView1 addSubview: btn_download1];
        [contentView1 addSubview: btn_like1];
        [contentView1 addSubview: likeCountLabel1];
        [contentView1 addSubview: timerImage1];
        [contentView1 addSubview: passedTime1];
        [cell addSubview: contentView1];

        if(indexPath.row * 2 + 1 < [self.likedArray count])
        {
            InstagramMedia *media1 = [self.likedArray objectAtIndex: indexPath.row * 2 + 1];
            NSInteger likeCount1 = media1.likeCount;
            NSDate *postDate1 = media1.createdTime;
            NSDate *now1 = [NSDate date];
            NSTimeInterval interval1 = [now1 timeIntervalSinceDate: postDate1];
            float min1 = interval1 / 60.0;
            float hrs1 = interval1 / 3600.0;
            NSString *postDateStr1;
            if(hrs1 >= 1.0)
                postDateStr1 = [NSString stringWithFormat: @"%d hr", (int)hrs1];
            else
                postDateStr1 = [NSString stringWithFormat: @"%d m", (int)min1];
            NSDictionary *feedImageDict1 = [media1.images objectForKey: @"standard_resolution"];
            NSString *imageURL1 = [feedImageDict1 objectForKey: @"url"];
            
            likedImageView1.imageURL = [NSURL URLWithString: imageURL1];
            [likeCountLabel1 setText: [NSString stringWithFormat: @"%ld", likeCount1]];
            [passedTime1 setText: postDateStr1];

        }

        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        return cell;
    }
    else if(tableView.tag == MEDIA_TABLE)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"mediaCell"];
        
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"mediaCell"];
        
        if(indexPath.row % 2 == 0)
        {
            if(indexPath.row == 0)
            {
                if([self.mediaArray count] == 0)
                    return cell;
                UIView *contentView = [[UIView alloc] initWithFrame: CGRectMake(self.leftAlign, 0, tableView.frame.size.width-self.leftAlign, 300)];
                AsyncImageView *mediaImage = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, contentView.frame.size.width, 250)];
                AsyncImageView *profileImage = [[AsyncImageView alloc] initWithFrame: CGRectMake(20, mediaImage.frame.size.height-50, 40, 40)];
                UILabel *fullnameLabel = [[UILabel alloc] initWithFrame: CGRectMake(profileImage.frame.origin.x + profileImage.frame.size.width + 10, profileImage.frame.origin.y, 200, 20)];
//                    UIImageView *imageTimer = [[UIImageView alloc] initWithFrame: CGRectMake(profileImage.frame.origin.x + profileImage.frame.size.width + 10, profileImage.frame.origin.y+profileImage.frame.size.height - 6, 6, 6)];
//                    UILabel *postTimeLabel = [[UILabel alloc] initWithFrame: CGRectMake(imageTimer.frame.origin.x+3, imageTimer.frame.origin.y, 80, 15)];

//                    UIImageView *locationImage = [[UIImageView alloc] initWithFrame: CGRectMake(contentView.frame.size.width/2 + 10, postTimeLabel.frame.origin.y, 6,6)];
//                    UILabel *locationLabel = [[UILabel alloc] initWithFrame: CGRectMake(locationImage.frame.origin.x+9, locationImage.frame.origin.y, 100, 15)];
                UILabel *descLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, mediaImage.frame.origin.y + mediaImage.frame.size.height+10, contentView.frame.size.width-20, 50)];
                profileImage.layer.masksToBounds = YES;
                profileImage.layer.cornerRadius = 20;
                
                [fullnameLabel setFont: [UIFont fontWithName: @"OpenSans" size: 15.0]];
                [fullnameLabel setTextColor: [UIColor whiteColor]];
                [descLabel setFont: [UIFont fontWithName: @"OpenSans" size: 12.0]];
                [descLabel setNumberOfLines: 3];
                InstagramMedia *media = [self.mediaArray objectAtIndex: indexPath.row];
                NSDictionary *feedImageDict = [media.images objectForKey: @"standard_resolution"];
                NSString *imageURL = [feedImageDict objectForKey: @"url"];

                NSDictionary *dict = [self.activedAccounts objectAtIndex: self.accountPointer];
                NSString *insta_userfullname = [dict valueForKey: @"insta_userfullname"];
                NSString *profile_imageurl = [dict valueForKey: @"insta_userprofilepictureurl"];
                mediaImage.imageURL = [NSURL URLWithString: imageURL];
                profileImage.imageURL = [NSURL URLWithString: profile_imageurl];
                [fullnameLabel setText: insta_userfullname];
                
                [contentView addSubview: mediaImage];
                [contentView addSubview: profileImage];
                [contentView addSubview: fullnameLabel];
                [contentView addSubview: descLabel];
                [cell addSubview: contentView];
            }
            else
            {
                UIView *contentView = [[UIView alloc] initWithFrame: CGRectMake(5 + self.leftAlign, 5, tableView.frame.size.width-self.leftAlign-10, 300)];
                AsyncImageView *mediaImage = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
                
                
                InstagramMedia *media = [self.mediaArray objectAtIndex: (indexPath.row/2) * 3];
//                    InstagramUser *user = media.user;
                NSInteger likeCount = media.likeCount;
                NSDate *postDate = media.createdTime;
                NSDate *now = [NSDate date];
                NSTimeInterval interval = [now timeIntervalSinceDate: postDate];
                float min = interval / 60.0;
                float hrs = interval / 3600.0;
                NSString *postDateStr;
                if(hrs >= 1.0)
                    postDateStr = [NSString stringWithFormat: @"%d hr", (int)hrs];
                else
                    postDateStr = [NSString stringWithFormat: @"%d m", (int)min];
                NSDictionary *mediaDict = [media.images objectForKey: @"standard_resolution"];
                NSString *imageURL = [mediaDict objectForKey: @"url"];
                UIButton *btn_download = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 10, 15)];
                UIButton *btn_like = [[UIButton alloc] initWithFrame: CGRectMake(5, mediaImage.frame.size.height-20, 12, 12)];
                UILabel *likeCountLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, mediaImage.frame.size.height-20, 50, 10)];
                UIImageView *timerImage = [[UIImageView alloc] initWithFrame: CGRectMake(mediaImage.frame.size.width-36, mediaImage.frame.size.height-20, 12, 12)];
                UILabel *postTimeLabel = [[UILabel alloc] initWithFrame: CGRectMake(mediaImage.frame.size.width-28, mediaImage.frame.size.height-20, 28, 15)];
                [likeCountLabel setFont: [UIFont fontWithName: @"OpenSans" size: 8.0]];
                [postTimeLabel setFont: [UIFont fontWithName: @"OpenSans" size: 8.0]];
                
                [btn_download setImage:[UIImage imageNamed: @"ic_feed_download.png"] forState: UIControlStateNormal];
                [btn_like setImage: [UIImage imageNamed: @"ic_activity_like.png"] forState: UIControlStateNormal];
                [likeCountLabel setText: [NSString stringWithFormat: @"%ld", likeCount]];
                [timerImage setImage: [UIImage imageNamed: @"ic_feed_schedule.png"]];
                [postTimeLabel setText: postDateStr];
                
                btn_download.tag = (indexPath.row/2) * 3;
                [btn_download addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];
                btn_like.tag = (indexPath.row/2) * 3;
                [btn_like addTarget: self action: @selector(btn_likeClicked:) forControlEvents: UIControlEventTouchUpInside];
                
                mediaImage.imageURL = [NSURL URLWithString: imageURL];
                
                [contentView addSubview: mediaImage];
                [contentView addSubview: btn_download];
                [contentView addSubview: btn_like];
                [contentView addSubview: likeCountLabel];
                [contentView addSubview: timerImage];
                [contentView addSubview: postTimeLabel];
                
                [cell addSubview: contentView];
                
            }
        }
        else
        {
            UIView *contentView1 = [[UIView alloc] initWithFrame: CGRectMake(5 + self.leftAlign, 5, (tableView.frame.size.width-self.leftAlign - 15)/2, 150)];
            [cell addSubview: contentView1];
            AsyncImageView *mediaImage = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, contentView1.frame.size.width, contentView1.frame.size.height)];
            UIButton *btn_download = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 15, 20)];
            UIButton *btn_like = [[UIButton alloc] initWithFrame: CGRectMake(5, mediaImage.frame.size.height-20, 12, 12)];
            UILabel *likeCountLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, mediaImage.frame.size.height-22, 50, 15)];
            UIImageView *timerImage = [[UIImageView alloc] initWithFrame: CGRectMake(mediaImage.frame.size.width-60, mediaImage.frame.size.height-20, 10, 10)];
            UILabel *postTimeLabel = [[UILabel alloc] initWithFrame: CGRectMake(mediaImage.frame.size.width-45, mediaImage.frame.size.height-22, 45, 15)];
            [likeCountLabel setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
            [postTimeLabel setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
            [btn_download setImage:[UIImage imageNamed: @"ic_feed_download.png"] forState: UIControlStateNormal];
            [btn_like setImage: [UIImage imageNamed: @"ic_activity_like.png"] forState: UIControlStateNormal];
            [timerImage setImage: [UIImage imageNamed: @"ic_feed_schedule.png"]];
            [postTimeLabel setTextColor: [UIColor whiteColor]];
            [likeCountLabel setTextColor: [UIColor whiteColor]];
            btn_download.tag = indexPath.row + indexPath.row / 2;
            btn_like.tag = indexPath.row + indexPath.row / 2;
            [btn_download addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];
            [btn_like addTarget: self action: @selector(btn_likeClicked:) forControlEvents: UIControlEventTouchUpInside];
            
            [contentView1 addSubview: mediaImage];
            [contentView1 addSubview: btn_download];
            [contentView1 addSubview: btn_like];
            [contentView1 addSubview: likeCountLabel];
            [contentView1 addSubview: timerImage];
            [contentView1 addSubview: postTimeLabel];
            [cell addSubview: contentView1];
            
            if(indexPath.row+indexPath.row/2 < [self.mediaArray count])
            {
                InstagramMedia *media = [self.mediaArray objectAtIndex: indexPath.row+indexPath.row/2];
//                    InstagramUser *user = media.user;
                NSInteger likeCount = media.likeCount;
                NSDate *postDate = media.createdTime;
                NSDate *now = [NSDate date];
                NSTimeInterval interval = [now timeIntervalSinceDate: postDate];
                float min = interval / 60.0;
                float hrs = interval / 3600.0;
                NSString *postDateStr;
                if(hrs >= 1.0)
                    postDateStr = [NSString stringWithFormat: @"%d hr", (int)hrs];
                else
                    postDateStr = [NSString stringWithFormat: @"%d m", (int)min];
                NSDictionary *mediaDict = [media.images objectForKey: @"standard_resolution"];
                NSString *imageURL = [mediaDict objectForKey: @"url"];
                
                mediaImage.imageURL = [NSURL URLWithString: imageURL];
                [postTimeLabel setText: postDateStr];
                [likeCountLabel setText: [NSString stringWithFormat: @"%ld", (long)likeCount]];

            }
            else
                [contentView1 setHidden: YES];
            
            
            UIView *contentView2 = [[UIView alloc] initWithFrame: CGRectMake(5 + contentView1.frame.origin.x + contentView1.frame.size.width, contentView1.frame.origin.y, contentView1.frame.size.width, contentView1.frame.size.height)];
            
            AsyncImageView *mediaImage1 = [[AsyncImageView alloc] initWithFrame: CGRectMake(0, 0, contentView2.frame.size.width, contentView2.frame.size.height)];
            UIButton *btn_download1 = [[UIButton alloc] initWithFrame: CGRectMake(5, 5, 10, 15)];
            UIButton *btn_like1 = [[UIButton alloc] initWithFrame: CGRectMake(5, mediaImage1.frame.size.height-20, 12, 12)];
            UILabel *likeCountLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(20, mediaImage1.frame.size.height-22, 50, 15)];
            UIImageView *timerImage1 = [[UIImageView alloc] initWithFrame: CGRectMake(mediaImage1.frame.size.width-60, mediaImage1.frame.size.height-20, 10, 10)];
            UILabel *postTimeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(mediaImage1.frame.size.width-45, mediaImage1.frame.size.height-22, 45, 15)];
            [likeCountLabel1 setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
            [postTimeLabel1 setFont: [UIFont fontWithName: @"OpenSans" size: 10.0]];
            [postTimeLabel1 setTextColor: [UIColor whiteColor]];
            [likeCountLabel1 setTextColor: [UIColor whiteColor]];

            
            [btn_download1 setImage:[UIImage imageNamed: @"ic_feed_download.png"] forState: UIControlStateNormal];
            [btn_like1 setImage: [UIImage imageNamed: @"ic_activity_like.png"] forState: UIControlStateNormal];
            [timerImage1 setImage: [UIImage imageNamed: @"ic_feed_schedule.png"]];
            [contentView2 addSubview: mediaImage1];
            [contentView2 addSubview: btn_download1];
            [contentView2 addSubview: btn_like1];
            [contentView2 addSubview: likeCountLabel1];
            [contentView2 addSubview: timerImage1];
            [contentView2 addSubview: postTimeLabel1];
            [cell addSubview: contentView2];
            
            btn_download1.tag = indexPath.row + indexPath.row / 2 + 1;
            btn_like1.tag = indexPath.row + indexPath.row / 2;
            [btn_download1 addTarget: self action: @selector(btn_downloadClicked:) forControlEvents: UIControlEventTouchUpInside];
            [btn_like1 addTarget: self action: @selector(btn_likeClicked:) forControlEvents: UIControlEventTouchUpInside];


            if(indexPath.row+indexPath.row/2+1 < [self.mediaArray count])
            {
                InstagramMedia *media1 = [self.mediaArray objectAtIndex: indexPath.row+indexPath.row/2 + 1];
//                    InstagramUser *user1 = media1.user;
                NSInteger likeCount1 = media1.likeCount;
                NSDate *postDate1 = media1.createdTime;
                NSDate *now1 = [NSDate date];
                NSTimeInterval interval1 = [now1 timeIntervalSinceDate: postDate1];
                float min1 = interval1 / 60.0;
                float hrs1 = interval1 / 3600.0;
                NSString *postDateStr1;
                if(hrs1 >= 1.0)
                    postDateStr1 = [NSString stringWithFormat: @"%d hr", (int)hrs1];
                else
                    postDateStr1 = [NSString stringWithFormat: @"%d m", (int)min1];
                NSDictionary *mediaDict1 = [media1.images objectForKey: @"standard_resolution"];
                NSString *imageURL1 = [mediaDict1 objectForKey: @"url"];
                mediaImage1.imageURL = [NSURL URLWithString: imageURL1];
                [likeCountLabel1 setText: [NSString stringWithFormat: @"%ld", (long)likeCount1]];
                [postTimeLabel1 setText: postDateStr1];

            }
            else
            {
                [contentView2 setHidden: YES];
            }
        }

        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"menuCell"];
        [cell setBackgroundColor: [UIColor colorWithRed: 0.37 green: 0.38 blue: 0.4 alpha: 1]];
        UILabel *menuTitle = [[UILabel alloc] initWithFrame: CGRectMake(60, 10, 100, 25)];
        UIImageView *menuIcon = [[UIImageView alloc] initWithFrame: CGRectMake(20, 10, 25, 25)];
        [menuTitle setFont: [UIFont fontWithName: @"OpenSans" size: 13.0]];
        [menuTitle setTextColor: [UIColor whiteColor]];
        if(indexPath.row == 0)
        {
            [menuTitle setText: @"Feed"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_feed.png"]];
            UIImageView *alertIcon = [[UIImageView alloc] initWithFrame: CGRectMake(110, 10, 40, 30)];
            [alertIcon setImage: [UIImage imageNamed: @"ic_feed_alert.png"]];
//                [cell addSubview: alertIcon];
        }
        else if(indexPath.row == 1)
        {
            [menuTitle setText: @"Liked"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_liked.png"]];
            UIImageView *alertIcon = [[UIImageView alloc] initWithFrame: CGRectMake(110, 10, 40, 30)];
            [alertIcon setImage: [UIImage imageNamed: @"ic_feed_alert.png"]];
//                [cell addSubview: alertIcon];
        }
        else if(indexPath.row == 2)
        {
            [menuTitle setText: @"My Photo"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_myphoto.png"]];
            UIImageView *alertIcon = [[UIImageView alloc] initWithFrame: CGRectMake(140, 10, 40, 30)];
            [alertIcon setImage: [UIImage imageNamed: @"ic_feed_alert.png"]];
//                [cell addSubview: alertIcon];
        }
        else if(indexPath.row == 3)
        {
            [menuTitle setText: @"Downloads"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_download.png"]];
        }
        else if(indexPath.row == 4)
        {
            [menuTitle setText: @"Post Photo"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_post.png"]];
        }
        else if(indexPath.row == 5)
        {
            [menuTitle setText: @"Schedule Photo"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_schedule.png"]];
        }
        else if(indexPath.row == 6)
        {
            [menuTitle setText: @"Account"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_logout.png"]];
        }
        else if(indexPath.row == 7)
        {
            [menuTitle setText: @"Logout"];
            [menuIcon setImage: [UIImage imageNamed: @"ic_feed_logout.png"]];
        }
        [cell addSubview: menuIcon];
        [cell addSubview: menuTitle];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == MENU_TABLE)
    {
        [tableView deselectRowAtIndexPath: indexPath animated: NO];
        if(indexPath.row == 0)
        {
            [self hideMenu];
            [self showAllFeeds];
        }
        else if(indexPath.row == 1)
        {
            [self hideMenu];
            [self showLikedStatus];
        }
        else if(indexPath.row == 2)
        {
            [self hideMenu];
            [self showUserMedia];
        }
        else if(indexPath.row == 3)
        {
            [self hideMenu];
            [self showDownloadView];
        }
        else if(indexPath.row == 4)
        {
            [self hideMenu];
            [self postPicture];
        }
        else if(indexPath.row == 5)
        {
            [self hideMenu];
//            [self schedulePhoto];
        }
        else if(indexPath.row == 6)
        {
            [self hideMenu];
            [self showAccountsView];
        }
        else if(indexPath.row == 7)
        {
            [self dismissViewControllerAnimated: YES completion: nil];
        }

    }
}

-(void)serverResponce:(NSArray*)respDict
{
    if(respDict)
    {
        if(respDict.count == 1)
        {
            NSString *info = [respDict valueForKey: @"info"];
            NSString *result = [respDict valueForKey: @"result"];
            NSString *request = [respDict valueForKey: @"request"];
            NSLog(@"Result:%@", result);
            NSLog(@"Info:%@", info);
            NSLog(@"Request:%@", request);
           [self showMessage: [NSString stringWithFormat: @"%@", info] withTitle: @"Warning"];
        }
        else if(respDict.count > 1)
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
                self.activedAccounts = nil;
                self.activedAccounts = [NSMutableArray array];
                for(int i = 1; i < respDict.count; i ++)
                {
                    NSMutableDictionary *accountDict = [respDict objectAtIndex: i];
                    [self.appDelegate.instaAccounts addObject: accountDict];
                    NSString *active = [accountDict valueForKey: @"active"];
                    if([active isEqual: @"1"])
                        [self.activedAccounts addObject: accountDict];
                }
                
                if([self.appDelegate.instaAccounts count] > 0)
                    
                    [self showAllFeeds];

                else
                {
                    [self showMessage: @"You haven't any Instagram accounts registered. Please add one to use the app." withTitle: @"ManageGram"];
                }
            }
            
        }
    }
    
}

-(void)btn_downloadClicked:(id)sender
{
    UIButton *btnDownload = (UIButton*)sender;
    if(btnDownload.tag != -1)
    {
        InstagramMedia *media;
        if(self.feedTable.tag == FEEDS_TABLE)
        {
            media = [self.feedArray objectAtIndex: btnDownload.tag];
        }
        else if(self.feedTable.tag == LIKED_TABLE)
        {
            media = [self.likedArray objectAtIndex: btnDownload.tag];
        }
        else if(self.feedTable.tag == MEDIA_TABLE)
        {
            media = [self.mediaArray objectAtIndex: btnDownload.tag];
        }
        
        NSDictionary *mediaDict = [media.images objectForKey: @"standard_resolution"];
        NSString *mediaURL = [mediaDict objectForKey: @"url"];

        NSString *urlLastPathComponent = [[mediaURL componentsSeparatedByString:@"/"] lastObject];
        NSString *fileName = [MZUtility getUniqueFileNameForName:urlLastPathComponent];
        [self.downloadingViewObj addDownloadTask:fileName fileURL:mediaURL];
        
    }

}

-(void)btn_likeClicked:(id)sender
{
    UIButton *btnDownload = (UIButton*)sender;
    if(btnDownload.tag != -1)
    {
        InstagramMedia *media;
        if(self.feedTable.tag == FEEDS_TABLE)
        {
            media = [self.feedArray objectAtIndex: btnDownload.tag];
        }
        else if(self.feedTable.tag == LIKED_TABLE)
        {
            media = [self.likedArray objectAtIndex: btnDownload.tag];
        }
        else if(self.feedTable.tag == MEDIA_TABLE)
        {
            media = [self.mediaArray objectAtIndex: btnDownload.tag];
        }
        
        NSDictionary *mediaDict = [media.images objectForKey: @"standard_resolution"];
        NSString *mediaURL = [mediaDict objectForKey: @"url"];
        
    }

}

#pragma mark - MZDownloadManager Delegates -
-(void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask
{
//    [self updateDownloadingTabBadge];
}
-(void)downloadRequestFinished:(NSString *)fileName
{
//    [self updateDownloadingTabBadge];
//    NSString *docDirectoryPath = [fileDest stringByAppendingPathComponent:fileName];
//    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadCompletedNotif object:docDirectoryPath];
}
-(void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask
{
//    [self updateDownloadingTabBadge];
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


@implementation HomeViewController (Private)

- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController: (CustomTransitioningViewController*)viewController{
    
    if (SYSTEM_VERSION_GREATER_THAN_7) {
        viewController.transition = transition;
        [self presentViewController: viewController animated: YES completion: nil];
    } else {
        [self.transitionController presentViewController: viewController animated: YES completion: nil];
//        [self.transitionController pushViewController:viewController withTransition:transition];
    }
}
@end
