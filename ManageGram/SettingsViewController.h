//
//  UIViewController+SettingsViewController.h
//  ManageGram
//
//  Created by YangGuo on 10/16/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitioningViewController.h"
#import "CustomTransitionController.h"

@interface SettingsViewController : CustomTransitioningViewController
{
    IBOutlet UITableView *settingsTable;
    IBOutlet UILabel *titleLabel;
}

-(IBAction)btn_backClicked:(id)sender;

@end
