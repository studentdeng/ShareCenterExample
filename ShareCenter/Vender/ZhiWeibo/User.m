//
//  User.m
//  helloWeibo
//
//  Created by junmin liu on 11-4-13.
//  Copyright 2011年 Openlab. All rights reserved.
//

#import "User.h"


@implementation User
@synthesize userId = _userId;
@synthesize screenName = _screenName;
@synthesize profileImageUrl = _profileImageUrl;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        _userId = [decoder decodeInt64ForKey:@"userId"];
        _profileImageUrl = [[decoder decodeObjectForKey:@"profileImageUrl"]retain];
        _screenName = [[decoder decodeObjectForKey:@"screenName"] retain];
    }
    return self;
}     

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt64:_userId forKey:@"userId"];
    [encoder encodeObject:_screenName forKey:@"screenName"];
    [encoder encodeObject:_profileImageUrl forKey:@"profileImageUrl"];
}

- (id)initWithJsonDictionary:(NSDictionary*)dic {
    self = [super init];
    if (self) {
        _userId = [[dic objectForKey:@"id"] longLongValue];
        _screenName = [[dic objectForKey:@"screen_name"] retain];
        _profileImageUrl = [[dic objectForKey:@"profile_image_url"] retain];
    }
    return self;
}


+ (User*)userWithJsonDictionary:(NSDictionary*)dic
{
    User *u = [[User alloc] initWithJsonDictionary:dic];
    return [u autorelease];
}


- (void)dealloc {
    [_screenName release];
    [_profileImageUrl release];
    [super dealloc];
}

@end
