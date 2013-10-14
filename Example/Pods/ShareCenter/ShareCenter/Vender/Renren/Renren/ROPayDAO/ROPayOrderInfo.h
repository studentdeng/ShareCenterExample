//
//  ROPayOrderInfo.h
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-10-19.
//  Copyright 2011 renren.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROPayOrderInfo : NSObject {
	NSString *_appID;
	NSString *_tradingVolume;
	NSString *_orderNum;
    NSString *_orderTime;
    NSString *_serialNum;
    NSString *_userID;
    NSString *_localOrderStatus;
    NSString *_description;
    NSString *_serverOrderStatus;
    NSString *_payment;
    NSString *_payEncode;
    NSString *_orderCheckCode;
    NSString *_isTestOrder;
    NSString *_payStatusCode;
}

/**
 * 应用的AppID
 */
@property (nonatomic, retain) NSString *appID;

/**
 * 订单金额
 */
@property (nonatomic, retain) NSString *tradingVolume;

/**
 * 订单号
 */
@property (nonatomic, retain) NSString *orderNum;

/**
 * 订单时间
 */
@property (nonatomic, retain) NSString *orderTime;

/**
 * 订单流水号
 */
@property (nonatomic, retain) NSString *serialNum;

/**
 * 用户ID
 */
@property (nonatomic, retain) NSString *userID;

/**
 * 本地订单状态
 */
@property (nonatomic, retain) NSString *localOrderStatus;

/**
 * 服务器的订单状态
 */
@property (nonatomic, retain) NSString *serverOrderStatus;

/**
 * 订单描述
 */
@property (nonatomic, retain) NSString *description;

/**
 * 订单信息中第三方开发者自定义内容
 */
@property (nonatomic, retain) NSString *payment;

/**
 * 订单信息的校验码
 */
@property (nonatomic, retain) NSString *payEncode;

/**
 * 是否为测试订单
 */
@property (nonatomic, retain) NSString *isTestOrder;

/**
 * 订单信息校验码
 */
@property (nonatomic, retain) NSString *orderCheckCode;

/**
 * 订单状态码
 */
@property (nonatomic, retain) NSString *payStatusCode;

@end
