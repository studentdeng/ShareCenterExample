//
//  CUTimelineViewController.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-28.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUTimelineDataSource.h"
#import "CUShareClient.h"

@class LoadMoreCell;
@interface CUTimelineViewController : UIViewController
<CUTimelineDataSourceDelegate, UITableViewDataSource, UITableViewDelegate, CUShareClientDelegate>
{
    CUTimelineDataSource *timelineDataSource;
    
    UITableView *tableView;
    LoadMoreCell *loadMoreCell;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id)initWithToken:(NSString *)token;

- (IBAction)close:(id)sender;
- (IBAction)refresh:(id)sender;

@end
