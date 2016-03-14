
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
@synthesize itemID;
@synthesize emotionData;
@synthesize trackingData;

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
    trackingData = [NSMutableArray array];
    experimentID = currentExperimentID;
}
/**
 *  Set the current item ID that results are being gathered for
 *
 *  @param currentItemID <#currentItemID description#>
 */
-(void)setItemID:(NSString *)currentItemID{
    itemID = currentItemID;
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
 *  Send the current results for an item to the results API via a POST request
 */
-(void)postCurrentData{
    // Hardcoded API URL - currently hosted on DigitalOcean
    NSURL *APIUrl = [NSURL URLWithString:@"http://188.166.147.187:3000/api/results"];
    
    // Create JSON data representation of results needed for API POST request
    NSDictionary *resultData = [[NSDictionary alloc] initWithObjectsAndKeys:emotionData, @"emotionData", trackingData, @"trackingData", nil];
    
    NSDictionary *postData = [[NSDictionary alloc] initWithObjectsAndKeys:experimentID, @"experimentID", itemID, @"itemID", resultData, @"resultData", nil];
    
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
    }];
    
    [task resume];
    
    [emotionData removeAllObjects];
    [trackingData removeAllObjects];
}

@end

