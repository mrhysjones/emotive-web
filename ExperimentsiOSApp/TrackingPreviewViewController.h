//
//  TrackingPreviewViewController.h
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 24/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc.hpp>
#import "trackerWrapper.h"
#import "svmWrapper.h"

@interface TrackingPreviewViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *videoView;

@property (strong, nonatomic) trackerWrapper *tracker;
@property (strong, nonatomic) svmWrapper *svm;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) CIContext *ciContext;


@end
