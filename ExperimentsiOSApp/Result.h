//
//  Result.h
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 13/03/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Result : NSObject {
    
    NSString *experimentID;
    NSString *experimentName;
    NSString *itemID;
    NSString *itemData;
    NSString *itemType;
    NSString *displaySeconds; 
    NSMutableArray *emotionData;
    NSMutableArray *trackingData;
    NSMutableArray *videoFrames;
}

@property(nonatomic,retain)NSString *experimentID;
@property(nonatomic,retain)NSString *experimentName;
@property(nonatomic,retain)NSString *itemID;
@property(nonatomic,retain)NSString *itemData;
@property(nonatomic,retain)NSString *itemType;
@property(nonatomic,retain)NSString *displaySeconds;
@property(nonatomic,retain)NSMutableArray *emotionData;
@property(nonatomic,retain)NSMutableArray *trackingData;
@property(nonatomic,retain)NSMutableArray *videoFrames;


+(Result*)getInstance;
-(void)setExperimentID:(NSString *)currentExperimentID;
-(void)setItemID:(NSString *)currentItemID;
-(void)addTrackingData:(NSDictionary *)tracking;
-(void)addEmotionData:(NSDictionary *)emotions;
-(void)addVideoFrame:(UIImage *)frame;
-(void)postCurrentData;


@end
