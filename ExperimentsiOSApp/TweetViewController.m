//
//  TweetViewController.m
//  ExperimentsiOSApp
//
//  Created by Matthew Jones on 25/02/2016.
//  Copyright © 2016 Matthew Jones. All rights reserved.
//

#import "TweetViewController.h"
#import <TwitterKit/TwitterKit.h>

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[[TWTRAPIClient alloc] init] loadTweetWithID:@"702281796214505472" completion:^(TWTRTweet *tweet, NSError *error) {
        if (tweet) {
            TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweet style:TWTRTweetViewStyleRegular];
            tweetView.center = CGPointMake(self.view.center.x, self.topLayoutGuide.length + tweetView.frame.size.height / 2);
            [self.view addSubview:tweetView];
        } else {
            NSLog(@"Tweet load error: %@", [error localizedDescription]);
        }
    }];
}

@end