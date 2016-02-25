//
//  ExperimentItemViewController.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 25/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "ExperimentItemViewController.h"


@interface ExperimentItemViewController ()

@end

@implementation ExperimentItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.playerView loadWithVideoId:@"M7lc1UVf-VE"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
