//
//  Result.h
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 13/03/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Result : NSObject {
    
    NSString *experimentID;
    NSString *itemID;
    NSMutableArray *emotionData;
    NSMutableArray *trackingData;
}

@property(nonatomic,retain)NSString *experimentID;
@property(nonatomic,retain)NSString *itemID;
@property(nonatomic,retain)NSMutableArray *emotionData;
@property(nonatomic,retain)NSMutableArray *trackingData;

+(Result*)getInstance;
-(void)setExperimentID:(NSString *)currentExperimentID;
-(void)setItemID:(NSString *)currentItemID;
-(void)addTrackingData:(NSDictionary *)tracking;
-(void)addEmotionData:(NSDictionary *)emotions;
-(void)postCurrentData;


@end
