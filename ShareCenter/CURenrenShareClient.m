//
//  CURenrenShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-14.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CURenrenShareClient.h"
#import "ROMacroDef.h"
#import "ROUtility.h"

@interface CURenrenShareClient ()
@property (nonatomic, retain) NSMutableDictionary *sendParams;
@end

@implementation CURenrenShareClient
@synthesize sendParams;

#pragma mark viewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        renren = [[Renren sharedRenren] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [renren release];
    [sendParams release];
    
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
    return bAuth = [renren isSessionValid];
}

- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
{
    UIViewController *controller = [self CUGetAuthViewController];
    
    [vc presentModalViewController:controller animated:YES];
    
    return;
}

- (void)CULogout
{
    [renren logout:nil];
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
    if (![self isCUAuth]) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:renren.appKey forKey:@"client_id"];
        [parameters setValue:kRRSuccessURL forKey:@"redirect_uri"];
        [parameters setValue:@"token" forKey:@"response_type"];
        [parameters setValue:@"touch" forKey:@"display"];
        
        NSURL *url = [ROUtility generateURL:kAuthBaseURL params:parameters];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        return request;
    }
    else {
        NSString *dialogURL = [kDialogBaseURL stringByAppendingString:@"feed"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"www.baidu.com", @"url",
                                       @"www.baidu.com", @"name",
                                       @"iKnow英语", @"action_name",
                                       @"http://www.imiknow.com/", @"action_link",
                                       @"www.baidu.com", @"description",
                                       @"www.baidu.com", @"caption",
                                       @"www.baidu.com", @"image",
                                       nil];
        
        //NSString *dialogURL = [kDialogBaseURL stringByAppendingString:action];
        [params setObject:renren.appId forKey:@"app_id"];
        [params setObject:@"touch" forKey:@"display"];
        
        if ([params objectForKey:@"redirect_uri"] == nil) {
            [params setObject:kRRSuccessURL forKey:@"redirect_uri"];
        }
        
        if ([renren isSessionValid]) {
            [params setValue:[renren.accessToken stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"access_token"];
        }
        
        [params setObject:kWidgetDialogUA forKey:@"ua"];
        
        NSURL *url = [ROUtility generateURL:dialogURL params:params];
        NSLog(@"start load URL: %@", url);
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        return request;
    }
}

#pragma mark - UIWebViewDelegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIActivityIndicatorView *activeIndicator = [self getActivityIndicatorView];
    [activeIndicator sizeToFit];
    [activeIndicator startAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [ROUtility parseURLParams:query];
    NSString *accessToken = [params objectForKey:@"access_token"];
    //    NSString *error_desc = [params objectForKey:@"error_description"];
    NSString *errorReason = [params objectForKey:@"error"];
    if(nil != errorReason) {
        //[self dialogDidCancel:nil];
        [self CUNotifyShareCancel:self];
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked)/*点击链接*/{
        BOOL userDidCancel = ((errorReason && [errorReason isEqualToString:@"login_denied"])||[errorReason isEqualToString:@"access_denied"]);
        if(userDidCancel){
            //[self dialogDidCancel:url];
            [self CUNotifyAuthFailed:self withError:nil];
        }else {
            NSString *q = [url absoluteString];
            if (![q hasPrefix:kAuthBaseURL]) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {//提交表单
        NSString *state = [params objectForKey:@"flag"];
        if ((state && [state isEqualToString:@"success"]) || accessToken) {
            [self dialogDidSucceed:url];
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[self.indicatorView stopAnimating];
    //    self.cancelButton.hidden = YES;
    UIActivityIndicatorView *view = [self getActivityIndicatorView];
    [view stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        //[self dismissWithError:error animated:YES];
        [self CUNotifyAuthFailed:self withError:error];
    }
}

#pragma mark common method

- (BOOL)isAuthDialog
{
    return [_serverURL isEqualToString:kAuthBaseURL];
}

- (void)dialogDidSucceed:(NSURL *)url {
	NSString *q = [url absoluteString];
	if([self isAuthDialog]) {
        
        NSString *token = [ROUtility getValueStringFromUrl:q forParam:@"access_token"];
        NSString *expTime = [ROUtility getValueStringFromUrl:q forParam:@"expires_in"];
        NSDate   *expirationDate = [ROUtility getDateFromString:expTime];
        NSDictionary *responseDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token,expirationDate,nil]
                                                                forKeys:[NSArray arrayWithObjects:@"token",@"expirationDate",nil]];
        
        renren.accessToken = token;
        renren.expirationDate = expirationDate;
        renren.secret=[ROUtility getSecretKeyByToken:token];
        renren.sessionKey=[ROUtility getSessionKeyByToken:token];
        //self.response = [ROResponse responseWithRootObject:responseDic];
        
        if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
            [self dialogDidCancel:nil];
        } 
        else 
        {
            [self CUNotifyAuthSucceed:self];
        }
        
        //TODO:save userinfo
        [renren saveUserSessionInfo];	
        [renren getLoggedInUserId];
    }
    else 
    {
        NSString *flag = [ROUtility getValueStringFromUrl:q forParam:@"flag"];	
        if ([flag isEqualToString:@"success"]) {
            NSString *query = [url fragment];
            if (!query) {
                query = [url query];
            }
            //NSDictionary *params = [ROUtility parseURLParams:query];
            //self.response = [ROResponse responseWithRootObject:params];
            return [self CUNotifyShareSucceed:self];
        }
    }
    
    //should not be here
    return [self CUNotifyShareCancel:self];
}
/*
- (void)dismissWithError:(NSError*)error animated:(BOOL)animated {
    
    self.response = [ROResponse responseWithError:[ROError errorWithNSError:error]];
    if ([self isAuthDialog]) {
        if ([self.delegate respondsToSelector:@selector(authDialog:withOperateType:)]){
            [self.delegate authDialog:self withOperateType:RODialogOperateFailure];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(widgetDialog:withOperateType:)]) {
            
            [self.delegate widgetDialog:self withOperateType:RODialogOperateFailure];
        }
    }
}*/

- (void)dialogDidCancel:(NSURL *)url {
    /*
    if ([self isAuthDialog]) {
        if ([self.delegate respondsToSelector:@selector(authDialog:withOperateType:)]){
            [self.delegate authDialog:self withOperateType:RODialogOperateCancel];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(widgetDialog:withOperateType:)]){
            [self.delegate widgetDialog:self withOperateType:RODialogOperateCancel];
        }
    }*/
    [self CUNotifyShareCancel:self];
}

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    /*
    NSString *shareUrl    = [iKnowAPI getShareArticlePath:article.Id];
    NSString *articleName = article.Name ? article.Name : @"";
    NSString *description = nil;
    NSString *caption     = [NSString stringWithFormat:article.UserName];      
    
    if ( [article.Description length] == 0 ) 
    {
        description = [article.Name length] == 0 ? [NSString stringWithString:article.Name] : @"";
        
    }
    else 
    {  
        description = [StringUtils trimString:article.Description toCharCount:100]; 
    }
    
    NSString *imagePath = article.SourceImageUrl ? [NSString stringWithString:article.SourceImageUrl] : @""; 
    NSString *articleShort = [StringUtils trimString:articleName toCharCount:25];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   shareUrl, @"url",
                                   articleShort, @"name",
                                   @"iKnow英语", @"action_name",
                                   @"http://www.imiknow.com/", @"action_link",
                                   description, @"description",
                                   caption, @"caption",
                                   imagePath, @"image",
                                   nil];*/
    
    
    [delegate presentModalViewController:self animated:YES];
}   

#pragma mark RenrenDelegate

- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response
{
    
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的错误对象。
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error
{
    
}

@end
