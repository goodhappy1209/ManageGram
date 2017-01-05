//
//  UIViewController+DownloadViewController.m
//  ManageGram
//
//  Created by YangGuo on 10/20/14.
//  Copyright (c) 2014 3wmedia. All rights reserved.
//

#import "DownloadManageViewController.h"
#import "PhotoViewController.h"
#import "DownloadingCell.h"
#import "AppDelegate.h"
#import "MZUtility.h"
#import "Constants.h"

NSString * const kMZDownloadKeyURL = @"URL";
NSString * const kMZDownloadKeyStartTime = @"startTime";
NSString * const kMZDownloadKeyFileName = @"fileName";
NSString * const kMZDownloadKeyProgress = @"progress";
NSString * const kMZDownloadKeyTask = @"downloadTask";
NSString * const kMZDownloadKeyStatus = @"requestStatus";
NSString * const kMZDownloadKeyDetails = @"downloadDetails";
NSString * const kMZDownloadKeyResumeData = @"resumedata";

NSString * const RequestStatusDownloading = @"RequestStatusDownloading";
NSString * const RequestStatusPaused = @"RequestStatusPaused";
NSString * const RequestStatusFailed = @"RequestStatusFailed";


@interface DownloadManageViewController () <NSURLSessionDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    NSIndexPath *selectedIndexPath;
    UIActionSheet *actionSheetRetry;
    UIActionSheet *actionSheetPause;
    UIActionSheet *actionSheetStart;
    
    NSMutableArray *downloadedFilesArray;
    NSFileManager *fileManger;
    NSIndexPath *selectedIndexPath1;

}


@end

@implementation DownloadManageViewController
@synthesize downloadingArray, downloadTableView, sessionManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    actionSheetRetry = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Retry",@"Delete", nil];
    actionSheetRetry.tag = 0;
    
    actionSheetPause = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Pause",@"Delete", nil];
    actionSheetPause.tag = 0;
    
    actionSheetStart = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start",@"Delete", nil];
    actionSheetStart.tag = 0;
    
    
    downloadedFilesArray = [[NSMutableArray alloc] init];
    fileManger = [NSFileManager defaultManager];
    NSError *error;
    downloadedFilesArray = [[fileManger contentsOfDirectoryAtPath:fileDest error:&error] mutableCopy];
    
    if([downloadedFilesArray containsObject:@".DS_Store"])
        [downloadedFilesArray removeObject:@".DS_Store"];

    if(error && error.code != NSFileReadNoSuchFileError)
        [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
    else
        [self.downloadedTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinishedNotification:) name:DownloadCompletedNotif object:nil];
    
//    UIFont *font = [UIFont fontWithName: @"PragmataPro" size: 14.0];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
//                                                           forKey:UITextAttributeFont];
//    [segmentControl setTitleTextAttributes:attributes
//                                  forState:UIControlStateNormal];

    [self.downloadTableView setHidden: NO];
    [self.downloadTableView reloadData];
    [self.downloadedTableView setHidden: YES];
    [self.downloadedTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [segmentControl addTarget:self action:@selector(typeSelected:) forControlEvents:UIControlEventValueChanged];
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadCompletedNotif object:nil];
    
}

-(IBAction)btn_backClicked:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - My Methods -
- (void)deleteItemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [downloadedFilesArray objectAtIndex:indexPath.row];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",fileDest,fileName]];
    NSError *error;
    BOOL isDeletedSucces = [fileManger removeItemAtURL:fileURL error:&error];
    if(isDeletedSucces)
    {
        [downloadedFilesArray removeObject:fileName];
        [self.downloadedTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"Error occured while deleting file:\n%@",error.localizedDescription];
        [MZUtility showAlertViewWithTitle:kAlertTitle msg:errorMsg];
    }
}

- (void)renameFileTo:(NSString *)fileName
{
    NSString *oldFilePath = [NSString stringWithFormat:@"%@/%@",fileDest,[downloadedFilesArray objectAtIndex:selectedIndexPath1.row]];
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@.%@",fileDest,fileName,oldFilePath.pathExtension];
    
    NSError *error;
    BOOL isRenamedSuccess = [fileManger moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
    
    if(isRenamedSuccess)
    {
        NSString *newFileName = [NSString stringWithFormat:@"%@.%@",fileName,newFilePath.pathExtension];
        [downloadedFilesArray replaceObjectAtIndex:selectedIndexPath1.row withObject:newFileName];
        [self.downloadedTableView reloadRowsAtIndexPaths:@[selectedIndexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"Error occured while renaming file:\n%@",error.localizedDescription];
        
        if(error.code == NSFileWriteFileExistsError)
            [MZUtility showAlertViewWithTitle:kAlertTitle msg:@"File already exists with the same name"];
        else
            [MZUtility showAlertViewWithTitle:kAlertTitle msg:errorMsg];
    }
}

#pragma mark - My IBActions -
- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender
{
    if(self.downloadedTableView.isEditing)
    {
        [sender setTitle:@"Edit"];
        [sender setStyle:UIBarButtonItemStylePlain];
        [self.downloadedTableView setEditing:NO animated:YES];
    }
    else
    {
        [sender setTitle:@"Done"];
        [sender setStyle:UIBarButtonItemStyleDone];
        [self.downloadedTableView setEditing:YES animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Methods -
- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.iosDevelopment.VDownloader.SimpleBackgroundTransfer.BackgroundSession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}
- (NSArray *)tasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)dataTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)uploadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)downloadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)tasksForKeyPath:(NSString *)keyPath
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [sessionManager getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return tasks;
}

- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL
{
    NSURL *url = [NSURL URLWithString:fileURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request];
    
    [downloadTask resume];
    
    NSMutableDictionary *downloadInfo = [NSMutableDictionary dictionary];
    [downloadInfo setObject:fileURL forKey:kMZDownloadKeyURL];
    [downloadInfo setObject:fileName forKey:kMZDownloadKeyFileName];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:downloadInfo options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [downloadTask setTaskDescription:jsonString];
    
    [downloadInfo setObject:[NSDate date] forKey:kMZDownloadKeyStartTime];
    [downloadInfo setObject:RequestStatusDownloading forKey:kMZDownloadKeyStatus];
    [downloadInfo setObject:downloadTask forKey:kMZDownloadKeyTask];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downloadingArray.count inSection:0];
    [downloadingArray addObject:downloadInfo];
    
    [downloadTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    if([self.delegate respondsToSelector:@selector(downloadRequestStarted:)])
        [self.delegate downloadRequestStarted:downloadTask];
}

- (void)populateOtherDownloadTasks
{
    NSArray *downloadTasks = [self downloadTasks];
    
    for(int i=0;i<downloadTasks.count;i++)
    {
        NSURLSessionDownloadTask *downloadTask = [downloadTasks objectAtIndex:i];
        
        NSError *error = nil;
        NSData *taskDescription = [downloadTask.taskDescription dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *downloadInfo = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
        
        if(error)
            NSLog(@"Error while retreiving json value: %@",error);
        
        [downloadInfo setObject:downloadTask forKey:kMZDownloadKeyTask];
        [downloadInfo setObject:[NSDate date] forKey:kMZDownloadKeyStartTime];
        
        NSURLSessionTaskState taskState = downloadTask.state;
        if(taskState == NSURLSessionTaskStateRunning)
            [downloadInfo setObject:RequestStatusDownloading forKey:kMZDownloadKeyStatus];
        else if(taskState == NSURLSessionTaskStateSuspended)
            [downloadInfo setObject:RequestStatusPaused forKey:kMZDownloadKeyStatus];
        else
            [downloadInfo setObject:RequestStatusFailed forKey:kMZDownloadKeyStatus];
        
        if(!downloadInfo)
        {
            [downloadTask cancel];
        }
        else
        {
            [self.downloadingArray addObject:downloadInfo];
        }
    }
}

/**Post local notification when all download tasks are finished
 */
- (void)presentNotificationForDownload:(NSString *)fileName
{
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState appCurrentState = [application applicationState];
    if(appCurrentState == UIApplicationStateBackground)
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"Downloading complete of %@",fileName];
        localNotification.alertAction = @"Background Transfer Download!";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = [application applicationIconBadgeNumber] + 1;
        [application presentLocalNotificationNow:localNotification];
    }
}
#pragma mark - NSURLSession Delegates -
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    for(NSMutableDictionary *downloadDict in downloadingArray)
    {
        if([downloadTask isEqual:[downloadDict objectForKey:kMZDownloadKeyTask]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = (double)downloadTask.countOfBytesReceived/(double)downloadTask.countOfBytesExpectedToReceive;
                
                NSTimeInterval downloadTime = -1 * [[downloadDict objectForKey:kMZDownloadKeyStartTime] timeIntervalSinceNow];
                
                float speed = totalBytesWritten / downloadTime;
                
                NSInteger indexOfDownloadDict = [downloadingArray indexOfObject:downloadDict];
                NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:indexOfDownloadDict inSection:0];
                DownloadingCell *cell = (DownloadingCell *)[downloadTableView cellForRowAtIndexPath:indexPathToRefresh];
                
                [cell.progressDownload setProgress:progress];
                
                NSMutableString *remainingTimeStr = [[NSMutableString alloc] init];
                
                unsigned long long remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten;
                
                int remainingTime = (int)(remainingContentLength / speed);
                int hours = remainingTime / 3600;
                int minutes = (remainingTime - hours * 3600) / 60;
                int seconds = remainingTime - hours * 3600 - minutes * 60;
                
                if(hours>0)
                    [remainingTimeStr appendFormat:@"%d Hours ",hours];
                if(minutes>0)
                    [remainingTimeStr appendFormat:@"%d Min ",minutes];
                if(seconds>0)
                    [remainingTimeStr appendFormat:@"%d sec",seconds];
                
                NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                             [MZUtility calculateFileSizeInUnit:(unsigned long long)totalBytesExpectedToWrite],
                                             [MZUtility calculateUnit:(unsigned long long)totalBytesExpectedToWrite]];
                
                NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"File Size: %@\nDownloaded: %.2f %@ (%.2f%%)\nSpeed: %.2f %@/sec\n",fileSizeInUnits,
                                                    [MZUtility calculateFileSizeInUnit:(unsigned long long)totalBytesWritten],
                                                    [MZUtility calculateUnit:(unsigned long long)totalBytesWritten],progress*100,
                                                    [MZUtility calculateFileSizeInUnit:(unsigned long long) speed],
                                                    [MZUtility calculateUnit:(unsigned long long)speed]
                                                    ];
                
                if(progress == 1.0)
                    [detailLabelText appendFormat:@"Time Left: Please wait..."];
                else
                    [detailLabelText appendFormat:@"Time Left: %@",remainingTimeStr];
                
                [cell.lblDetails setText:detailLabelText];
                
                [downloadDict setObject:[NSString stringWithFormat:@"%f",progress] forKey:kMZDownloadKeyProgress];
                [downloadDict setObject:detailLabelText forKey:kMZDownloadKeyDetails];
            });
            break;
        }
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    for(NSMutableDictionary *downloadInfo in downloadingArray)
    {
        if([[downloadInfo objectForKey:kMZDownloadKeyTask] isEqual:downloadTask])
        {
            NSString *fileName = [downloadInfo objectForKey:kMZDownloadKeyFileName];
            NSString *destinationPath = [fileDest stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
            NSLog(@"directory Path = %@",destinationPath);
            
            if (location) {
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
                if (error)
                    [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
            }
            
            break;
        }
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSInteger errorReasonNum = [[error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] integerValue];
    
    if([error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] &&
       (errorReasonNum == NSURLErrorCancelledReasonUserForceQuitApplication ||
        errorReasonNum == NSURLErrorCancelledReasonBackgroundUpdatesDisabled))
    {
        NSString *taskInfo = task.taskDescription;
        
        NSError *error = nil;
        NSData *taskDescription = [taskInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *taskInfoDict = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
        
        if(error)
            NSLog(@"Error while retreiving json value: %@",error);
        
        NSString *fileName = [taskInfoDict objectForKey:kMZDownloadKeyFileName];
        NSString *fileURL = [taskInfoDict objectForKey:kMZDownloadKeyURL];
        
        NSMutableDictionary *downloadInfo = [[NSMutableDictionary alloc] init];
        [downloadInfo setObject:fileName forKey:kMZDownloadKeyFileName];
        [downloadInfo setObject:fileURL forKey:kMZDownloadKeyURL];
        
        NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if(resumeData)
            task = [sessionManager downloadTaskWithResumeData:resumeData];
        else
            task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:fileURL]];
        [task setTaskDescription:taskInfo];
        
        [downloadInfo setObject:task forKey:kMZDownloadKeyTask];
        
        [self.downloadingArray addObject:downloadInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadTableView reloadData];
            [self dismissAllActionSeets];
        });
        return;
    }
    for(NSMutableDictionary *downloadInfo in downloadingArray)
    {
        if([[downloadInfo objectForKey:kMZDownloadKeyTask] isEqual:task])
        {
            NSInteger indexOfObject = [downloadingArray indexOfObject:downloadInfo];
            
            if(error)
            {
                if(error.code != NSURLErrorCancelled)
                {
                    NSString *taskInfo = task.taskDescription;
                    
                    NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                    if(resumeData)
                        task = [sessionManager downloadTaskWithResumeData:resumeData];
                    else
                        task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:[downloadInfo objectForKey:kMZDownloadKeyURL]]];
                    [task setTaskDescription:taskInfo];
                    
                    [downloadInfo setObject:RequestStatusFailed forKey:kMZDownloadKeyStatus];
                    [downloadInfo setObject:(NSURLSessionDownloadTask *)task forKey:kMZDownloadKeyTask];
                    
                    [downloadingArray replaceObjectAtIndex:indexOfObject withObject:downloadInfo];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
                        [self.downloadTableView reloadData];
                        [self dismissAllActionSeets];
                    });
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *fileName = [[downloadInfo objectForKey:kMZDownloadKeyFileName] copy];
                    
                    [self presentNotificationForDownload:[downloadInfo objectForKey:kMZDownloadKeyFileName]];
                    
                    [downloadingArray removeObjectAtIndex:indexOfObject];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfObject inSection:0];
                    [downloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    if([self.delegate respondsToSelector:@selector(downloadRequestFinished:)])
                        [self.delegate downloadRequestFinished:fileName];
                    
                    [self dismissAllActionSeets];
                });
            }
            break;
        }
    }
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");
}
#pragma mark - UITableView Delegates and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == DOWNLOADING_TABLE)
        return downloadingArray.count;
    else
        return downloadedFilesArray.count;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == DOWNLOADING_TABLE)
    {
        static NSString *cellIdentifier = @"DownloadingCell";
        DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [self updateCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"DownloadedFileCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell.textLabel setText:[downloadedFilesArray objectAtIndex:indexPath.row]];
        return cell;
    }
}
- (void)updateCell:(DownloadingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *downloadInfoDict = [downloadingArray objectAtIndex:indexPath.row];
    
    NSString *fileName = [downloadInfoDict objectForKey:kMZDownloadKeyFileName];
    
    [cell.lblTitle setText:[NSString stringWithFormat:@"File Title: %@",fileName]];
    [cell.detailTextLabel setText:[downloadInfoDict objectForKey:kMZDownloadKeyDetails]];
    [cell.progressDownload setProgress:[[downloadInfoDict objectForKey:kMZDownloadKeyProgress] floatValue]];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == DOWNLOADING_TABLE)
    {
        selectedIndexPath = [indexPath copy];
        NSMutableDictionary *downloadInfoDict = [downloadingArray objectAtIndex:indexPath.row];
        if([[downloadInfoDict objectForKey:kMZDownloadKeyStatus] isEqualToString:RequestStatusPaused])
            [actionSheetStart showFromRect: CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width,200) inView: self.view animated: YES];
        else if([[downloadInfoDict objectForKey:kMZDownloadKeyStatus] isEqualToString:RequestStatusDownloading])
            [actionSheetPause showFromRect: CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width,200) inView: self.view animated: YES];
        else
            [actionSheetRetry showFromRect: CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width,200) inView: self.view animated: YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        selectedIndexPath1 = [indexPath copy];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Choose", @"Rename", nil];
        actionSheet.tag = 1;
        [actionSheet showFromRect: CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width,200) inView: self.view animated: YES];

    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == DOWNLOADED_TABLE)
        [self deleteItemForRowAtIndexPath:indexPath];
}

#pragma mark - UIActionSheet Delegates -
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 0)
    {
        if(buttonIndex == 0)
            [self pauseOrRetryButtonTappedOnActionSheet];
        else if(buttonIndex == 1)
            [self cancelButtonTappedOnActionSheet];
    }
    else
    {
        if (buttonIndex == 1)
        {
            NSString *fileName = [downloadedFilesArray objectAtIndex:selectedIndexPath.row];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename File" message:@"Please enter file name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
            [[alertView textFieldAtIndex:0] setText:[fileName stringByDeletingPathExtension]];
            [alertView setTag:1000];
            [alertView show];
        }
        else if(buttonIndex == 0)
        {
            NSLog(@"Choose");
            PhotoViewController *photoView = [self.storyboard instantiateViewControllerWithIdentifier: @"photoView"];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",fileDest,[downloadedFilesArray objectAtIndex:selectedIndexPath1.row]];
            photoView.imagePath = filePath;
            [self presentViewController: photoView animated: NO completion: nil];

        }
        else
        {
            NSLog(@"Cancel");

        }

    }
}
- (void)dismissAllActionSeets
{
    [actionSheetPause dismissWithClickedButtonIndex:2 animated:YES];
    [actionSheetRetry dismissWithClickedButtonIndex:2 animated:YES];
    [actionSheetStart dismissWithClickedButtonIndex:2 animated:YES];
}

#pragma mark - UIAlertView Delegate -
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if(alertView.tag == 1000)
    {
        NSString *textfieldText = [[alertView textFieldAtIndex:0] text];
        if(textfieldText.length == 0)
            textfieldText = @"";
        return ([[MZUtility trimWhitespace:textfieldText] length]>0)?YES:NO;
    }
    return YES;
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1000)
    {
        if(buttonIndex == 1)
        {
            UITextField *textfield = [alertView textFieldAtIndex:0];
            [self renameFileTo:textfield.text];
        }
    }
}

#pragma mark - NSNotification Methods -
- (void)downloadFinishedNotification:(NSNotification *)notification
{
    NSLog(@"Downloading finished.");
    NSString *fileName = notification.object;
    [downloadedFilesArray addObject:fileName.lastPathComponent];
    [self.downloadedTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - DownloadingCell Delegate -
- (IBAction)cancelButtonTappedOnActionSheet
{
    NSLog(@"Downloading cancelled.");
    
    NSIndexPath *indexPath = selectedIndexPath;
    
    NSMutableDictionary *downloadInfo = [downloadingArray objectAtIndex:indexPath.row];
    
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kMZDownloadKeyTask];
    
    [downloadTask cancel];
    
    [downloadingArray removeObjectAtIndex:indexPath.row];
    [downloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    if([self.delegate respondsToSelector:@selector(downloadRequestCanceled:)])
        [self.delegate downloadRequestCanceled:downloadTask];
}
- (IBAction)pauseOrRetryButtonTappedOnActionSheet
{
    NSIndexPath *indexPath = selectedIndexPath;
    DownloadingCell *cell = (DownloadingCell *)[downloadTableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary *downloadInfo = [downloadingArray objectAtIndex:indexPath.row];
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kMZDownloadKeyTask];
    NSString *downloadingStatus = [downloadInfo objectForKey:kMZDownloadKeyStatus];
    
    if([downloadingStatus isEqualToString:RequestStatusDownloading])
    {
        [downloadTask suspend];
        [downloadInfo setObject:RequestStatusPaused forKey:kMZDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kMZDownloadKeyStartTime];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:cell forRowAtIndexPath:indexPath];
        NSLog(@"Downloading paused.");
    }
    else if([downloadingStatus isEqualToString:RequestStatusPaused])
    {
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kMZDownloadKeyStatus];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:cell forRowAtIndexPath:indexPath];
        NSLog(@"Downloading resumed.");
    }
    else
    {
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kMZDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kMZDownloadKeyStartTime];
        [downloadInfo setObject:downloadTask forKey:kMZDownloadKeyTask];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:cell forRowAtIndexPath:indexPath];
        NSLog(@"Downloading resumed.");
    }
}

- (void)typeSelected:(id)sender
{
    if(segmentControl.selectedSegmentIndex == 0)
    {
        [self.downloadedTableView setHidden: YES];
        [self.downloadTableView setHidden: NO];
        [self.downloadTableView reloadData];
    }
    else if(segmentControl.selectedSegmentIndex == 1)
    {
        downloadedFilesArray = nil;
        downloadedFilesArray = [[NSMutableArray alloc] init];
        fileManger = [NSFileManager defaultManager];
        NSError *error;
        downloadedFilesArray = [[fileManger contentsOfDirectoryAtPath:fileDest error:&error] mutableCopy];
        
        if([downloadedFilesArray containsObject:@".DS_Store"])
            [downloadedFilesArray removeObject:@".DS_Store"];
        
        if(error && error.code != NSFileReadNoSuchFileError)
            [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
        else
            [self.downloadedTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinishedNotification:) name:DownloadCompletedNotif object:nil];
        
        [self.downloadTableView setHidden: YES];
        [self.downloadTableView reloadData];
        [self.downloadedTableView setHidden: NO];
        [self.downloadedTableView reloadData];
    }
}

#pragma mark - UIInterfaceOrientations -
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
