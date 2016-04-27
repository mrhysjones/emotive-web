
//
//  Result.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 13/03/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "Result.h"

@implementation Result
@synthesize experimentID;
@synthesize experimentName;
@synthesize itemID;
@synthesize itemData;
@synthesize itemType;
@synthesize displaySeconds; 
@synthesize emotionData;
@synthesize trackingData;
@synthesize videoFrames;

static Result *instance = nil;

/**
 *  Gets/creates singleton instance of Result class
 *
 *  @return Result instance
 */
+(Result *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Result new];
        }
    }
    return instance;
}

/**
 *  Set the current experiment ID that results are being gathered for
 *
 *  @param currentExperimentID Current experiment ID
 */
-(void)setExperimentID:(NSString *)currentExperimentID{
    emotionData = [NSMutableArray array];
    //trackingData = [NSMutableArray array];
    videoFrames = [NSMutableArray array];
    experimentID = currentExperimentID;
}

/**
 *  Set the current experiment name that results are being gathered for
 *
 *  @param currentExperimentID Current experiment name
 */
-(void)setExperimentName:(NSString *)currentExperimentName{
    experimentName = currentExperimentName;
}

/**
 *  Set the current item ID that results are being gathered for
 *
 *  @param currentItemID Current item ID
 */
-(void)setItemID:(NSString *)currentItemID{
    itemID = currentItemID;
}

/**
 *  Set the current item data source that results are being gathered for
 *
 *  @param currentItemData Data source for the item viewed
 */
-(void)setItemData:(NSString *)currentItemData{
    itemData = currentItemData;
}

/**
 *  Set the current item data type that results are being gathered for
 *
 *  @param currentItemType Enum value (twitter/youtube/webpage)
 */
-(void)setItemType:(NSString *)currentItemType{
    itemType = currentItemType;
}


/**
 *  Set the number of seconds item displayed for during experiment
 *
 *  @param currentDisplaySeconds Display seconds
 */
-(void)setDisplaySeconds:(NSString *)currentDisplaySeconds{
    displaySeconds = currentDisplaySeconds;
}



/**
 *  Add emotion classifications of frame(s) to the emotion data results
 *
 *  @param emotions Array of 8 predictions
 */
-(void)addEmotionData:(NSDictionary *)emotions{
    [emotionData addObject:emotions];
}
/**
 *  Add face tracking of frame(s) to the tracking data results
 
 *
 *  @param tracking Array of tracking landmarks
 */
-(void)addTrackingData:(NSDictionary *)tracking{
    [trackingData addObject:tracking];
    
}

/**
 * Add a UIImage frame captured by the camera to the frames array used to generate
 * video files
 *
 * @param frame A single camera frame
 */
-(void)addVideoFrame:(UIImage *)frame{
    [videoFrames addObject:frame];
    
    // To reduce memory requirements of the app, save a video approximately every 15 seconds (300 frames / 20 FPS) - otherwise will crash with large content 
    if ([videoFrames count] == 300){
        [self saveVideoFrames];
    }
}

/**
 *  Send the current results for an item to the results API via a POST request
 */
-(void)postCurrentData{
    // Hardcoded Experiment API URL - currently hosted on DigitalOcean droplet
    // Code for this component is available on https://github.com/mrhysjones/emotion-creation-app
    NSURL *APIUrl = [NSURL URLWithString:@"http://188.166.147.187:3000/api/results"];
    
    // Create JSON data representation of results needed for API POST request
    
    NSDictionary *itemsData =[[NSDictionary alloc] initWithObjectsAndKeys:itemID, @"itemID", itemData, @"data", itemType, @"dataType", displaySeconds, @"displaySeconds", nil];
    
    //NSDictionary *resultData = [[NSDictionary alloc] initWithObjectsAndKeys:emotionData, @"emotionData", trackingData, @"trackingData", nil];
    
    NSDictionary *resultData = [[NSDictionary alloc] initWithObjectsAndKeys:emotionData, @"emotionData", nil];

//    if([trackingData count]){
//        [trackingData removeAllObjects];
//    }
    NSDictionary *postData = [[NSDictionary alloc] initWithObjectsAndKeys:experimentID, @"experimentID", experimentName, @"experimentName", itemsData, @"itemData", resultData, @"resultData", nil];
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:postData
                                                       options:0
                                                         error:nil];
    
    // Create and execute POST request using this JSON data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:APIUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[JSONData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: JSONData];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        if ([emotionData count]){
            [emotionData removeAllObjects];
        }
    }];
    
    [task resume];
}

/**
 *  Generate name for video based on experiment ID, item ID, and unix time
 *
 *  @param res Current results instance - used to retrieve item ID and experiment ID
 *
 *  @return File name string, appended with .mov, for use with CEMovieMaker
 */
-(NSString*) generateVideoName{
    // Current UNIX timetstamp
    int time = [[NSDate date] timeIntervalSince1970];
    
    // Combine into filename
    NSString* filename = [NSString stringWithFormat:@"/%@-%@-%d.mov", experimentID, itemID, time];
    
    return filename;
}

/**
 * Save the contents of frames array to a single .mov file
 *
 */
-(void) saveVideoFrames{
    NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:320 andHeight:480];
    NSString* videoFileName = [self generateVideoName];
    self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings videoName:videoFileName];
    [self.movieMaker createMovieFromImages:[videoFrames copy] withCompletion:^(NSURL *fileURL){
        NSLog(@"%@", fileURL);
    }];
    [videoFrames removeAllObjects];
}

@end

