//
//  UIViewController+AddInstagramACViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/10/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitioningViewController.h"
#import "CustomTransitionController.h"

@protocol InstagramAuthDelegate <NSObject>

- (void)instagramAuthLoadFailed:(NSError *)error;

- (void)instagramAuthSucceeded:(NSString *)token;

- (void)instagramAuthFailed:(NSString *)error
                errorReason:(NSString *)errorReason
           errorDescription:(NSString *)errorMessage;
@end

@interface AddInstagramACViewController : CustomTransitioningViewController<InstagramAuthDelegate>
{
    IBOutlet UIButton *btn_skip;
    CGFloat _duration;
    CustomTransitionOrientation _orientation;
}

-(IBAction)btn_backClicked:(id)sender;
-(IBAction)btn_addClicked:(id)sender;
-(IBAction)btn_skipClicked:(id)sender;

-(void)serverResponce:(NSArray*)respDict;

@end
