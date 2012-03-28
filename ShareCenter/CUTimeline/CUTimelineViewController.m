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
    self.timelineDataSource = nil;
    self.tableView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    timelineDataSource.delegate = self;
    
    [timelineDataSource loadRecentSinceID:0];
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

#pragma mark CUTimelineDataSourceDelegate

- (void)CUTimelineDataSourceFinish:(CUTimelineDataSource *)ds
{
    [self.tableView reloadData];
}

- (void)CUTimelineDataSource:(CUTimelineDataSource *)ds failedWithError:(NSError *)err
{
    NSLog(@"tilelineDataSource load error");
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.timelineDataSource.timelineDataKey count];
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

@end
