//
//  CUTimeline.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-27.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#define SINA_TIMELINE_DEFAULT_API   @"statuses/friends_timeline.json"

#import "CUTimelineDataSource.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "NSDictionaryAdditions.h"

#import "Status.h"
#import "User.h"

#define MAX_CACHE_WEIBO_ITEM    100

@interface CUTimelineDataSource()

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableArray *statusIds;
@property (nonatomic, retain) NSMutableDictionary *statusDic;
@property (nonatomic, retain) NSString *accessToken;

@end

@implementation CUTimelineDataSource

@synthesize request;
@synthesize statusIds;
@synthesize statusDic;
@synthesize accessToken;
@synthesize delegate;

+ (NSString *)getPath {
    NSString *localFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] 
                               stringByAppendingPathComponent:@"weiboCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:localFilePath 
                                  withIntermediateDirectories:NO 
                                                   attributes:nil 
                                                        error:&error];
    }
    
    return localFilePath;
}

#pragma mark - life

- (id)initWithToken:(NSString *)token
{
    if (self = [super init]) {
        self.accessToken = token;
        statusIds = [[NSMutableArray alloc] initWithCapacity:0];
        statusDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        NSMutableArray *statusArray = [self loadTimelineFromLocal];
        for (Status *item in statusArray) {
            if ([item isKindOfClass:[Status class]]) {
                [statusDic setObject:item forKey:item.statusKey];
                [statusIds addObject:item.statusKey];
            }
            else {
                [statusIds addObject:item];
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self cancel];
    
    [self saveTimelineToLocal];
    
    self.delegate = nil;   
    self.statusIds = nil;
    self.accessToken = nil;
    self.request = nil;
    self.statusDic = nil;
    
    [super dealloc];
}

#pragma mark - common method

- (void)loadTimelineBySinceId:(long long)sinceId
{
    //TODO URL ERROR
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/home_timeline.json?access_token=%@&since_id=%lld&count=20", accessToken, sinceId];
    
    [self.request clearDelegatesAndCancel];
    
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    __block ASIHTTPRequest *aRequest = self.request;
    __block CUTimelineDataSource *vcSelf = self;
    
    [aRequest setFailedBlock:^{
        [vcSelf report:vcSelf withFailed:aRequest.error];
    }];
    
    [aRequest setCompletionBlock:^{
        id jsonObject = [aRequest.responseString JSONValue];
        
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            [vcSelf report:vcSelf withFailed:nil];
        }
        else {
            NSDictionary *result = (NSDictionary *)jsonObject;
            if ([result objectForKey:@"error_code"] && [[result objectForKey:@"error_code"] intValue] != 200) {
                
                NSLog(@"error : %@", result);
                
                [vcSelf report:vcSelf withFailed:nil];
            }
            else {
                
                //TODO parser in background
                NSArray *statusArray = [result objectForKey:@"statuses"];
                if ([statusArray count]) {
                    [vcSelf parseNewData:[result objectForKey:@"statuses"]];
                }
                
                [vcSelf reportSuccess:vcSelf];
            }
        }
    }];
    
    [self.request startAsynchronous];
}

- (void)loadTimelineByMaxId:(long long)maxId
{
    //TODO URL ERROR
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/home_timeline.json?access_token=%@&max_id=%lld&count=20", accessToken, maxId];
    
    [self.request clearDelegatesAndCancel];
    
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    __block ASIHTTPRequest *aRequest = self.request;
    __block CUTimelineDataSource *vcSelf = self;
    
    [aRequest setFailedBlock:^{
        [vcSelf report:vcSelf withFailed:aRequest.error];
    }];
    
    [aRequest setCompletionBlock:^{
        id jsonObject = [aRequest.responseString JSONValue];
        
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            [vcSelf report:vcSelf withFailed:nil];
        }
        else {
            NSDictionary *result = (NSDictionary *)jsonObject;
            if ([result objectForKey:@"error_code"] && [[result objectForKey:@"error_code"] intValue] != 200) {
                [vcSelf report:vcSelf withFailed:nil];
            }
            else {
                
                //TODO parser in background
                
                NSArray *statusArray = [result objectForKey:@"statuses"];
                if ([statusArray count]) {
                    [vcSelf parseMoreData:[result objectForKey:@"statuses"]];
                }
                
                [vcSelf reportSuccess:vcSelf];
            }
        }
    }];
    
    [self.request startAsynchronous];
}


- (NSDictionary *)timelineData
{
    return [NSDictionary dictionaryWithDictionary:self.statusDic];
}

- (NSArray *)timelineDataKey
{
    return [NSArray arrayWithArray:self.statusIds];
}

- (NSMutableArray *)loadTimelineFromLocal
{
    NSString *filePath = [[CUTimelineDataSource getPath] stringByAppendingPathComponent:@"friendsWeiboCache.db"];
    NSMutableArray *statusArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return statusArray;
}

- (void)saveTimelineToLocal
{
    if ([statusDic count] == 0) {
        return;
    }
    
    
    int i = 0;
    NSMutableArray *statuses = [NSMutableArray array];
    for (NSNumber *item in statusIds) {
        if ([item isKindOfClass:[NSNumber class]]) {
			Status *sts = [statusDic objectForKey:item];
			if (sts) {
				[statuses addObject:sts];
			}			
		}
        ++i;
        
        if (MAX_CACHE_WEIBO_ITEM <= i) {
            break;
        }
    }
    
    NSString *filePath = [[CUTimelineDataSource getPath] stringByAppendingPathComponent:@"friendsWeiboCache.db"];
    [NSKeyedArchiver archiveRootObject:statuses toFile:filePath];
}

#pragma mark - private

- (void)cancel
{
    if (request) {
		[request clearDelegatesAndCancel];
		[request release];
		request = nil;
    }
}

- (void)parseNewData:(NSArray *)statusArray
{
    if ([statusArray count] == 0) {
        return;
    }
    
    long long lastSyncStatusId = 0;
    
    NSNumber* lastStatusKey = statusIds.count > 0 ? [statusIds objectAtIndex:0] : nil;
    
    for (int i = [statusArray count] - 1; i >= 0; --i) {
        NSDictionary *item = (NSDictionary *)[statusArray objectAtIndex:i];
        if (![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        long long statusId = [item getLongLongValueValueForKey:@"id" 
                                                  defaultValue:0];
        
        lastSyncStatusId = MAX(statusId, lastSyncStatusId);
        
        if (lastStatusKey && statusId <= [lastStatusKey longLongValue]) {
            continue;
        }
        
        Status *status = [Status statusWithJsonDictionary:item];
        if (status && status.statusId) {
            [self.statusIds insertObject:status.statusKey atIndex:0];
            [self.statusDic setObject:status forKey:status.statusKey];
            
            //TODO 转发
            if (status.retweetedStatus) {
                
            }
        }
    }
    
    /*
    if ([statusArray count] && lastStatusKey && (lastSyncStatusId > [lastStatusKey longLongValue]))
    {
        NSLog(@"data change");
    }
    else {
        NSLog(@"origin data");
    }*/
}

- (void)parseMoreData:(NSArray *)statusArray
{
    if ([statusArray count] == 0) {
        return;
    }
    
    int insertPos = [statusIds count];
    NSNumber *firstStatusKey = nil;
    
    for (int i = [statusIds count] - 1; i >= 0; --i) {
        NSNumber *statusKey = [statusIds objectAtIndex:i];
		if (statusKey && [statusKey isKindOfClass:[NSNumber class]]) {
			firstStatusKey = statusKey;
			break;
		}
    } 
    
    for (int i = [statusArray count] - 1; i >= 0; --i) {
        NSDictionary *item = (NSDictionary *)[statusArray objectAtIndex:i];
        if (![item isKindOfClass:[NSDictionary class]]) {
			continue;
		}
        
		long long statusId = [item getLongLongValueValueForKey:@"id" defaultValue:-1];
		if (statusId <= 0
            || (firstStatusKey && statusId >= [firstStatusKey longLongValue])) {
			// Ignore stale message
			continue;
		}
        
        Status *status = [Status statusWithJsonDictionary:item];
        if (status && status.statusId) {
            [self.statusIds insertObject:status.statusKey atIndex:insertPos];
            [self.statusDic setObject:status forKey:status.statusKey];
        }
        
        //TODO 转发
        if (status.retweetedStatus) {
            
        }
    }
}

- (void)reportSuccess:(CUTimelineDataSource *)datasource
{
    if ([delegate respondsToSelector:@selector(CUTimelineDataSourceFinish:)]) {
        [delegate CUTimelineDataSourceFinish:self];
    }
}

- (void)report:(CUTimelineDataSource *)datasource withFailed:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(CUTimelineDataSource:failedWithError:)]) {
        [delegate CUTimelineDataSource:self failedWithError:error];
    }
}

@end
