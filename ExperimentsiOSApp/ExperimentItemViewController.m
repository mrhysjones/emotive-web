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

-(void)loadFirstExperiment{
    Experiment* exp = [Experiment getInstance];
    NSDictionary* firstItemData = exp.items[0];
    NSString* itemType = firstItemData[@"dataType"];
    NSString* itemData = firstItemData[@"data"];
    NSString* itemTimeString = firstItemData[@"displaySeconds"];
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
    NSLog(@"Now viewing Tweet with ID - %@", tweetID);
}


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
    NSLog(@"Now viewing web page with URL - %@", data);
}

-(void) loadYoutubeView:(NSString*) data{
    [self clearSubViews];
    YTPlayerView *youtubeView = [[YTPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview:youtubeView];
    [youtubeView loadWithVideoId:data];
    NSLog(@"Now viewing YouTube video with ID - %@", data);
}


- (void)loadNextExperiment:(int) time{
    
    Experiment* exp = [Experiment getInstance];
    [exp updateCurrentItem];
    int currentIndex =  [exp.currentItem intValue];
    if (currentIndex != -1){
        NSDictionary* itemData = exp.items[currentIndex];
        NSString* itemType = itemData[@"dataType"];
        NSString* itemDatasource = itemData[@"data"];
        NSString* itemTimeString = itemData[@"displaySeconds"];
        int itemTime = [itemTimeString intValue];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  (int)(size_t)time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([itemType  isEqual: @"twitter"]){
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  (int)(size_t)time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"experimentEndSegue" sender:self];
        });
    }
}

-(void)clearSubViews{
    for (UIView *subView in self.view.subviews)
    {
        [subView removeFromSuperview];
    }
}

-(NSString*) getTweetIDFromURL:(NSString*) url{
    NSArray* urlComponents = [url componentsSeparatedByString: @"/"];
    NSString* tweetID = [urlComponents objectAtIndex:([urlComponents count] -1)];
    return tweetID;
}

/*!
 @brief Sets up the input/output required for the app to work
 
 @discussion This method is used to set up a capture session with the front camera, to set up the output video, and also to handle the video buffer
 
 */
- (void) createAndRunNewSession
{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.device = [self findCamera:AVCaptureDevicePositionFront];
    
    
    if ([self.device lockForConfiguration:nil]) {
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        [self.device unlockForConfiguration];
    }
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    
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

/*!
 @brief Finds the front/back camera from the available devices
 
 @discussion This method is called to look for all available capture devices, and to find the camera with specified position
 
 @return AVCaptureDevice    Camera if found, nil otherwise
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
 

/*!
 @brief Applies processsing to the output from the camera
 
 @discussion This method will take a sample from the buffer, and will apply the tracking methods to this sample, before adding the resultant image to the video view
 */
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // start tracking data and get image of tracked face
        [self.tracker trackWithCVImageBufferRef:imageBuffer trackIndicator:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
