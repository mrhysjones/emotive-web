//
//  QRCodeReaderController.h
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 19/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Experiment.h"

@interface QRCodeReaderController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *qrCodeView;

@end
