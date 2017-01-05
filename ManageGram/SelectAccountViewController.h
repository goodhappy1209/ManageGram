//
//  UIViewController+SelectAccountViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/21/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAccountViewController : UIViewController 
{
    IBOutlet UITableView *accountTable;
}

-(IBAction)btn_nextClicked:(id)sender;

@end
