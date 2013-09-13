//
//  ROPayError.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-28.
//  Copyright 2011年 renren－inc. All rights reserved.
//

#import "ROPayError.h"

@implementation ROPayError
@synthesize errorCode = _errorCode;
@synthesize description = _description;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    self.errorCode = nil;
    self.description = nil;
	[super dealloc];
}

@end
