//
//  Constants.h
//  ManageGram
//
//  Created by YangGuo on 10/9/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#ifndef ManageGram_Constants_h
#define ManageGram_Constants_h

//###############  Backend Service ###############

#define registrationLink @"http://www.managegram.com/reg_action.php?"
#define loginLink        @"http://www.managegram.com/login_action.php?"
#define manageInstaUser  @"http://www.managegram.com/manage_instauser.php?"

//#define registrationLink @"http://192.168.0.74/krazzymobile/reg_action.php?"
//#define loginLink        @"http://192.168.0.74/krazzymobile/login_action.php?"
//#define manageInstaUser  @"http://192.168.0.74/krazzymobile/manage_instauser.php?"

#define LOGIN_WITH_FACEBOOK 100
#define LOGIN_WITH_EMAIL    200

#define FEEDS_TABLE     301
#define LIKED_TABLE     302
#define MEDIA_TABLE     303
#define MENU_TABLE      304

#define DOWNLOADING_TABLE  0
#define DOWNLOADED_TABLE   1

#define iPhone4S ([UIScreen mainScreen].bounds.size.height==480)?1:0
#define iPhone5S ([UIScreen mainScreen].bounds.size.height==568)?1:0
#define iPhone6  ([UIScreen mainScreen].bounds.size.height==667)?1:0
#define iPhone6P ([UIScreen mainScreen].bounds.size.height==736)?1:0

#define SYSTEM_VERSION_GREATER_THAN_7 ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] == NSOrderedDescending)

#endif
