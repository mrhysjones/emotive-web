//
//  ExperimentItemViewController.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 25/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "ExperimentItemViewController.h"

@interface ExperimentItemViewController ()

@end

@implementation ExperimentItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadFirstExperiment];
    
    // Face tracker initialisation
    self.tracker = [[trackerWrapper alloc] init];
    [self.tracker initialiseModel];
    [self.tracker initialiseValues];
    
    // Initialise capture and video view
    [self createAndRunNewSession];
}


/**
 *  Loads the initial experiment item with the appropriate view
 */
-(void)loadFirstExperiment{
    Experiment* exp = [Experiment getInstance];
    Result* res = [Result getInstance];
    [res setExperimentID:exp.experimentID];
    [res setExperimentName:exp.name];
    
    NSDictionary* firstItemData = exp.items[0];
    [res setItemID:firstItemData[@"_id"]];
    
    NSString* itemType = firstItemData[@"dataType"];
    NSString* itemData = firstItemData[@"data"];
    NSString* itemTimeString = firstItemData[@"displaySeconds"];
    
    [res setItemType:itemType];
    [res setItemData:itemData];
    [res setDisplaySeconds:itemTimeString];
    
    int itemTime = [itemTimeString intValue];
    
    if ([itemType  isEqual: @"twitter"]){
        [self loadTweetView:itemData];
        [self loadNextExperiment:itemTime];
    }
    else if ([itemType isEqual:@"youtube"]){
        [self loadYoutubeView:itemData];
        [self loadNextExperiment:itemTime];
    }
    else{
        [self loadWebView:itemData];
        [self loadNextExperiment:itemTime];
    }
}

/**
 *  Creates a TWTRTweetView and adds to view
 *
 *  @param data Tweet URL
 */
-(void) loadTweetView:(NSString*) data{
    // Clear sub view
    [self clearSubViews];
    
    // Extract tweet ID from URL given in the API
    NSString* tweetID = [self getTweetIDFromURL:data];
    
    // Create tweet view based on tweet ID
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    [client loadTweetWithID:tweetID completion:^(TWTRTweet *tweet, NSError *error) {
        if (tweet) {
            TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweet];
            [self.view addSubview:tweetView];
            tweetView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
        } else {
            NSLog(@"Error loading Tweet: %@", [error localizedDescription]);
        }
    }];
}


/**
 *  Creates a UIWebView and adds to view
 *
 *  @param data URL to load web view with
 */
-(void) loadWebView:(NSString*) data{
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    webview.scalesPageToFit = YES;
    webview.autoresizesSubviews = YES;
    webview.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [webview setBackgroundColor:[UIColor clearColor]];
    NSURL *targetURL = [NSURL URLWithString:data];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webview loadRequest:request];
    
    [self.view addSubview:webview];
}

/**
 *  Creates a YTPlayerView and adds to view
 *
 *  @param data YouTube video ID
 */
-(void) loadYoutubeView:(NSString*) data{
    [self clearSubViews];
    YTPlayerView *youtubeView = [[YTPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview:youtubeView];
    [youtubeView loadWithVideoId:data];
}

/**
 *  Load in the next experiment item/finish experiment
 *
 *  @param time Number of seconds to wait before load of next item (based on display time of previous item)
 */
- (void)loadNextExperiment:(int) time{
    // Check if there are more items to load
    Experiment* exp = [Experiment getInstance];
    Result* res = [Result getInstance];
    
    [exp updateCurrentItem];
    int currentIndex =  [exp.currentItem intValue];
    if (currentIndex != -1){
        NSDictionary* itemData = exp.items[currentIndex];
        
        NSString* itemType = itemData[@"dataType"];
        NSString* itemDatasource = itemData[@"data"];
        NSString* itemTimeString = itemData[@"displaySeconds"];
        int itemTime = [itemTimeString intValue];
        
        // Wait until time is up before loading appropriate view
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  (int)(size_t)time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // Save result frames to phone
            NSMutableArray* resultFrames = [res videoFrames];
            UIImage *firstFrame = [resultFrames objectAtIndex:0];
            NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:320 andHeight:480];
            self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings];
            NSLog(@"%f", firstFrame.size.width);
            NSLog(@"%f",firstFrame.size.height);
            [self.movieMaker createMovieFromImages:[resultFrames copy] withCompletion:^(NSURL *fileURL){
                NSLog(@"%@", fileURL);
            }];
            
            [res postCurrentData];
            [res setItemID:itemData[@"_id"]];
            if ([itemType isEqual: @"twitter"]){
                [self loadTweetView:itemDatasource];
                [self loadNextExperiment:itemTime];
            }
            else if ([itemType isEqual:@"youtube"]){
                [self loadYoutubeView:itemDatasource];
                [self loadNextExperiment:itemTime];
            }
            else {
                [self loadWebView:itemDatasource];
                [self loadNextExperiment:itemTime];
            }
        });
    }
    else{
        // If no experiment items left, still wait for display time, and then perform segue to end of experiment view
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  (int)(size_t)time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [res postCurrentData];
            [self performSegueWithIdentifier:@"experimentEndSegue" sender:self];
        });
    }
}
/**
 *  Clears all subviews i.e. YTPlayerView/UIWebView/TWTRTweetView from view
 */
-(void)clearSubViews{
    
    for (UIView *subView in self.view.subviews)
    {
        [subView removeFromSuperview];
    }
    
    
}


/**
 *  Return Tweet ID from a full Tweet URL
 *
 *  @param url Full Tweet URL in the form twitter.com/user/status/tweetID
 *
 *  @return Tweet ID
 */
-(NSString*) getTweetIDFromURL:(NSString*) url{
    NSArray* urlComponents = [url componentsSeparatedByString: @"/"];
    NSString* tweetID = [urlComponents objectAtIndex:([urlComponents count] -1)];
    return tweetID;
}


/**
 *  Set up the input/output required for this capture session
 */
- (void) createAndRunNewSession
{
    // Set up AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Set up camera
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.device = [self findCamera:AVCaptureDevicePositionFront];
    
    
    if ([self.device lockForConfiguration:nil]) {
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        [self.device unlockForConfiguration];
    }
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    
    // Set up how to handle video frames from camera
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    self.output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt: kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    self.output.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("new_queue", NULL);
    
    [self.output setSampleBufferDelegate:self queue:queue];
    
    // These checks have been put in place to stop simulator errors
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]){
        [self.session addOutput:self.output];
    }
    // Triggers captureOutput below
    [self.session startRunning];
}

/**
 *  Finds camera with particular position
 *
 *  @param pos AVCaptureDevicePosition
 *
 *  @return AVCaptureDevice if found
 */
- (AVCaptureDevice *) findCamera:(AVCaptureDevicePosition) pos
{
    AVCaptureDevice *camera = nil;
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *currentDevice in devices) {
        if ([currentDevice hasMediaType:AVMediaTypeVideo]) {
            if ([currentDevice position] == pos) {
                camera =  currentDevice;
            }
        }
    }
    return camera;
}


/**
 *  Handle sample buffer - delegate method
 *
 *  @param captureOutput Capture output object
 *  @param sampleBuffer  Video frame data
 *  @param connection    Connection from which the video was received
 */
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // start tracking data and get image of tracked face
        [self.tracker trackWithCVImageBufferRef:imageBuffer trackIndicator:1];
    }
}
/**
 *  Handles the stopping of AVCaptureSession and clearing of subviews at end of experiment
 *
 *  @param segue  Segue to make
 *  @param sender Sender
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self clearSubViews];
    
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
