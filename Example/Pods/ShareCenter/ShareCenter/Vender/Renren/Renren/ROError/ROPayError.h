//
//  ROPayError.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-28.
//  Copyright 2011年 renren－inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROPayError : NSError {
    NSString *_errorCode;
    NSString *_description;
}

/**
 * 错误码
 */
@property (nonatomic, retain)NSString *errorCode;

/**
 * 错误描述
 */
@property (nonatomic, retain)NSString *description;

@end
