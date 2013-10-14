//
//  RenrenPay.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-17.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ROPayDialogViewController.h"
#import "ROCheckDialogViewController.h"

@class ROPayOrderDao;
@class ROPayOrderInfo;

@protocol RenrenPayDelegate <NSObject>

@optional

/**
 * 支付成功，第三方开发者实现这个方法
 * @param order 传回订单详细信息的对象。
 */
- (void)payDidSuccessWithOrder:(ROPayOrderInfo*)order;

/**
 * 支付失败，第三方开发者实现这个方法
 * @param error 传回订单支付失败信息的对象。
 */
- (void)payDidFailWithError:(ROPayError*)error;

/**
 * 修复成功，第三方开发者实现这个方法
 * @param order 传回订单详细信息的对象。
 */
- (void)repairOrderDidSuccessWithOrder:(ROPayOrderInfo*)order;

/**
 * 修复失败，第三方开发者实现这个方法
 * @param error 传回订单修复失败信息的对象。
 */
- (void)repairOrderDidFailWithError:(ROPayError*)error;
@end

@interface RenrenPay : NSObject <RODialogDelegate,RORequestDelegate,RenrenPayDialogDelegate,RenrenCheckDialogDelegate>{
    ROPayOrderDao *_payDao;
    Renren *_renren;
    RORequest *_payRequest;
    id<RenrenPayDelegate> _delegate;
    ROPayOrderInfo *_tempOrder;
    NSString *_appSecret;
    BOOL _isTest;
}
@property (retain ,nonatomic)ROPayOrderDao *payDao;
@property (retain ,nonatomic)Renren *renren;
@property (retain ,nonatomic)RORequest *payRequest;
@property (assign ,nonatomic)id<RenrenPayDelegate> delegate;
@property (assign ,nonatomic)BOOL isTest;
@property (retain ,nonatomic)ROPayOrderInfo *tempOrder;
@property (retain ,nonatomic)NSString *appSecret;

/**
 * 初始化RenrenPay
 * @return 返回RenrenPay的对象。
 */
- (id)initPayWithRenren:(Renren*)renren andSecretKey:(NSString *)secret andLocalMem:(BOOL)isUsed;

/**
 * 获取订单号
 * @return 返回订单号。
 */
- (NSString*)getOrderNumber;

/**
 * 生成订单对象
 * @param orderNum      订单号。
 * @param amount        订单金额。
 * @param description   订单描述。
 * @param payment       订单开发者自定义内容。
 * @return 返回订单对象。
 */
- (ROPayOrderInfo *)makePayOrderWithOrderNum:(NSString *)orderNum 
                                    andAmount:(NSUInteger)amount 
                               andDescription:(NSString *)description 
                                   andPayment:(NSString*)payment;

/**
 * 提交订单——弹层页面
 * @param order         订单对象。
 * @param permissions   未授权情况下可以设定开通的权限。
 * @param delegate      代理对象。
 */
- (void)submitPayOrderWithOrder:(ROPayOrderInfo*)order 
                 andPermissions:(NSArray*)permissions 
                    andDelegate:(id<RenrenPayDelegate>)delegate;

/**
 * 提交订单——Navigation页面
 * @param order         订单对象。
 * @param permissions   未授权情况下可以设定开通的权限。
 * @param delegate      代理对象。
 */
- (void)submitPayOrderInNavigationWithOrder:(ROPayOrderInfo*)order 
                 andPermissions:(NSArray*)permissions 
                    andDelegate:(id<RenrenPayDelegate>)delegate;

/**
 * 提交订单——弹层页面
 * @param delegate    代理对象。
 */
- (void)queryOrderListWithDelegate:(id<RenrenPayDelegate>)delegate;

/**
 * 提交订单——Navigation页面
 * @param delegate    代理对象。
 */
- (void)queryOrderListInNavigationWithDelegate:(id<RenrenPayDelegate>)delegate;

/**
 * 删除订单
 */
- (void)deleteOrderList;

/**
 * 取得订单结果校验码
 * @param order     支付成功的订单或修复成功的订单。
 * @param password  APP的支付密码。
 */
- (NSString*)getPayResultEncodeWithOrder:(ROPayOrderInfo*)order andAppPayPassword:(NSString*)password;

@end
