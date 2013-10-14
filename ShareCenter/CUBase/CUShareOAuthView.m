//
//  CUShareOAuthView.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CUShareOAuthView.h"
#import "CUConfig.h"

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

@interface  CUShareOAuthView()

@property (nonatomic, readwrite) UIInterfaceOrientation orientation;
@end

@implementation CUShareOAuthView

@synthesize webView;
@synthesize orientation;
@synthesize loginRequest;
@synthesize tintColor;

#pragma mark -  life

- (id)init
{
    if (self = [super init]) {
        CGRect rc = ApplicationFrame(self.orientation);
        self.webView = [[[UIWebView alloc] initWithFrame:rc] autorelease];
	     
        [self.view addSubview: self.webView];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    self.loginRequest = nil;
    self.tintColor = nil;
    
    [super dealloc];
}

#pragma mark -  UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rc = ApplicationFrame(self.orientation);
    
    self.view = [[[UIView alloc] initWithFrame: rc] autorelease];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
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
    
    self.title = @"登录";
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [buttonLeft setImage:[UIImage imageNamed:@"CUShareCenter.bundle/back"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft];
    self.navigationItem.leftBarButtonItem = itemLeft;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown 
    || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - common method

- (void)cancel:(id)sender {
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (UIActivityIndicatorView *)getActivityIndicatorView
{
    return (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
}

- (void)close:(id)sender
{
    [[self getActivityIndicatorView] stopAnimating];
    
    self.webView.delegate = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
