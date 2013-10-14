//
//  ROPayOrderDao.m
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-10-19.
//  Copyright 2011 renren.com. All rights reserved.
//

#import "ROPayOrderInfo.h"
#import "ROPayOrderDao.h"
#import "ROPayDB.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#define TABLE_NAME @"ORDERS"

@implementation ROPayOrderDao
@synthesize dbManager;

- (id)init{
	if(self = [super init])
	{
		dbManager = [[ROPayDB alloc] init];
        [dbManager initDatabase];
	}
	
	return self;
}

// SELECT
-(NSMutableArray *)queryOrderWithUserID:(NSString *)UserID
{
	NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE USERID='%@'",TABLE_NAME,UserID];
    
	FMResultSet *rs = [[dbManager getDatabase] executeQuery:querySQL];
	while ([rs next]) {
		ROPayOrderInfo *tr = [[ROPayOrderInfo alloc] init];
        tr.appID = [rs stringForColumn:@"APPID"];
        tr.tradingVolume = [rs stringForColumn:@"TRADINGVOLUME"];
        tr.orderNum = [rs stringForColumn:@"ORDERNUM"];
        tr.orderTime = [rs stringForColumn:@"ORDERTIME"];
        tr.serialNum = [rs stringForColumn:@"SERIALNUM"];
        tr.userID = [rs stringForColumn:@"USERID"];
        tr.orderCheckCode = [rs stringForColumn:@"CHECKCODE"];
        tr.localOrderStatus = [rs stringForColumn:@"LOCALORDERSTATUS"];
        tr.serverOrderStatus = [rs stringForColumn:@"SERVERORDERSTATUS"];
        tr.description = [rs stringForColumn:@"DESCRIPTION"];
        tr.payEncode = [rs stringForColumn:@"PAYENCODE"];
        tr.isTestOrder = [rs stringForColumn:@"ISTESTORDER"];
        tr.payStatusCode = [rs stringForColumn:@"PAYSTATUSCODE"];
        tr.payment = [rs stringForColumn:@"PAYMENT"];
		[result addObject:tr];
		[tr release];
	}
	
	[rs close];
	
	return result;
}

-(ROPayOrderInfo*)getOrderWithOrderNum:(NSString *)orderNum
{
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ORDERNUM='%@'",TABLE_NAME,orderNum];
    
	FMResultSet *rs = [[dbManager getDatabase] executeQuery:querySQL];
    ROPayOrderInfo *tr = [[[ROPayOrderInfo alloc] init] autorelease];
	while ([rs next]) {
        tr.appID = [rs stringForColumn:@"APPID"];
        tr.tradingVolume = [rs stringForColumn:@"TRADINGVOLUME"];
        tr.orderNum = [rs stringForColumn:@"ORDERNUM"];
        tr.orderTime = [rs stringForColumn:@"ORDERTIME"];
        tr.serialNum = [rs stringForColumn:@"SERIALNUM"];
        tr.userID = [rs stringForColumn:@"USERID"];
        tr.orderCheckCode = [rs stringForColumn:@"CHECKCODE"];
        tr.localOrderStatus = [rs stringForColumn:@"LOCALORDERSTATUS"];
        tr.serverOrderStatus = [rs stringForColumn:@"SERVERORDERSTATUS"];
        tr.description = [rs stringForColumn:@"DESCRIPTION"];
        tr.payEncode = [rs stringForColumn:@"PAYENCODE"];
        tr.isTestOrder = [rs stringForColumn:@"ISTESTORDER"];
        tr.payStatusCode = [rs stringForColumn:@"PAYSTATUSCODE"];
        tr.payment = [rs stringForColumn:@"PAYMENT"];
	}
	
	[rs close];
    
    return tr;
}


// INSERT
-(void)insertWithPayRecord:(ROPayOrderInfo *)order
{
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (APPID, TRADINGVOLUME, ORDERNUM, ORDERTIME, SERIALNUM, USERID, LOCALORDERSTATUS, SERVERORDERSTATUS,PAYENCODE,DESCRIPTION,ISTESTORDER,CHECKCODE,PAYMENT) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_NAME];
	[[dbManager getDatabase] executeUpdate:insertSQL, order.appID, order.tradingVolume, order.orderNum, order.orderTime, order.serialNum, order.userID, order.localOrderStatus, order.serverOrderStatus, order.payEncode,order.description,order.isTestOrder,order.orderCheckCode,order.payment];
	if ([[dbManager getDatabase] hadError]) {
		NSLog(@"Err %d: %@", [[dbManager getDatabase] lastErrorCode], [[dbManager getDatabase] lastErrorMessage]);
	}
}


// UPDATE
-(BOOL)updateOrderWithRecord:(ROPayOrderInfo *)order
{
	BOOL success = YES;
	[[dbManager getDatabase] executeUpdate:[self SQL:@"UPDATE %@ SET TRADINGVOLUME=?, SERIALNUM=?,SERVERORDERSTATUS=?, ORDERTIME=?, PAYENCODE=?, PAYMENT=?, PAYSTATUSCODE=? WHERE ORDERNUM=?" inTable:TABLE_NAME],
	                                    order.tradingVolume, order.serialNum, order.serverOrderStatus,order.orderTime, order.payEncode,order.payment,order.payStatusCode,order.orderNum];
	if ([[dbManager getDatabase] hadError]) {
		NSLog(@"Err %d: %@", [[dbManager getDatabase] lastErrorCode], [[dbManager getDatabase] lastErrorMessage]);
		success = NO;
	}
	
	return success;
}


// DELETE
- (BOOL)deleteOrderWithUserID:(NSString *)UserID
{
	BOOL success = YES;
	[[dbManager getDatabase] executeUpdate:[self SQL:@"DELETE FROM %@ WHERE USERID = ?" inTable:TABLE_NAME], UserID];
	if ([[dbManager getDatabase] hadError]) {
		NSLog(@"Err %d: %@", [[dbManager getDatabase] lastErrorCode], [[dbManager getDatabase] lastErrorMessage]);
		success = NO;
	}
	return success;
}

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table {
	return [NSString stringWithFormat:sql, table];
}

- (void)dealloc {
    [dbManager closeDatabase];
	[dbManager release];
	[super dealloc];
}

@end