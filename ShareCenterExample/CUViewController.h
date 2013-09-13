//
//  CUViewController.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUSinaShareClient.h"

@class CUTimelineDataSource;

@interface CUViewController : UIViewController <CUShareClientDelegate>
{
    IBOutlet UILabel *sinaBindLabel;
    IBOutlet UILabel *renrenBindLabel;
    IBOutlet UILabel *tencentBindLabel;
}

@property (nonatomic, retain) UILabel *sinaBindLabel;
@property (nonatomic, retain) UILabel *renrenBindLabel;
@property (nonatomic, retain) UILabel *tencentBindLabel;

- (IBAction)share:(id)sender;
- (IBAction)logout:(id)sender;

- (IBAction)showRENREN:(id)sender;

@end
