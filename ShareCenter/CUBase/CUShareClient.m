//
//  CUShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CUShareClient.h"

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

@interface  CUShareClient()

@property (nonatomic, readonly) UIToolbar *pinCopyPromptBar;
@property (nonatomic, readwrite) UIInterfaceOrientation orientation;

@end

@implementation CUShareClient

@synthesize webView;
@synthesize delegate;
@synthesize orientation;
@synthesize appKey;
@synthesize appKeySecret;

#pragma mark life

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init]) {
        self.appKey = theAppKey;
        self.appKeySecret = theAppSecret;
    }
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    self.appKey = nil;
    self.appKeySecret = nil;
    
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
    
	self.webView = [[UIWebView alloc] initWithFrame:frame];
	self.webView.delegate = self;
	
    NSURLRequest *request = [self CULoginURLRequest];
    
	[self.webView loadRequest:request];
	
	[self.view addSubview: self.webView];
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

- (NSURLRequest *)CULoginURLRequest
{
    NSAssert(0,@"subclass implement");
    return nil;
}

#pragma mark common method

- (void)cancel:(id)sender {
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

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
}

- (UIActivityIndicatorView *)getActivityIndicatorView
{
    return (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
}

- (void)close:(id)sender
{
    //[self.webView loadHTMLString:nil baseURL:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)CUNotifyShareFailed:(CUShareClient *)client withError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(CUShareFailed:withError:)]) {
        [delegate CUShareFailed:client withError:error];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyShareSucceed:(CUShareClient *)client
{
    if ([delegate respondsToSelector:@selector(CUShareSucceed:)]) {
        [delegate CUShareSucceed:client];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyShareCancel:(CUShareClient *)client
{
    if ([delegate respondsToSelector:@selector(CUSHareCancel:)]) {
        [delegate CUSHareCancel:client];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:.20f];
}

- (void)CUNotifyAuthSucceed:(CUShareClient *)client
{
    if ([delegate respondsToSelector:@selector(CUAuthSucceed:)]) {
        [delegate CUAuthSucceed:client];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(CUShareFailed:withError:)]) {
        [delegate CUShareFailed:client withError:error];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

@end
