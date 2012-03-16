//
//  CUTencentShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-16.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUTencentShareClient.h"
#import "QWeiboSyncApi.h"

//project key
//#define kOAuthConsumerKey				@""
//#define kOAuthConsumerSecret			@""


//this is just for test


#define VERIFY_URL @"http://open.t.qq.com/cgi-bin/authorize?oauth_token="

@interface CUTencentShareClient ()

@end

@implementation CUTencentShareClient

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    self = [super init];
    if (self) {
        if (engine == nil){
            engine = [[CUTencentEngine alloc] initWithAppKey:theAppKey 
                                                   appSecret:theAppSecret];
            engine.delegate = self;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [engine release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark CUShareClientData

- (BOOL)isCUAuth
{
    return [engine isLoggedIn] && ![engine isAuthorizeExpired];
}

- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
{
    UIViewController *controller = [self CUGetAuthViewController];
    
    [vc presentModalViewController:controller animated:YES];
    
    return;
}

- (void)CULogout
{
    [engine logOut];
    return;
}

- (void)CUShowWithText:(NSString *)text
{
    return [self CUShowWithText:text andImage:nil];
}

- (void)CUShowWithText:(NSString *)text andImage:(UIImage *)image
{
    if ([text length] == 0) {
        return;
    }
    
    return [self post:text andImage:image];
}

- (void)CUShowWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    return [self post:text andImageURLString:imageURLString];
}

- (UIViewController *)CUGetAuthViewController
{
    return self;
}

#pragma mark CUShareClient

- (NSURLRequest *)CULoginURLRequest
{
    QWeiboSyncApi *api = [[[QWeiboSyncApi alloc] init] autorelease];
    NSString *retString = [api getRequestTokenWithConsumerKey:engine.appKey 
                                               consumerSecret:engine.appSecret];
    NSLog(@"Get requestToken:%@", retString);
    
    [engine parseTokenKeyWithResponse:retString];

    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", VERIFY_URL, engine.tokenKey];

    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    
    return request;
}

#pragma mark common method

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    NSAssert(0,@"not implement");
    return;
}  

- (void)post:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    if ([text length] == 0 && [imageURLString length] == 0) {
        
        [self CUNotifyShareFailed:self withError:nil];
        
        return;
    }
    
    return [engine sendWeiBoWithText:text imageURL:imageURLString];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
	NSString *query = [[request URL] query];
	
    if ([engine authorizeResponse:query]) {
        return NO;
    }
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    UIActivityIndicatorView *indicatorView = [self getActivityIndicatorView];
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    UIActivityIndicatorView *indicatorView = [self getActivityIndicatorView];
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    UIActivityIndicatorView *indicatorView = [self getActivityIndicatorView];
    [indicatorView stopAnimating];
}

#pragma mark CUTencentEngineDelegate

// Log in successfully.
- (void)engineDidLogIn:(CUTencentEngine *)engine
{
    [self CUNotifyAuthSucceed:self];
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(CUTencentEngine *)engine didFailToLogInWithError:(NSError *)error
{
    [self CUNotifyAuthFailed:self withError:error];
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(CUTencentEngine *)engine
{
    [self CUNotifyShareFailed:self withError:nil];
}

- (void)engine:(CUTencentEngine *)engine requestDidFailWithError:(NSError *)error
{
    [self CUNotifyShareFailed:self withError:error];
}

- (void)engine:(CUTencentEngine *)engine requestDidSucceedWithResult:(id)result
{
    [self CUNotifyShareSucceed:self];
}

@end
