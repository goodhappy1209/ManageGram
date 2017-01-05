//
//  UIViewController+MyProfileViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/17/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstagramAuthDelegate <NSObject>

- (void)instagramAuthLoadFailed:(NSError *)error;

- (void)instagramAuthSucceeded:(NSString *)token;

- (void)instagramAuthFailed:(NSString *)error
                errorReason:(NSString *)errorReason
           errorDescription:(NSString *)errorMessage;
@end

@interface MyProfileViewController : UIViewController <InstagramAuthDelegate>
{
    IBOutlet UIButton *btn_back;
    IBOutlet UITableView *profileTable;
}

-(void)serverResponce:(NSArray*)respDict;

-(IBAction)btn_backClicked:(id)sender;

@end
