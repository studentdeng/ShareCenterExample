//
//  CUViewController.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUSinaShareClient.h"

@interface CUViewController : UIViewController <CUShareClientDelegate>

- (IBAction)share:(id)sender;
- (IBAction)logout:(id)sender;

@end
