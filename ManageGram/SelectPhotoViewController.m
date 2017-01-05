//
//  UIViewController+PostPhotoViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/21/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "SelectPhotoViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AddCaptionViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
//#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

@interface SelectPhotoViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong) AppDelegate *appDelegate;
@property (strong, atomic) ALAssetsLibrary* library;

@end


@implementation SelectPhotoViewController: UIViewController

@synthesize library;

-(void)viewDidLoad
{
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.library = [[ALAssetsLibrary alloc] init];

    [self performSelector: @selector(showActionSheet) withObject: nil afterDelay: 1];
}

-(void)viewDidAppear:(BOOL)animated
{

}

-(void)dealloc
{
    self.library = nil;

}

-(void)viewTap
{
    [self showActionSheet];
}

-(void)showActionSheet
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"Take Photo",@"Import from Library",nil];
    
    [actionSheet showFromRect: CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width,200) inView: self.view animated: YES];

}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
        [self dismissViewControllerAnimated: NO completion: nil];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0:
        {
            //Cancel button, Do nothing
            break;
        }
        case 1:
        {
            [self takePhoto];
            break;
        }
        case 2:
        {
            [self selectPhoto];
            break;
        }
            break;
    }
    
}


- (void)selectPhoto
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //picker.navigationBar.barStyle = UIBarStyleDefault;
    //picker.navigationBar.tintColor = [UIColor blackColor];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
//    if (self.media_type == 1)
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    else if (self.media_type == 2)
//        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (void)takePhoto{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated: NO completion: ^void(){

        [self showActionSheet];
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.appDelegate.selectedImageData = [[NSData alloc] init];
    
    if ([[info valueForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"])
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.appDelegate.selectedImageData = UIImagePNGRepresentation([self imageByScalingProportionallyToSize: CGSizeMake(400, 400) withOriginalImage:chosenImage]);
        
//        [self.library saveImage:chosenImage toAlbum:@"Post Images" withCompletionBlock:^(NSError *error) {
//            if (error!=nil) {
//                NSLog(@"Big error: %@", [error description]);
//            }
//        }];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES);
        NSString* docDirPath = [paths lastObject];

//        NSString *docDirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filePath = [docDirPath stringByAppendingPathComponent:@"/image.igo"];
        [[NSFileManager defaultManager] removeItemAtPath: filePath error: nil];
        [UIImagePNGRepresentation(chosenImage) writeToFile:filePath atomically:YES];
        self.appDelegate.selectedFileURL = [NSURL fileURLWithPath: filePath];
    }
    else if ([[info valueForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.movie"])
    {
        NSURL *videoUrl = [NSURL URLWithString: [info objectForKey:UIImagePickerControllerMediaURL]];
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL: videoUrl options:nil];
        CMTime duration = sourceAsset.duration;
        float seconds = CMTimeGetSeconds(duration);
        if(seconds <= 300)
        {
//            self.appDelegate.selectedFileURL = [info valueForKey:@"UIImagePickerControllerReferenceURL"];
            self.appDelegate.selectedImageData = [NSData dataWithContentsOfURL: videoUrl];
        }
        else
        {
            NSLog(@"Huge file.");
        }
        NSLog(@"Seconds: %0.2f", seconds);
        
    }
    
    [picker dismissViewControllerAnimated:YES completion: ^void(){
        [self postImage];
        
    }];
    
    
}

- (void)postImage
{
    AddCaptionViewController *captionView = [self.storyboard instantiateViewControllerWithIdentifier: @"addcaptionView"];
    [self presentViewController: captionView animated: NO completion: nil];

}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize withOriginalImage:(UIImage *)origin {
    
    UIImage *sourceImage = origin;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    return newImage ;
}


-(void)didReceiveMemoryWarning
{
    
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
