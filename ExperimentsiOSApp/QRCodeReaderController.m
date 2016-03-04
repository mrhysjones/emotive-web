//
//  QRCodeReaderController.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 19/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "QRCodeReaderController.h"

@interface QRCodeReaderController ()


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation QRCodeReaderController

NSString *qrcode;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self qrRead];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  Read QR code based on camer aframes
 */
-(void) qrRead{
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    // Set up capture session
    _captureSession  = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // Look for QR code
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_qrCodeView.layer.bounds];
    [_qrCodeView.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
}
/**
 *  Handle sample buffer - delegate method
 *
 *  @param captureOutput Capture output object
 *  @param sampleBuffer  Video frame data
 *  @param connection    Connection from which the video was received
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        // Check if QR code has been scanned
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_captureSession stopRunning];
            qrcode = metadataObj.stringValue;
            
            // Populate experiment data with API URL encoded in QR code
            Experiment *exp = [Experiment getInstance];
            [exp getExperimentInfo:[@"http://" stringByAppendingString:qrcode]];
            
            // Perform segue to experiment summary
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"QRCodeSegue" sender:self];
            });
        }
    }
}

@end
