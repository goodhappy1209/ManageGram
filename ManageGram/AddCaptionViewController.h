//
//  UIViewController+AddCaptionViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/21/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCaptionViewController : UIViewController
{
    IBOutlet UIImageView *postImage;
    IBOutlet UITextView *captionTextView;
}

-(IBAction)btn_cancelClicked:(id)sender;
-(IBAction)btn_nextClicked:(id)sender;

@end
