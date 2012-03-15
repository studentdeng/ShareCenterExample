//
//  CUShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CUShareClient.h"

//#define kActiveIndicatorTag 10

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

#pragma mark life

- (id)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    
    [super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rc = ApplicationFrame(self.orientation);
    
    self.view = [[[UIView alloc] initWithFrame: rc] autorelease];
	_navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)] autorelease];
	
	_navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	CGRect frame = ApplicationFrame(self.orientation);
	frame.origin.y = 44;
	frame.size.height -= 44;
    
	self.webView = [[UIWebView alloc] initWithFrame:frame];
	//self.webView.alpha = 0.0;
	self.webView.delegate = self;
	//_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if ([self.webView respondsToSelector: @selector(setDetectsPhoneNumbers:)]) [(id) self.webView setDetectsPhoneNumbers: NO];
	if ([self.webView respondsToSelector: @selector(setDataDetectorTypes:)]) [(id) self.webView setDataDetectorTypes: 0];
	
    NSURLRequest *request = [self CULoginURLRequest];
    
	[self.webView loadRequest: request];
	
	[self.view addSubview: self.webView];
	[self.view addSubview: _navBar];
    
    UIActivityIndicatorView *activeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activeIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    activeIndicator.tag = kActiveIndicatorTag;
    activeIndicator.hidden = YES;
    activeIndicator.frame = CGRectMake(CGRectGetMidX(self.webView.bounds) - 20.0f,
                                       CGRectGetMidY(self.webView.bounds) - 20.0f,
                                       40.0f, 40.0f);
    [self.webView addSubview:activeIndicator];
    [activeIndicator release];

	
	UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Sina Weibo Info", nil)] autorelease];
	navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                               target:self 
                                                                               action:@selector(cancel:)] 
                                 autorelease];
	
	[_navBar pushNavigationItem: navItem animated: NO];
}

- (NSURLRequest *)CULoginURLRequest
{
    //subclass implement;
    return nil;
}

#pragma mark common method

- (void)denied {
    [self CUNotifyAuthFailed:self withError:nil];
}

- (void)cancel:(id)sender {
    [self CUNotifyShareCancel:self];
}

- (UIToolbar *) pinCopyPromptBar {
	if (_pinCopyPromptBar == nil){
		CGRect					bounds = self.view.bounds;
		
		_pinCopyPromptBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, bounds.size.width, 44)] autorelease];
		_pinCopyPromptBar.barStyle = UIBarStyleBlackTranslucent;
		_pinCopyPromptBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		
		_pinCopyPromptBar.items = [NSArray arrayWithObjects: 
								   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease],
								   [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Select and Copy the PIN", @"Select and Copy the PIN") style: UIBarButtonItemStylePlain target: nil action: nil] autorelease], 
								   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease], 
								   nil];
	}
	
	return _pinCopyPromptBar;
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
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:1.0f];
}

- (void)CUNotifyShareSucceed:(CUShareClient *)client
{
    if ([delegate respondsToSelector:@selector(CUShareSucceed:)]) {
        [delegate CUShareSucceed:client];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:1.0f];
}

- (void)CUNotifyShareCancel:(CUShareClient *)client
{
    if ([delegate respondsToSelector:@selector(CUSHareCancel:)]) {
        [delegate CUSHareCancel:client];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:1.0f];
}

- (void)CUNotifyAuthSucceed:(CUShareClient *)client
{
    if ([delegate respondsToSelector:@selector(CUAuthSucceed:)]) {
        [delegate CUAuthSucceed:client];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:1.0f];
}

- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(CUShareFailed:withError:)]) {
        [delegate CUShareFailed:client withError:error];
    }
    
    [self performSelector:@selector(close:) withObject:nil afterDelay:1.0f];
}


@end
