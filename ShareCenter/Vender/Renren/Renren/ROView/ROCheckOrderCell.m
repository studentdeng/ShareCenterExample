//
//  ROCheckOrderCell.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-19.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import "ROCheckOrderCell.h"
#import "ROCheckDialogViewController.h"
#import "ROCheckNavigationViewController.h"

@implementation ROCheckOrderCell
@synthesize orderNum = _orderNum;
@synthesize orderTime = _orderTime;
@synthesize orderStatus = _orderStatus;
@synthesize tradingVolume = _tradingVolume;
@synthesize repair = _repair;
@synthesize serialNum = _serialNum;
@synthesize description = _description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)repairOrder:(id)sender
{
    UIResponder* responder = self.nextResponder;
	while (responder) {
		if ([responder isKindOfClass:[ROCheckDialogViewController class]]) {
			ROCheckDialogViewController* viewController = (ROCheckDialogViewController*)responder;
            [viewController repairOrder:self];
			break;
		} else if ([responder isKindOfClass:[ROCheckNavigationViewController class]]) {
			ROCheckNavigationViewController* viewController = (ROCheckNavigationViewController*)responder;
            [viewController repairOrder:self];
			break;
		}
		responder = responder.nextResponder;
	}
}

- (void)dealloc
{
    self.orderNum = nil;
    self.orderStatus = nil;
    self.orderTime = nil;
    self.tradingVolume = nil;
    self.repair = nil;
    self.serialNum = nil;
    self.description = nil;
    [super dealloc];
}



@end
