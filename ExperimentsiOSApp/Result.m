
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

-(void)setExperimentID:(NSString *)currentExperimentID{
    emotionData = [NSMutableArray array];
    trackingData = [NSMutableArray array];
    experimentID = currentExperimentID;
}

-(void)setItemID:(NSString *)currentItemID{
    itemID = currentItemID;
}

-(void)addEmotionData:(NSDictionary *)emotions{
    [emotionData addObject:emotions];
}

-(void)addTrackingData:(NSDictionary *)tracking{
    [trackingData addObject:tracking];
    
}

-(void)postCurrentData{
    
    // Create JSON data representation needed for API POST request
    NSDictionary *resultData = [[NSDictionary alloc] initWithObjectsAndKeys:emotionData, @"emotionData", trackingData, @"trackingData", nil];
    
    NSDictionary *postData = [[NSDictionary alloc] initWithObjectsAndKeys:experimentID, @"experimentID", itemID, @"itemID", resultData, @"resultData", nil];
    
    NSURL *APIUrl = [NSURL URLWithString:@"http://188.166.147.187:3000/api/results"];
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:postData
                                                       options:0
                                                         error:nil];
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

