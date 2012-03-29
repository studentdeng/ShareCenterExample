//
//  CUTimelineViewController.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-28.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUTimelineViewController.h"
#import "LoadMoreCell.h"
#import "Status.h"
#import "User.h"
#import "CUSinaShareClient.h"
#import "CUShareCenter.h"
#import "RTTableViewCell.h"

@interface CUTimelineViewController ()

@property (nonatomic, retain) CUTimelineDataSource *timelineDataSource;

@end

@implementation CUTimelineViewController

@synthesize timelineDataSource;
@synthesize tableView;

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        // Custom initialization
        timelineDataSource = [[CUTimelineDataSource alloc] initWithToken:token];
        
        loadMoreCell = [[LoadMoreCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:@"LoadCell"];
    }
    
    return self;
}

- (void)dealloc
{
    self.timelineDataSource.delegate = nil;
    self.timelineDataSource = nil;
    self.tableView = nil;
    [loadMoreCell release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    timelineDataSource.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CUSinaShareClient *sinaClient = [[[CUSinaShareClient alloc] initWithAppKey:kOAuthConsumerKey_sina 
                                                                     appSecret:kOAuthConsumerSecret_sina] autorelease];
    sinaClient.delegate = self;
    [CUShareCenter setupClient:sinaClient withType:SINACLIENT];
    [CUShareCenter setupContainer:self withType:SINACLIENT];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.tableView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark action

- (IBAction)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)refresh:(id)sender
{
    //[self.timelineDataSource loadTimelineBySinceId:0];
    NSNumber *newKey = nil;
    
    for (int i =  0; i < [self.timelineDataSource.timelineDataKey count]; ++i) {
        NSNumber *statusKey = [self.timelineDataSource.timelineDataKey objectAtIndex:i];
        if (statusKey && [statusKey isKindOfClass:[NSNumber class]]) {
            newKey = [[statusKey copy] autorelease];
            
            break;
        }
    }
    
    [self.timelineDataSource loadTimelineBySinceId:[newKey longLongValue]];
}

#pragma mark CUTimelineDataSourceDelegate

- (void)CUTimelineDataSourceFinish:(CUTimelineDataSource *)ds
{
    [self.tableView reloadData];
    
    [super performSelector:@selector(dataSourceDidFinishLoadingNewData:) 
                withObject:[NSNumber numberWithInt:1] 
                afterDelay:0.1];
}

- (void)CUTimelineDataSource:(CUTimelineDataSource *)ds failedWithError:(NSError *)err
{
    NSLog(@"tilelineDataSource load error");
    
    if (err) {
        //err != nil 为网络错误
        [super performSelector:@selector(dataSourceDidFinishLoadingNewData:) withObject:nil afterDelay:0.1];
    }
    else {
        //
        //这里为sina 服务器返回错误，要不sina server crash,要不就是参数错误 要不就是认证失败，认证失败概率最大，这里简单处理了
        [[CUShareCenter sharedInstanceWithType:SINACLIENT] Bind];
        
        [super performSelector:@selector(dataSourceDidFinishLoadingNewData:) withObject:[NSNumber numberWithInt:1]  afterDelay:0.1];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.timelineDataSource.timelineDataKey count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.timelineDataSource.timelineDataKey.count) {
        id obj = [self.timelineDataSource.timelineDataKey objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *statusKey = (NSNumber *)obj;
            Status *status = [self.timelineDataSource.timelineData objectForKey:statusKey];
            
            return [RTTableViewCell rowHeightForObject:status];
        }
    }
    
    return 44;
}

- (UITableViewCell *)getTableViewCell:(NSNumber *)statusKey
{
    static NSString *cellIdentifier = @"RTTableViewCell";
    
    RTTableViewCell *articleTableViewCell = (RTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (articleTableViewCell == nil)
    {
        articleTableViewCell = [[RTTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        // set selection color 
        UIView *backgroundView = [[UIView alloc] initWithFrame:articleTableViewCell.frame]; 
        //backgroundView.backgroundColor = SELECTED_BACKGROUND;
        articleTableViewCell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
    }
    
    Status *status = [self.timelineDataSource.timelineData objectForKey:statusKey];
    if (status) {
        [articleTableViewCell setDataSource:status];
        [articleTableViewCell setAvatarImageUrl:status.user.profileImageUrl 
                                          tagId:2
                                         target:self 
                                         action:@selector(avatarButtonClicked:)];
    }
    
    return articleTableViewCell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.timelineDataSource.timelineDataKey.count) {
        id obj = [self.timelineDataSource.timelineDataKey objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *statusKey = (NSNumber *)obj;
            
            return [self getTableViewCell:statusKey];
        }
    }
    
    return loadMoreCell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)loadMore
{
    NSNumber *lastKey = nil;
    
    for (int i = [self.timelineDataSource.timelineDataKey count] - 1; i >= 0; --i) {
        NSNumber *statusKey = [self.timelineDataSource.timelineDataKey objectAtIndex:i];
        if (statusKey && [statusKey isKindOfClass:[NSNumber class]]) {
            lastKey = [[statusKey copy] autorelease];
            
            break;
        }
    }
    
    if (lastKey) {
        [self.timelineDataSource loadTimelineByMaxId:[lastKey longLongValue] - 1];
    }
    else {
        [self refresh:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.timelineDataSource.timelineDataKey count]) {
        [self loadMore];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)CUAuthSucceed:(CUShareClient *)client
{
    
}

#pragma mark

- (void)reloadTableViewDataSource
{
    [self refresh:nil];
    // Should be calling your tableview's model to reload.
    //[super performSelector:@selector(dataSourceDidFinishLoadingNewData:) withObject:nil afterDelay:3.0];
}

- (void)dataSourceDidFinishLoadingNewData:(NSNumber *)loadedData
{
    // Should check if data reload was successful.
    if ([loadedData boolValue]) {
        [refreshHeaderView setCurrentDate];
        [super dataSourceDidFinishLoadingNewData:nil];
        [self.tableView reloadData];
    } else {
        [super dataSourceDidFinishLoadingNewData:nil];
        // Present an informative UIAlertView
        [self dataSourceDidFailPresentingError];
    }
}

- (void)dataSourceDidFailPresentingError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:@"Unable to contact the server.\n Please try again later."
                                                       delegate:self 
                                              cancelButtonTitle:@"Okay" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


@end
