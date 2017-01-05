//
//  UIViewController+PhotoViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/22/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController 
{
    IBOutlet UIImageView *imageView;
}

@property(nonatomic,strong) NSString *imagePath;

-(IBAction)btn_backClicked:(id)sender;

@end
