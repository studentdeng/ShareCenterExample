//
//  CUShareViewClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CUShareViewClient.h"

int kActiveIndicatorTag = 10;

CGRect ApplicationFrame(UIInterfaceOrientation interfaceOrientation) {
	
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
    
	bounds.origin.x = 0;
	return bounds;
}

@interface  CUShareViewClient()

@property (nonatomic, readwrite) UIInterfaceOrientation orientation;

@end

@implementation CUShareViewClient

@synthesize webView;
@synthesize orientation;
@synthesize loginRequest;

#pragma mark life

- (id)init
{
    if (self = [super init]) {
        CGRect rc = ApplicationFrame(self.orientation);
        rc.size.height -= 24;
        rc.origin.y += 24;
        
        self.webView = [[[UIWebView alloc] initWithFrame:rc] autorelease];
        
        [self.view addSubview: self.webView];
    }
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    self.loginRequest = nil;
    
    [super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rc = ApplicationFrame(self.orientation);
    
    self.view = [[[UIView alloc] initWithFrame: rc] autorelease];
	navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)] autorelease];
	
	navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	CGRect frame = ApplicationFrame(self.orientation);
	frame.origin.y = 44;
	frame.size.height -= 44;
    
	[self.view addSubview: navBar];
    
    UIActivityIndicatorView *activeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activeIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin 
                                            | UIViewAutoresizingFlexibleBottomMargin
                                            | UIViewAutoresizingFlexibleLeftMargin 
                                            | UIViewAutoresizingFlexibleRightMargin;
    activeIndicator.tag = kActiveIndicatorTag;
    activeIndicator.hidden = YES;
    activeIndicator.frame = CGRectMake(CGRectGetMidX(self.webView.bounds) - 20.0f,
                                       CGRectGetMidY(self.webView.bounds) - 20.0f,
                                       40.0f, 40.0f);
    [self.webView addSubview:activeIndicator];
    [activeIndicator release];
	
	//UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Sina Weibo Info", nil)] autorelease];
    UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle:@"登陆"] autorelease];
	navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                               target:self 
                                                                               action:@selector(cancel:)] 
                                 autorelease];
	
	[navBar pushNavigationItem: navItem animated: NO];
}

#pragma mark common method

- (void)cancel:(id)sender {
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

/*
- (UIToolbar *) pinCopyPromptBar {
	if (pinCopyPromptBar == nil){
		CGRect					bounds = self.view.bounds;
		
		pinCopyPromptBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, bounds.size.width, 44)] autorelease];
		pinCopyPromptBar.barStyle = UIBarStyleBlackTranslucent;
		pinCopyPromptBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		
		pinCopyPromptBar.items = [NSArray arrayWithObjects: 
								   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease],
								   [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Select and Copy the PIN", @"Select and Copy the PIN") style: UIBarButtonItemStylePlain target: nil action: nil] autorelease], 
								   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease], 
								   nil];
	}
	
	return pinCopyPromptBar;
}*/

- (UIActivityIndicatorView *)getActivityIndicatorView
{
    return (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
}

- (void)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
