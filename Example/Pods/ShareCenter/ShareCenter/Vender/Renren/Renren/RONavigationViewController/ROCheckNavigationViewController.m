//
//  ROCheckNavigationViewController.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-14.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

#import "ROCheckNavigationViewController.h"

@implementation ROCheckNavigationViewController
@synthesize orderView = _orderView;
@synthesize result = _result;
@synthesize delegate = _delegate;

- (id)initWithResult:(NSMutableArray *)result;
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.result = result;
        
        self.orderView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)] autorelease];
        self.orderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.orderView.delegate = self;
        self.orderView.dataSource = self;
        self.orderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.orderView];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.orderView.frame.size.width, 32)];
        headerView.backgroundColor = [UIColor colorWithRed:0.0 green:94.0/255.0 blue:172.0/255.0 alpha:1.0];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PayLogo.png"]];
        imageView.frame = CGRectMake(0, 0, 98, 32);
        [headerView addSubview:imageView];
        [imageView release];
        
        self.orderView.tableHeaderView = headerView;
        [headerView release];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)repairOrder:(ROCheckOrderCell*)cell
{
    NSIndexPath *indexPath = [self.orderView indexPathForCell:cell];
    ROPayOrderInfo *order = [self.result objectAtIndex:[indexPath row]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(renrenRepairOrder:andPresentController:)]) {
        [self.delegate renrenRepairOrder:order andPresentController:self];
    }
    
//    [self close];
    
    //	NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    //	
    //    [self.orderView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.result.count) {
		// Configure the cell...
		ROCheckOrderCell *cell = (ROCheckOrderCell*)[tableView dequeueReusableCellWithIdentifier:@"RenrenCheckOrderCell"];
        if (cell == nil) {
            //            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCellIdentifier] autorelease];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ROCheckOrderCell" 
                                                         owner:self options:nil];
#ifdef __IPHONE_2_1
            cell = (ROCheckOrderCell *)[nib objectAtIndex:0];
#else
            cell = (ROCheckOrderCell *)[nib objectAtIndex:1];
#endif
        }
        
        ROPayOrderInfo *order = (ROPayOrderInfo *)[self.result objectAtIndex:indexPath.row];
        
        cell.orderNum.text = order.orderNum;
        if ([order.serverOrderStatus isEqualToString:@""]||order.serverOrderStatus == nil) {
            cell.orderStatus.text = order.localOrderStatus;
        } else {
            cell.orderStatus.text = order.serverOrderStatus;
        }
        
        NSDate *orderedTime = [NSDate dateWithTimeIntervalSince1970:[order.orderTime doubleValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        cell.orderTime.text = [formatter stringFromDate:orderedTime];
        [formatter release];
        
        cell.tradingVolume.text = [NSString stringWithFormat:@"%@人人豆",order.tradingVolume];
        
        cell.description.text = order.description;
        cell.serialNum.text = order.serialNum;
        
        if ([order.payStatusCode isEqualToString:kPaySuccessCode]) {
            cell.repair.hidden = YES;
        } else {
            cell.repair.hidden = NO;
        }
        
		return cell;
	}
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.result.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return the number of rows in the section.
    ROPayOrderInfo *orderRecord = (ROPayOrderInfo *)[self.result objectAtIndex:indexPath.row];
    if ([orderRecord.payStatusCode isEqualToString:kPaySuccessCode]) {
        return 194;
    }else{
        return 252;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)selfChangeOption:(ROBaseNavigationViewController *)newController
{
    [newController otherChangeOption:self];
    [self close];
}

- (void)dealloc
{
    self.orderView = nil;
    self.result = nil;
    [super dealloc];
}
@end
