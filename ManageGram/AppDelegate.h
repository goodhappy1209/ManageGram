//
//  AppDelegate.h
//  ManageGram
//
//  Created by YangGuo on 10/9/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *fbSession;
@property (strong, nonatomic) NSString *userFirstName;
@property (strong, nonatomic) NSString *userLastName;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) UIImage *userProfileImage;
@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *userProfileImageUrl;
@property (assign, nonatomic) int       registerType;
@property (assign, nonatomic) int       loginType;
@property (strong, nonatomic) NSString *lastaccessToken;
@property (strong, nonatomic) NSMutableArray *accessTokenArray;
@property(nonatomic,strong) NSMutableArray *instaAccounts;

@property (nonatomic,strong) NSData *selectedImageData;
@property (nonatomic,strong) NSURL *selectedFileURL;

@property (nonatomic,strong) NSMutableArray *activatedAccounts;

-(void)callURL:(NSString*)postURL action:(NSString*)postStr delegate:(id)delegate;
-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@property (copy) void (^backgroundSessionCompletionHandler)();

@end

