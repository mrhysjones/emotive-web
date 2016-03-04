//
//  NSObject+Experiment.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 22/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "Experiment.h"

@implementation Experiment
@synthesize name;
@synthesize description;
@synthesize createdBy;
@synthesize items;
@synthesize currentItem;

static Experiment *instance = nil;

/**
 *  Gets/creates singleton instance of Experiment class
 *
 *  @return Experiment instance
 */
+(Experiment *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Experiment new];
        }
    }
    return instance;
}

/**
 *  Retrieves experiment information from API request, store in class variables
 *
 *  @param APIUrl API URL for experiment to retrieve
 */
-(void)getExperimentInfo:(NSString*) APIUrl{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:APIUrl]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10
     ];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse error:&requestError];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NULL error:NULL];
    
    instance.name = dict[@"name"];
    instance.description = dict[@"description"];
    instance.createdBy = dict[@"createdBy"];
    instance.items = dict[@"items"];
    instance.currentItem = [NSNumber numberWithInt:0];
}

/**
 *  Keeps track of current item being looked at in experiment 
 */
-(void)updateCurrentItem{
    if ([instance.currentItem intValue] < [instance.items count] - 1){
        int value = [instance.currentItem intValue];
        instance.currentItem = [NSNumber numberWithInt:value + 1];
    }
    else{
        instance.currentItem = [NSNumber numberWithInt:-1];
    }
}



@end
