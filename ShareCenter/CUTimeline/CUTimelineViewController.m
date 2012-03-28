//
//  CUTimelineViewController.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-28.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUTimelineViewController.h"
#import "ABTableViewCell.h"
#import "LoadMoreCell.h"
#import "Status.h"
#import "CUSinaShareClient.h"
#import "CUShareCenter.h"

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
}

- (void)CUTimelineDataSource:(CUTimelineDataSource *)ds failedWithError:(NSError *)err
{
    NSLog(@"tilelineDataSource load error");
    
    [[CUShareCenter sharedInstanceWithType:SINACLIENT] Bind];
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
            
            CGSize size = [status.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240, 99999)];
            
            CGFloat height = size.height;
            if (height < 80) {
                height = 80;
            }
            
            return height;
        }
    }
    
    return 44;
}

- (UITableViewCell *)getTableViewCell:(NSNumber *)statusKey
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Status *sts = [self.timelineDataSource.timelineData objectForKey:statusKey];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = sts.text;
    cell.imageView.image = [UIImage imageNamed:@"profile_avatar_highlighted_frame.png"];
    
    //[self startImageDownload:sts forIndexPath:indexPath];     
    // Configure the cell.
    
    return cell;
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
    if ([self.timelineDataSource.timelineDataKey count] == 0) {
        //return;
    }
    
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
}

- (void)CUAuthSucceed:(CUShareClient *)client
{
    
}


@end
