//
//  ExperimentSummaryController.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 19/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//
#import "ExperimentSummaryController.h"

@interface ExperimentSummaryController ()

@end

@implementation ExperimentSummaryController

NSString *APIUrl;

/**
 *  Format API URL with http://
 *
 *  @param qrURL URL read by QR code
 */
-(void)setAPIUrl:(NSString*) qrURL{
    APIUrl = [@"http://" stringByAppendingString:qrURL];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Load experiment details stored in Experiment model
    Experiment *exp = [Experiment getInstance];
    _nameLabel.text = exp.name;
    _descLabel.text = exp.description;
    _creatorLabel.text = exp.createdBy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
