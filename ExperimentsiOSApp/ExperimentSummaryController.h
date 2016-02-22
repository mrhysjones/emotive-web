//
//  ExperimentSummaryController.h
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 19/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Experiment.h"

@interface ExperimentSummaryController : UIViewController
-(void)setAPIUrl:(NSString*)value;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;


@end
