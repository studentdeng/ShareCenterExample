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

- (id)initWithToken:(NSString *)token
{
    if (self = [super init]) {
        self.accessToken = token;
        statusIds = [[NSMutableArray alloc] initWithCapacity:0];
        statusDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)dealloc
{
    [self cancel];
    
    self.delegate = nil;   
    self.statusIds = nil;
    self.accessToken = nil;
    self.request = nil;
    self.statusDic = nil;
    
    [super dealloc];
}

- (NSDictionary *)timelineData
{
    return [NSDictionary dictionaryWithDictionary:self.statusDic];
}

- (NSArray *)timelineDataKey
{
    return [NSArray arrayWithArray:self.statusIds];
}

- (void)loadTimelineBySinceId:(long long)sinceId
{
    //TODO URL ERROR
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/home_timeline.json?access_token=%@&since_id=%lld&count=20", accessToken, sinceId];
    
    self.request.delegate = nil;
    [self.request cancel];
    
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [self.request setFailedBlock:^{
        [self report:self withFailed:request.error];
    }];
    
    [self.request setCompletionBlock:^{
        id jsonObject = [request.responseString JSONValue];
        
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            [self report:self withFailed:nil];
        }
        else {
            NSDictionary *result = (NSDictionary *)jsonObject;
            if ([result objectForKey:@"error_code"] && [[result objectForKey:@"error_code"] intValue] != 200) {
                [self report:self withFailed:nil];
            }
            else {
                
                //TODO parser in background
                
                NSArray *statusArray = [result objectForKey:@"statuses"];
                if ([statusArray count]) {
                    [self parseNewData:[result objectForKey:@"statuses"]];
                }
                
                [self reportSuccess:self];
            }
        }
    }];
    
    [self.request startAsynchronous];
}

- (void)loadTimelineByMaxId:(long long)maxId
{
    //TODO URL ERROR
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/home_timeline.json?access_token=%@&max_id=%lld&count=20", accessToken, maxId];
    
    self.request.delegate = nil;
    [self.request cancel];
    
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [self.request setFailedBlock:^{
        [self report:self withFailed:request.error];
    }];
    
    [self.request setCompletionBlock:^{
        id jsonObject = [request.responseString JSONValue];
        
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            [self report:self withFailed:nil];
        }
        else {
            NSDictionary *result = (NSDictionary *)jsonObject;
            if ([result objectForKey:@"error_code"] && [[result objectForKey:@"error_code"] intValue] != 200) {
                [self report:self withFailed:nil];
            }
            else {
                
                //TODO parser in background
                
                NSArray *statusArray = [result objectForKey:@"statuses"];
                if ([statusArray count]) {
                    [self parseMoreData:[result objectForKey:@"statuses"]];
                }
                
                [self reportSuccess:self];
            }
        }
    }];
    
    [self.request startAsynchronous];
}

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
