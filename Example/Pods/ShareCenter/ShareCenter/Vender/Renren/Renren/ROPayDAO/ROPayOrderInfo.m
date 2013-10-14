//
//  ROPayOrderInfo.m
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-10-19.
//  Copyright 2011 renren.com. All rights reserved.
//

#import "ROPayOrderInfo.h"

@implementation ROPayOrderInfo

@synthesize appID = _appID;
@synthesize tradingVolume = _tradingVolume;
@synthesize orderNum = _orderNum;
@synthesize orderTime = _orderTime;
@synthesize serialNum = _serialNum;
@synthesize userID = _userID;
@synthesize localOrderStatus = _localOrderStatus;
@synthesize serverOrderStatus = _serverOrderStatus;
@synthesize description = _description;
@synthesize payment = _payment;
@synthesize payEncode = _payEncode;
@synthesize orderCheckCode = _orderCheckCode;
@synthesize isTestOrder = _isTestOrder;
@synthesize payStatusCode = _payStatusCode;

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (void)dealloc
{
    self.appID = nil;
    self.tradingVolume = nil;
    self.orderNum = nil;
    self.orderTime = nil;
    self.serialNum = nil;
    self.userID = nil;
    self.localOrderStatus = nil;
    self.serverOrderStatus = nil;
    self.description = nil;
    self.payment = nil;
    self.payEncode = nil;
    self.orderCheckCode = nil;
    self.isTestOrder = nil;
    self.payStatusCode = nil;
	[super dealloc];
}

@end