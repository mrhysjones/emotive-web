//
//  trackerWrapper.h
//
//  Created by Tom Hartley on 01/12/2012.
//  Modified and documented by Matthew Jones on 09/09/2015 and 14/03/16
//  Copyright (c) 2012 Tom Hartley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "Tracker.h"
#import "imageConversion.h"
#import "svmWrapper.h"
#import "Result.h"
#import <AVFoundation/AVFoundation.h>

@interface trackerWrapper : NSObject

-(void)initialiseModel;
-(void)initialiseValues;
-(void)resetModel;
-(UIImage *)trackWithCVImageBufferRef:(CVImageBufferRef)imageBuffer trackIndicator:(int)trackIndicator;

@end