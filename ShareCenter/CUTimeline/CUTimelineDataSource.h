//
//  CUTimeline.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-27.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CUTimelineDataSource;
@protocol CUTimelineDataSourceDelegate <NSObject>

@optional
- (void)CUTimelineDataSourceFinish:(CUTimelineDataSource *)ds;
- (void)CUTimelineDataSource:(CUTimelineDataSource *)ds failedWithError:(NSError *)err;

@end

@class ASIHTTPRequest;
@interface CUTimelineDataSource : NSObject
{
    NSMutableArray *statusIds;
    NSMutableDictionary *statusDic;
    
    ASIHTTPRequest *request;
    
    NSString *accessToken;
    
    id <CUTimelineDataSourceDelegate> delegate;
}

@property (nonatomic, assign) id <CUTimelineDataSourceDelegate> delegate;

- (id)initWithToken:(NSString *)token;
- (void)loadTimelineBySinceId:(long long)sinceId;
- (void)loadTimelineByMaxId:(long long)maxId;

- (NSMutableArray *)loadTimelineFromLocal;
- (void)saveTimelineToLocal;

- (NSDictionary *)timelineData;
- (NSArray *)timelineDataKey;

@end
