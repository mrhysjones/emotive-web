//
//  NSObject+Experiment.h
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 22/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Experiment : NSObject {
    
    NSString *name;
    NSString *description;
    NSString *createdBy;
    NSDictionary *items; 
}

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *description;
@property(nonatomic,retain)NSString *createdBy;
@property(nonatomic,retain)NSDictionary *items;

+(Experiment*)getInstance;
-(void)getExperimentInfo:(NSString*) APIUrl;
@end
