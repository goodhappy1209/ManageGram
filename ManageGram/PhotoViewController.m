//
//  UIViewController+PhotoViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/22/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "PhotoViewController.h"


@implementation PhotoViewController : UIViewController

-(void)viewDidLoad
{
    
}

-(void)dealloc
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [imageView setImage: [UIImage imageWithContentsOfFile: self.imagePath]];
}

-(void)didReceiveMemoryWarning
{
    
}

-(IBAction)btn_backClicked:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
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
