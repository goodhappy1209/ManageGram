//
//  ViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/9/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CustomTransition.h"
#import "CustomDualTransition.h"
#import "CustomTransformTransition.h"
#import "CustomFlipTransition.h"
#import "CustomGlueTransition.h"
#import "CustomSwipeTransition.h"

@interface ViewController (Private)
- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController:(CustomTransitioningViewController*)viewController;
@end

@interface ViewController ()
{
    int helpScreenIndex;
}



@property(nonatomic, strong) NSMutableArray *helpScreenArray;
@property(nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;

    helpScreenIndex = 0;
    
    [self setupHelpScreens];
    
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeLeft:)] ;
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeRight:)];

    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];

}

-(void)dealloc
{
    self.helpScreenArray = nil;
    self.appDelegate = nil;
}

-(void)setupHelpScreens
{
    
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.helpScreenArray = [NSMutableArray array];
    
    //Setup first Help Screen
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float margin = 28.0;
    UIView *view1 = [[UIView alloc] initWithFrame: CGRectMake(margin, 80, screenWidth - 2 * margin, screenHeight - 200)];
    [view1 setBackgroundColor: [UIColor whiteColor]];
    
    [self.helpScreenArray addObject: view1];
    
    for(int i = 1; i < 4; i ++)
    {
        UIView *prevView = [self.helpScreenArray objectAtIndex: i - 1];
        UIView *view = [[UIView alloc] initWithFrame: CGRectMake(prevView.frame.origin.x + prevView.frame.size.width + margin / 2, 80, screenWidth - 2 * margin, screenHeight - 200)];
        [view setBackgroundColor: [UIColor whiteColor]];
        [self.helpScreenArray addObject: view];
    }
    
    for(int i = 0; i < 4; i ++)
    {
        UIView *helpScreen = [self.helpScreenArray objectAtIndex: i];
        [self.view addSubview: helpScreen];
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 150, view1.frame.size.width - 20, 150)];
        [label setText: [NSString stringWithFormat: @"%@%d", @"Step", i+1]];
        [label setTextAlignment: NSTextAlignmentCenter];
        [label setFont: [UIFont fontWithName: @"OpenSans" size: 15.0]];
        label.numberOfLines = 4;
        [helpScreen addSubview: label];

    }
    
    for (int i = 1; i < 4; i ++)
    {
        UIView *helpScreen = [self.helpScreenArray objectAtIndex: i];
        [helpScreen setHidden: YES];
    }
    
}

-(void)oneFingerSwipeLeft:(UITapGestureRecognizer*)recog
{
    float margin = 28.0;
    
    if(helpScreenIndex < 3)
        helpScreenIndex ++;
    else return;
    
    NSLog(@"Next page");
    
    UIView *currentView = [self.helpScreenArray objectAtIndex: helpScreenIndex - 1];
    UIView *nextView = [self.helpScreenArray objectAtIndex: helpScreenIndex];
    [nextView setHidden: NO];
    [currentView setHidden: NO];

    CATransform3D oldTransform = currentView.layer.transform;
    
    [UIView animateWithDuration:1.0
     
                     animations:^{
                         
                         CATransform3D t = CATransform3DIdentity;
                         t.m34 = 1.0/ -500;
//                         t = CATransform3DRotate(t, radianFromDegree(5.0f), 0.0f,0.0f, 1.0f);
                         t = CATransform3DTranslate(t, -nextView.frame.size.width * 2 , 0.0f, -400.0);
//                         t = CATransform3DRotate(t, radianFromDegree(-45), 0.0f,1.0f, 0.0f);
//                         t = CATransform3DRotate(t, radianFromDegree(50), 1.0f,0.0f, 0.0f);
                         t = CATransform3DScale(t, 0.2f, 0.2f, 0.2f);
                         currentView.layer.transform = t;
                         currentView.layer.opacity = 0.0;
                         
                         for (int i = helpScreenIndex; i < 4; i ++)
                         {
                             UIView *view = [self.helpScreenArray objectAtIndex: i];
                             [view setFrame: CGRectMake(view.frame.origin.x - (view.frame.size.width + margin / 2), view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
                         }
                         
                         for (int i = 0; i < helpScreenIndex - 1; i ++)
                         {
                             UIView *view = [self.helpScreenArray objectAtIndex: i];
                             [view setFrame: CGRectMake(view.frame.origin.x - (view.frame.size.width + margin / 2), view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
                         }

                         
                     }
                     completion:^(BOOL finished) {
                         currentView.layer.transform = oldTransform;
                         currentView.layer.opacity = 1.0;
                         [currentView setHidden: YES];
                         [currentView setFrame: CGRectMake(currentView.frame.origin.x - (currentView.frame.size.width+margin/2), currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height)];
                     }];
    
    [self showHelpScreen];

    
}

-(void)oneFingerSwipeRight:(UITapGestureRecognizer*)recog
{
    float margin = 28.0;
    
    
    if(helpScreenIndex > 0)
        helpScreenIndex --;
    else return;
    
    NSLog(@"Prev page");
    
    
    UIView *currentView = [self.helpScreenArray objectAtIndex: helpScreenIndex + 1];
    UIView *nextView = [self.helpScreenArray objectAtIndex: helpScreenIndex];
    [nextView setHidden: NO];
    [currentView setHidden: NO];
    CATransform3D oldTransform = currentView.layer.transform;

    [UIView animateWithDuration:1.0
     
                     animations:^{
                         
                         CATransform3D t = CATransform3DIdentity;
                         t.m34 = 1.0/ -500;
//                         t = CATransform3DRotate(t, radianFromDegree(5.0f), 0.0f,0.0f, 1.0f);
                         t = CATransform3DTranslate(t, nextView.frame.size.width * 2 , 0.0f, -400.0);
//                         t = CATransform3DRotate(t, radianFromDegree(-45), 0.0f,1.0f, 0.0f);
//                         t = CATransform3DRotate(t, radianFromDegree(50), 1.0f,0.0f, 0.0f);
                         t = CATransform3DScale(t, 0.2f, 0.2f, 0.2f);
                         currentView.layer.transform = t;
                         currentView.layer.opacity = 0.0;
                         
                         for (int i = 0; i <= helpScreenIndex; i ++)
                         {
                             UIView *view = [self.helpScreenArray objectAtIndex: i];
                             [view setFrame: CGRectMake(view.frame.origin.x + (view.frame.size.width + margin / 2), view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
                         }
                         
                         for (int i = helpScreenIndex + 2; i < 4; i ++ )
                         {
                             UIView *view = [self.helpScreenArray objectAtIndex: i];
                             [view setFrame: CGRectMake(view.frame.origin.x + (view.frame.size.width + margin / 2), view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         currentView.layer.transform = oldTransform;
                         currentView.layer.opacity = 1.0;
                         [currentView setHidden: YES];
                         [currentView setFrame: CGRectMake(currentView.frame.origin.x + (currentView.frame.size.width+margin/2), currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height)];

                     }];

    [self showHelpScreen];
}

-(void)showHelpScreen
{
    for(int i = 0; i < 4; i ++)
    {
        UIImageView *imageView = [imageArray objectAtIndex: i];
        [imageView setImage: [UIImage imageNamed: @"white_circle_blank.png"]];
    }
    UIImageView *imageView = [imageArray objectAtIndex: helpScreenIndex];
    [imageView setImage: [UIImage imageNamed: @"white_circle.png"]];
    
    
}

-(IBAction)btn_loginClicked:(id)sender
{
    CustomTransition * animation = [[CustomGlueTransition alloc] initWithDuration: 0.7 orientation:_orientation sourceRect:self.view.frame];
    
    LoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier: @"loginView"];
    
    [self _pushViewControllerWithTransition:animation nextViewController: loginView];
}

-(IBAction)btn_getStartedClicked:(id)sender
{
    CustomTransition * animation = [[CustomSwipeTransition alloc] initWithDuration: 0.7 orientation:_orientation sourceRect:self.view.frame];

    RegistrationViewController *registerView = [self.storyboard instantiateViewControllerWithIdentifier: @"registrationView"];
    [self _pushViewControllerWithTransition:animation nextViewController: registerView];
}


-(void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
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


@implementation ViewController (Private)

- (void)_pushViewControllerWithTransition:(CustomTransition *)transition nextViewController: (CustomTransitioningViewController*)viewController{
    
    if (SYSTEM_VERSION_GREATER_THAN_7) {
        viewController.transition = transition;
        [self presentViewController: viewController animated: YES completion: nil];
    } else {
        [self.transitionController pushViewController:viewController withTransition:transition];
    }
}
@end
