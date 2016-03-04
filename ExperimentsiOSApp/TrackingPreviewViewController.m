//
//  TrackingPreviewViewController.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 24/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "TrackingPreviewViewController.h"

@interface TrackingPreviewViewController ()

@end

@implementation TrackingPreviewViewController

@synthesize videoView;

AVCaptureDevicePosition pos = AVCaptureDevicePositionFront;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Face tracker initialisation
    self.tracker = [[trackerWrapper alloc] init];
    [self.tracker initialiseModel];
    [self.tracker initialiseValues];
    
    // Initialise capture and video view
    [self createAndRunNewSession];
    
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
 *  Set up the input/output required for this capture session
 */
- (void) createAndRunNewSession
{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.device = [self findCamera:pos];
    
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)faceTrack:(id)sender {
    [self.tracker resetModel];
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
        UIImage *trackedImage = [self.tracker trackWithCVImageBufferRef:imageBuffer trackIndicator:0];
        
        // Show modified image on video view
        [self.videoView performSelectorOnMainThread:@selector(setImage:) withObject:trackedImage waitUntilDone:YES];
    }
}

/**
 *  Reset face tracker on button
 *
 *  @param sender Button press
 */
- (IBAction)resetTracker:(id)sender {
    [self.tracker resetModel];
}

/**
 *  Stop AVCaptureSession before segue to start of experiment
 *
 *  @param segue  Segue to make
 *  @param sender Sender
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.session stopRunning];
}




@end
