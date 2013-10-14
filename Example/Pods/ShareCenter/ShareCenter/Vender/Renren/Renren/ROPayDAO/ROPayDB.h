//
//  ROPayDB.h
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-10-19.
//  Copyright 2011 renren.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface ROPayDB : NSObject {
	FMDatabase *db;
}

- (BOOL)initDatabase;
- (void)closeDatabase;
- (FMDatabase *)getDatabase;

@end
