//
//  RenrenPay.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-17.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import "RenrenPay.h"
#import "ROPayOrderDao.h"
#import "ROPayOrderInfo.h"
#import "ROCheckDialogViewController.h"
#import "ROPayDialogViewController.h"
#import "ROPayNavigationViewController.h"
#import "ROCheckNavigationViewController.h"

enum checkAppStatus {
    AppStatus_Non,
    AppStatus_CannotPay,
    AppStatus_Checking,
    AppStatus_CanPay
    };

static NSInteger _payStatus = AppStatus_Non;

@interface RenrenPay(private)

- (NSMutableDictionary*)prepareSubmitUrlParams:(ROPayOrderInfo *)order;
- (NSMutableDictionary*)prepareRepairUrlParams:(ROPayOrderInfo *)order;
- (void)authorizationWithPermisson:(NSArray *)permissions;
- (void)authorizationWithPermisson:(NSArray *)permission
               andParentController:(UIViewController *)controller;

- (void)checkAppPayStatus;

- (void)saveUserSessionInfo:(NSDictionary*)dictionary;

- (NSString*)makeOrderCheckCode:(ROPayOrderInfo *)order;

@end

@implementation RenrenPay
@synthesize payDao = _payDao;
@synthesize renren = _renren;
@synthesize payRequest = _payRequest;
@synthesize delegate = _delegate;
@synthesize tempOrder = _tempOrder;
@synthesize isTest = _isTest;
@synthesize appSecret = _appSecret;

- (id)initPayWithRenren:(Renren*)renren andSecretKey:(NSString *)secret andLocalMem:(BOOL)isUsed
{
    self = [super init];
    if (self) {
        // Initialization code here.
        if (isUsed) {
            _payDao = [[ROPayOrderDao alloc] init];
        } else {
            _payDao = nil;
        }
        self.renren = renren;
        self.appSecret = secret;
        if (_payStatus == AppStatus_Non) {
            _payStatus = AppStatus_Checking;
            [self checkAppPayStatus];
        }
        self.isTest = NO;
    }
    
    return self;
}

- (void)checkAppPayStatus
{
    NSDate *nowTime = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *dateString = [formatter stringFromDate:nowTime];
    [formatter release];
    
    NSMutableString *calcStr = [[[NSMutableString alloc] init] autorelease];
    [calcStr appendFormat:@"%@%@%@",kAPP_ID,dateString,self.appSecret];
    
    NSString *checkCode = [ROUtility md5HexDigest:calcStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:kAPP_ID,@"app_id",
                                   dateString,@"time",
                                   checkCode,@"app_encode",nil];
    
    self.payRequest = [self.renren openUrl:kCheckAppStatusURL params:params httpMethod:@"POST" delegate:self];
}

- (NSString*)getOrderNumber
{
    NSDate *nowTime = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:nowTime];
    [formatter release];
    
    NSString *appIDHeadFourChar = [[NSString stringWithFormat:kAPP_ID] substringWithRange:NSMakeRange(0,4)];
    
    NSString *random = [NSString stringWithFormat:@"%04d",arc4random()%10000];
    
    NSString *orderNumber = [NSString stringWithFormat:@"%@%@%@%@",kIPhonePaySDK,appIDHeadFourChar,dateString,random];
    
   return orderNumber;
}

- (ROPayOrderInfo *)makePayOrderWithOrderNum:(NSString *)orderNum 
                                    andAmount:(NSUInteger)amount 
                               andDescription:(NSString *)description 
                                   andPayment:(NSString*)payment
{
    if (orderNum == nil || [orderNum isEqualToString:@""]) {
        NSLog(@"makePayOrder------orderNum is nil or empty!!!");
        return nil;
    }
    NSDate *nowTime = [NSDate date];
    NSTimeInterval timeInterval = [nowTime timeIntervalSince1970];
    NSString *timeData = [NSString stringWithFormat:@"%0.0f",timeInterval];
    
    NSArray *tokenArray = [self.renren.accessToken componentsSeparatedByString:@"-"];
    NSString *userID = [tokenArray objectAtIndex:1];
    
    ROPayOrderInfo *order = [[[ROPayOrderInfo alloc] init] autorelease];
    order.appID = kAPP_ID;
    order.tradingVolume = [NSString stringWithFormat:@"%d",amount];
    order.orderNum = orderNum;
    order.orderTime = timeData;
    order.userID = userID;
    order.description = description;
    order.localOrderStatus = @"订单失败";
    order.payment = payment;
    
    return order;
}

- (void)submitPayOrderWithOrder:(ROPayOrderInfo*)order 
                 andPermissions:(NSArray*)permissions 
                    andDelegate:(id<RenrenPayDelegate>)delegate;
{
    if (order == nil) {
        NSLog(@"submitPayOrder------order is nil!!!");
        return;
    }
    self.delegate = delegate;
    if (_payStatus == AppStatus_CannotPay && self.isTest == NO) {
        UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:@"错误提示" message:@"支付状态错误" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if (![self.renren isSessionValid]) {
		[self authorizationWithPermisson:permissions];
        self.tempOrder = order;
        return;
    }
    
    NSMutableDictionary *params = [self prepareSubmitUrlParams:order];
    
    ROPayDialogViewController *payViewController = [[ROPayDialogViewController alloc] init];
    payViewController.params = params;
    payViewController.delegate = self;
    
    if (self.isTest) {
        payViewController.url = kTestSubmitOrderURL;
        order.isTestOrder = kIsTestOrder;
        
    } else {
        payViewController.url = kSubmitOrderURL;
        order.isTestOrder = kIsNotTestOrder;
    }
    
    [payViewController show];
    
    if (self.payDao != nil) {
        order.orderCheckCode = [self makeOrderCheckCode:order];
        [self.payDao insertWithPayRecord:order];
    }
}

- (void)submitPayOrderInNavigationWithOrder:(ROPayOrderInfo*)order 
                             andPermissions:(NSArray*)permissions 
                                andDelegate:(id<RenrenPayDelegate>)delegate
{
    if (order == nil) {
        NSLog(@"submitPayOrderInNavigation------order is nil!!!");
        return;
    }
    self.delegate = delegate;
    if (_payStatus == AppStatus_CannotPay && self.isTest == NO) {
        UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:@"错误提示" message:@"支付状态错误" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    if (![self.renren isSessionValid]) {
		[self authorizationWithPermisson:permissions andParentController:nil];
        self.tempOrder = order;
        return;
    }
    
    NSMutableDictionary *params = [self prepareSubmitUrlParams:order];
    
    ROPayNavigationViewController *payViewController = [[ROPayNavigationViewController alloc] init];
    if (self.isTest) {
        payViewController.url = kTestSubmitOrderURL;
        order.isTestOrder = kIsTestOrder;
    } else {
        payViewController.url = kSubmitOrderURL;
        order.isTestOrder = kIsNotTestOrder;
    };
    
    payViewController.params = params;
    payViewController.delegate = self;
    [payViewController show];
    
    if (self.payDao != nil) {
        order.orderCheckCode = [self makeOrderCheckCode:order];
        [self.payDao insertWithPayRecord:order];
    }
}

- (void)queryOrderListWithDelegate:(id<RenrenPayDelegate>)delegate
{
    if (self.payDao == nil) {
        NSLog(@"queryOrderList------local memory is not used!!!");
        return;
    }
    self.delegate = delegate;
    ROCheckDialogViewController *checkViewController = [[ROCheckDialogViewController alloc] init];
    NSMutableArray *result = [self.payDao queryOrderWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"session_UserId"]];
    
    checkViewController.result = result;
    checkViewController.delegate = self;
    [checkViewController show];
}

- (void)queryOrderListInNavigationWithDelegate:(id<RenrenPayDelegate>)delegate
{
    if (self.payDao == nil) {
        NSLog(@"queryOrderListInNavigation------local memory is not used!!!");
        return;
    }
    self.delegate = delegate;
    NSMutableArray *result = [self.payDao queryOrderWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"session_UserId"]];
    
    ROCheckNavigationViewController *checkViewController = [[ROCheckNavigationViewController alloc] initWithResult:result];
    
    checkViewController.delegate = self;
    [checkViewController show];
}

- (void)deleteOrderList
{
    if (self.payDao == nil) {
        NSLog(@"deleteOrderList------local memory is not used!!!");
        return;
    }
    [self.payDao deleteOrderWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"session_UserId"]];
}

- (void)request:(RORequest *)request didLoad:(id)result;
{
    NSDictionary *resultInfo = (NSDictionary *)result;
    
    NSArray *statusCodes = [resultInfo objectForKey:@"payStatusCodes"];
    
    NSInteger status = [[statusCodes objectAtIndex:0] intValue];
    
    if ( status == 201 || status == 202 || status ==203 || status == 204 || status == 205 ) {
        _payStatus = AppStatus_CannotPay;
    } else {
        _payStatus = AppStatus_CanPay;
    }
}

- (void)request:(RORequest *)request didFailWithROError:(ROError *)error;
{
    UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:@"错误提示" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void)renrenDialogPaySuccess:(id)result
{
    if (self.payDao != nil) {
        ROPayOrderInfo *updateOrder = (ROPayOrderInfo *)result;
        [self.payDao updateOrderWithRecord:updateOrder];
        
        ROPayOrderInfo *order = [self.payDao getOrderWithOrderNum:updateOrder.orderNum];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(payDidSuccessWithOrder:)]) {
            [self.delegate payDidSuccessWithOrder:order];
        }
    } else {
        ROPayOrderInfo *order = (ROPayOrderInfo *)result;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(payDidSuccessWithOrder:)]) {
            [self.delegate payDidSuccessWithOrder:order];
        }
    }
}

- (void)renrenDialogPayError:(ROPayError*)error;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(payDidFailWithError:)]) {
        [self.delegate payDidFailWithError:error];
    }
}

- (void)renrenDialogRepairSuccess:(id)result
{
    if (self.payDao != nil) {
        ROPayOrderInfo *updateOrder = (ROPayOrderInfo *)result;
        [self.payDao updateOrderWithRecord:updateOrder];
        
        ROPayOrderInfo *order = [self.payDao getOrderWithOrderNum:updateOrder.orderNum];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(repairOrderDidSuccessWithOrder:)]) {
            [self.delegate repairOrderDidSuccessWithOrder:order];
        }
    } else {
        ROPayOrderInfo *order = (ROPayOrderInfo *)result;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(repairOrderDidSuccessWithOrder:)]) {
            [self.delegate repairOrderDidSuccessWithOrder:order];
        }
    }
}

- (void)renrenDialogRepairError:(ROPayError*)error;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(repairOrderDidFailWithError:)]) {
        [self.delegate repairOrderDidFailWithError:error];
    }
}


#pragma mark - RODialogDelegate Methods -

- (void)authDialog:(id)dialog withOperateType:(RODialogOperateType )operateType
{
    NSDictionary* authDictionary = nil;
    switch (operateType) {
        case RODialogOperateSuccess:
            if ([dialog isKindOfClass:[ROWebDialogViewController class]]) {
                ROWebDialogViewController *viewController = (ROWebDialogViewController *)dialog;
                authDictionary = viewController.response.rootObject;
                [self saveUserSessionInfo:authDictionary];
                
                NSArray *tokenArray = [self.renren.accessToken componentsSeparatedByString:@"-"];
                NSString *userID = [tokenArray objectAtIndex:1];
                self.tempOrder.userID = userID;
                
                NSMutableDictionary *params = [self prepareSubmitUrlParams:self.tempOrder];
                
                ROPayDialogViewController *payViewController = [[ROPayDialogViewController alloc] init] ;
                payViewController.params = params;
                payViewController.delegate = self;
                if (self.isTest) {
                    payViewController.url = kTestSubmitOrderURL;
                } else {
                    payViewController.url = kSubmitOrderURL;
                }
                
                [payViewController show];
            } else if ([dialog isKindOfClass:[ROWebNavigationViewController class]]) {
                ROWebNavigationViewController *viewController = (ROWebNavigationViewController *)dialog;
                authDictionary = viewController.response.rootObject;
                [self saveUserSessionInfo:authDictionary];
                
                NSArray *tokenArray = [self.renren.accessToken componentsSeparatedByString:@"-"];
                NSString *userID = [tokenArray objectAtIndex:1];
                self.tempOrder.userID = userID;
                
                NSMutableDictionary *params = [self prepareSubmitUrlParams:self.tempOrder];
                
                ROPayNavigationViewController *payViewController = [[ROPayNavigationViewController alloc] init];
                if (self.isTest) {
                    payViewController.url = kTestSubmitOrderURL;
                } else {
                    payViewController.url = kSubmitOrderURL;
                }
                payViewController.params = params;
                payViewController.delegate = self;
                
                [viewController change:payViewController];
            }
            
            if (self.payDao != nil) {
                self.tempOrder.orderCheckCode = [self makeOrderCheckCode:self.tempOrder];
                [self.payDao insertWithPayRecord:self.tempOrder];
            }
            self.tempOrder = nil;
            break;
        case RODialogOperateFailure:
            if (self.delegate && [self.delegate respondsToSelector:@selector(payDidFailWithError:)]) {
                ROPayError *error = [[[ROPayError alloc] init] autorelease];
                error.errorCode = [NSString stringWithFormat:@"302"];
                error.description = [NSString stringWithFormat:@"用户登录失败"];;
                [self.delegate payDidFailWithError:error];
            }
            break;
        default:
            break;
    }
    
}

- (void)renrenRepairOrder:(ROPayOrderInfo *)order andPresentController:(id)viewController
{
    if (self.payDao == nil) {
        NSLog(@"renrenRepairOrder------local memory is not used!!!");
        return;
    }
    
    if (![order.orderCheckCode isEqualToString:[self makeOrderCheckCode:order]]) {
        UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:@"错误提示" message:@"很抱歉，订单存储错误，无法完成修复" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    NSMutableDictionary *params = [self prepareRepairUrlParams:order];
    
    if ([viewController isKindOfClass:[ROCheckDialogViewController class]]) {
        
        ROPayDialogViewController *payViewController = [[ROPayDialogViewController alloc] init];
        payViewController.params = params;
        payViewController.delegate = self;
        if ([order.isTestOrder isEqualToString:kIsTestOrder]) {
            payViewController.url = kTestFixOrderURL;
        } else {
            payViewController.url = kFixOrderURL;
        }
        
        [payViewController show];
    } else if ([viewController isKindOfClass:[ROCheckNavigationViewController class]]) {
        ROPayNavigationViewController *payViewController = [[ROPayNavigationViewController alloc] init];
        payViewController.params = params;
        if ([order.isTestOrder isEqualToString:kIsTestOrder]) {
            payViewController.url = kTestFixOrderURL;
        } else {
            payViewController.url = kFixOrderURL;
        }
        payViewController.delegate = self;
        
        ROCheckNavigationViewController *checkController = (ROCheckNavigationViewController *)viewController;
        [checkController change:payViewController];
    }
}

- (NSMutableDictionary*)prepareRepairUrlParams:(ROPayOrderInfo *)order
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:kAPP_ID,@"app_id",self.renren.accessToken,@"access_token",nil];
    
    if (order.tradingVolume != nil && ![order.tradingVolume isEqualToString:@""]) {
        [params setObject:order.tradingVolume forKey:@"amount"];
    }
    
    if (order.orderNum != nil && ![order.orderNum isEqualToString:@""]) {
        [params setObject:order.orderNum forKey:@"order_number"];
    }
    
    NSString *fixEncode = [ROUtility md5HexDigest:[NSString stringWithFormat:@"%@%@%@%@%@%@",order.userID,order.appID,order.orderNum,order.tradingVolume,order.orderTime,self.appSecret]];
    [params setObject:fixEncode forKey:@"fix_encode"];
    
    if (order.orderTime != nil && ![order.orderTime isEqualToString:@""]) {
        [params setObject:order.orderTime forKey:@"fix_time"];
    }
    
    return params;
}

- (NSMutableDictionary*)prepareSubmitUrlParams:(ROPayOrderInfo *)order
{
    NSMutableString *calcStr = [[[NSMutableString alloc] init] autorelease];
    [calcStr appendFormat:@"%@%@%@%@",kAPP_ID,order.orderNum,order.orderTime,self.appSecret];
    NSString *appCode = [ROUtility md5HexDigest:calcStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kAPP_ID,@"app_id",
                                   appCode,@"app_encode",
                                   self.renren.accessToken,@"access_token",nil];
    if (order.tradingVolume != nil && ![order.tradingVolume isEqualToString:@""]) {
        [params setObject:order.tradingVolume forKey:@"amount"];
    }
    
    if (order.orderTime != nil && ![order.orderTime isEqualToString:@""]) {
        [params setObject:order.orderTime forKey:@"submitTime"];
    }
    
    if (order.orderNum != nil && ![order.orderNum isEqualToString:@""]) {
        [params setObject:order.orderNum forKey:@"order_number"];
    }
    
    if (order.description != nil && ![order.description isEqualToString:@""]) {
        [params setObject:order.description forKey:@"descr"];
    }
    
    if (order.payment != nil && ![order.payment isEqualToString:@""]) {
        [params setObject:order.payment forKey:@"payment"];
    }
    
    return params;
}

- (void)authorizationWithPermisson:(NSArray *)permissions
               andParentController:(UIViewController *)controller
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* graphCookies = [cookies cookiesForURL:
                             [NSURL URLWithString:@"http://graph.renren.com"]];
	
	for (NSHTTPCookie* cookie in graphCookies) {
		[cookies deleteCookie:cookie];
	}
	NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
	
	for (NSHTTPCookie* cookie in widgetCookies) {
		[cookies deleteCookie:cookie];
	}
    if (![self.renren isSessionValid]) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:kAPI_Key forKey:@"client_id"];
        [parameters setValue:kRRSuccessURL forKey:@"redirect_uri"];
        [parameters setValue:@"token" forKey:@"response_type"];
        [parameters setValue:@"touch" forKey:@"display"];
        if (nil != permissions) {
            NSString *permissionScope = [permissions componentsJoinedByString:@","];
            [parameters setValue:permissionScope forKey:@"scope"];
        }
        
        ROWebNavigationViewController *viewController = [[ROWebNavigationViewController alloc] init];
        viewController.serverURL = kAuthBaseURL;
        viewController.params = parameters;
        viewController.delegate = self;
        
        [viewController show];
    }
}

- (void)authorizationWithPermisson:(NSArray *)permissions
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* graphCookies = [cookies cookiesForURL:
                             [NSURL URLWithString:@"http://graph.renren.com"]];
	
	for (NSHTTPCookie* cookie in graphCookies) {
		[cookies deleteCookie:cookie];
	}
	NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
	
	for (NSHTTPCookie* cookie in widgetCookies) {
		[cookies deleteCookie:cookie];
	}
    if (![self.renren isSessionValid]) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:kAPI_Key forKey:@"client_id"];
        [parameters setValue:kRRSuccessURL forKey:@"redirect_uri"];
        [parameters setValue:@"token" forKey:@"response_type"];
        [parameters setValue:@"touch" forKey:@"display"];
        if (nil != permissions) {
            NSString *permissionScope = [permissions componentsJoinedByString:@","];
            [parameters setValue:permissionScope forKey:@"scope"];
        }
        
        ROWebDialogViewController *viewController = [[ROWebDialogViewController alloc] init];
        viewController.params = parameters;
        viewController.delegate = self;
        viewController.serverURL = kAuthBaseURL;
        
        [viewController show];
    }
}

- (void)saveUserSessionInfo:(NSDictionary*)dictionary
{
    self.renren.accessToken = [dictionary objectForKey:@"token"];
    self.renren.expirationDate = [dictionary objectForKey:@"expirationDate"];
    self.renren.sessionKey = [ROUtility getSessionKeyByToken:self.renren.accessToken];
    self.renren.secret = [ROUtility getSecretKeyByToken:self.renren.accessToken];
    //用户信息保存到本地
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
    if (self.renren.accessToken) {
        [defaults setObject:self.renren.accessToken forKey:@"access_Token"];
    }
    if (self.renren.expirationDate) {
        [defaults setObject:self.renren.expirationDate forKey:@"expiration_Date"];
    }	
    if (self.renren.sessionKey) {
        [defaults setObject:self.renren.sessionKey forKey:@"session_Key"];
        [defaults setObject:self.renren.secret forKey:@"secret_Key"];
    }
    [defaults synchronize];
    
    [self.renren getLoggedInUserId];
}

- (NSString*)makeOrderCheckCode:(ROPayOrderInfo *)order
{
    NSString *orderStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",order.userID,order.appID,order.orderNum,order.tradingVolume,order.description,self.appSecret];
    
    return [ROUtility md5HexDigest:orderStr];
}

- (NSString*)getPayResultEncodeWithOrder:(ROPayOrderInfo*)order andAppPayPassword:(NSString*)password
{
    NSString *orderStr = [NSString stringWithFormat:@"%@true%@%@%@%@%@",order.isTestOrder,order.userID,order.appID,order.orderNum,order.tradingVolume,password];
    
    return [ROUtility md5HexDigest:orderStr];
}

- (void)dealloc
{
    self.payDao = nil;
    self.renren = nil;
    self.payRequest = nil;
    self.tempOrder = nil;
    self.appSecret = nil;
    [super dealloc];
}

@end
