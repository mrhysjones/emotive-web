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

-(void)setAPIUrl:(NSString*) qrURL{
    APIUrl = [@"http://" stringByAppendingString:qrURL];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
