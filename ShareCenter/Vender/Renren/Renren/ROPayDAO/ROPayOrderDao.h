//
//  ROPayOrderDao.h
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-10-19.
//  Copyright 2011 renren.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ROPayOrderInfo;
@class ROPayDB;

@interface ROPayOrderDao : NSObject {
    ROPayDB *dbManager;
}

@property (nonatomic, retain) ROPayDB *dbManager;

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table;
-(NSMutableArray *)queryOrderWithUserID:(NSString *)UserID;
-(void)insertWithPayRecord:(ROPayOrderInfo *)order;
-(BOOL)updateOrderWithRecord:(ROPayOrderInfo *)order;
-(BOOL)deleteOrderWithUserID:(NSString *)UserID;
-(ROPayOrderInfo*)getOrderWithOrderNum:(NSString *)orderNum;

@end
