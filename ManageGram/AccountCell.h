//
//  UITableViewCell+AccountCell.h
//  ManageGram
//
//  Created by YangGuo on 10/21/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface AccountCell : UITableViewCell

@property(nonatomic,weak) IBOutlet AsyncImageView *profileImageView;
@property(nonatomic,weak) IBOutlet UILabel *fullnameLabel;
@property(nonatomic,weak) IBOutlet UILabel *usernameLabel;
@property(nonatomic,weak) IBOutlet UIButton *btn_check;

@end
