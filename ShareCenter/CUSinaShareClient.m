//
//  CUSinaShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUSinaShareClient.h"
#import "ASIFormDataRequest.h"

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"

#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"

//< For Sina
#define kSinaKeyCodeLead @"获取到的授权码"
#define kSinaPostImagePath @"http://api.t.sina.com.cn/statuses/upload.json"
#define kSinaPostPath @"http://api.t.sina.com.cn/statuses/update.json"

//project key
#define kOAuthConsumerKey				@"2832649083"
#define kOAuthConsumerSecret			@"191a6c08a5d3f783a5bd0de5accd180b"

//view

@interface  CUShareClient()

- (NSString *)locateAuthPinInWebView:(UIWebView *)webView;
- (void)gotPin:(NSString *)pin;
- (void)post:(NSString *)text andImage:(UIImage *)image;

@end

@implementation CUSinaShareClient

#pragma mark life

- (id)init
{
    if (self = [super init]) {
        if (engine == nil){
            engine = [[WBEngine alloc] initWithAppKey:kOAuthConsumerKey appSecret:kOAuthConsumerSecret];
            [engine setRootViewController:self];
            [engine setDelegate:self];
            [engine setRedirectURI:@"http://"];
            [engine setIsUserExclusive:NO];            
            [engine setRedirectURI:@"http://"];
            
            WBAuthorize *auth = [[WBAuthorize alloc] initWithAppKey:kOAuthConsumerKey 
                                                          appSecret:kOAuthConsumerSecret];
            [auth setRootViewController:self];
            [auth setDelegate:engine];
            [auth setRedirectURI:engine.redirectURI];
            
            engine.authorize = auth;
            
            [auth release];

        }
    }
    
    return self;
}

- (void)dealloc
{
    [engine release];
    
    [super dealloc];
}

#pragma mark viewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

- (UIViewController *)CUGetAuthViewController
{
    return self;
}

#pragma mark CUShareClient


- (NSURLRequest *)CULoginURLRequest
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:engine.appKey, @"client_id",
                            @"code", @"response_type",
                            engine.redirectURI, @"redirect_uri", 
                            @"mobile", @"display", nil];
    NSString *urlString = [WBRequest serializeURL:kWBAuthorizeURL
                                           params:params
                                       httpMethod:@"GET"];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];

    return request;
}

#pragma mark - UIWebViewDelegate Methods

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

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        [engine.authorize authorizeWebView:nil didReceiveAuthorizeCode:code];
    }
    
    return YES;
}

#pragma mark WBEngineDelegate

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{

}

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)engine
{
    [self CUNotifyAuthSucceed:self];
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    [self CUNotifyAuthFailed:self withError:error];
}

// Log out successfully.
- (void)engineDidLogOut:(WBEngine *)engine
{
    
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine
{
    [self CUNotifyAuthFailed:self withError:nil];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    [self CUNotifyAuthFailed:self withError:nil];
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
}

#pragma mark common method

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    [engine sendWeiBoWithText:text image:image];
}

@end
