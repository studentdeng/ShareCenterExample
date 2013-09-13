//
//  ROCheckOrderCell.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-19.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROCheckOrderCell : UITableViewCell {
    UILabel *_orderNum;
    UILabel *_tradingVolume;
    UILabel *_orderTime;
    UILabel *_orderStatus;
    UILabel *_serialNum;
    UILabel *_description;
    UIButton *_repair;
}

@property (retain ,nonatomic)IBOutlet UILabel *orderNum;
@property (retain ,nonatomic)IBOutlet UILabel *tradingVolume;
@property (retain ,nonatomic)IBOutlet UILabel *orderTime;
@property (retain ,nonatomic)IBOutlet UILabel *orderStatus;
@property (retain ,nonatomic)IBOutlet UIButton *repair;
@property (retain ,nonatomic)IBOutlet UILabel *serialNum;
@property (retain ,nonatomic)IBOutlet UILabel *description;

- (IBAction)repairOrder:(id)sender;

@end
