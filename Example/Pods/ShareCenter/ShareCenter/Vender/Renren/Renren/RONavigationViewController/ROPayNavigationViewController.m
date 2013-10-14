//
//  ROPayNavigationViewController.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-13.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

#import "ROPayNavigationViewController.h"

@implementation ROPayNavigationViewController
@synthesize webView = _webView;
@synthesize url = _url;
@synthesize params = _params;
@synthesize delegate = _delegate;
@synthesize indicatorView = _indicatorView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)] autorelease];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.webView];
        
        self.indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        self.indicatorView.hidesWhenStopped = YES;
        self.indicatorView.center = self.webView.center;
        [self.view addSubview:self.indicatorView];
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
    // Do any additional setup after loading the view from its nib.
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *q = [url absoluteString];
    
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [ROUtility parseURLParams:query];
    
    if ([q hasPrefix:kPaySuccessURL]) {
        ROPayOrderInfo *order = [[[ROPayOrderInfo alloc] init] autorelease];
        order.tradingVolume = [params objectForKey:@"amount"];
        order.orderNum = [params objectForKey:@"order_number"];
        
        order.orderTime = [NSString stringWithFormat:@"%0.0f",[[params objectForKey:@"orderedTime"] doubleValue]/1000.0];

        order.payStatusCode = [params objectForKey:@"payStatusCode"];
        order.serialNum = [params objectForKey:@"bid"];
        order.serverOrderStatus = [params objectForKey:@"serverStatus"];
        order.payment = [params objectForKey:@"payment"];
        order.payEncode = [params objectForKey:@"payResultEncode"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(renrenDialogPaySuccess:)]) {
            [self.delegate renrenDialogPaySuccess:order];
        }
        
        [self close];
        return NO;
    } else if ([q hasPrefix:kPayFailURL]){
        NSString *errorDesc = [params objectForKey:@"description"];
        NSString *errorCode = [params objectForKey:@"code"];
        
        if(nil != errorCode) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(renrenDialogPayError:)]) {
                ROPayError *error = [[[ROPayError alloc] init] autorelease];
                error.errorCode = errorCode;
                error.description = errorDesc;
                
                [self.delegate renrenDialogPayError:error];
            }
            [self close];
            return NO;
        }
    } else if ([q hasPrefix:kDirectPayURL]){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else if ([q hasPrefix:kRepairSuccessURL]) {
        ROPayOrderInfo *order = [[[ROPayOrderInfo alloc] init] autorelease];
        order.tradingVolume = [params objectForKey:@"amount"];
        order.orderNum = [params objectForKey:@"order_number"];
        
        order.orderTime = [NSString stringWithFormat:@"%0.0f",[[params objectForKey:@"orderedTime"] doubleValue]/1000.0];
        
        order.payStatusCode = kPaySuccessCode;
        order.serialNum = [params objectForKey:@"bid"];
        order.serverOrderStatus = [params objectForKey:@"serverStatus"];
        order.payment = [params objectForKey:@"payment"];
        order.payEncode = [params objectForKey:@"payResultEncode"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(renrenDialogRepairSuccess:)]) {
            [self.delegate renrenDialogRepairSuccess:order];
        }
        
        [self close];
        return NO;
    } else if ([q hasPrefix:kRepairFailURL]){
        NSString *errorDesc = [params objectForKey:@"description"];
        NSString *errorCode = [params objectForKey:@"code"];
        
        if(nil != errorCode) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(renrenDialogRepairError:)]) {
                ROPayError *error = [[[ROPayError alloc] init] autorelease];
                error.errorCode = errorCode;
                error.description = errorDesc;
                
                [self.delegate renrenDialogRepairError:error];
            }
            
            [self close];
            return NO;
        }
    }
    
    //点击链接
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return  YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(renrenDialogPayError:)]) {
        ROPayError *payError = [[[ROPayError alloc] init] autorelease];
        payError.errorCode = [NSString stringWithFormat:@"%d",error.code];
        payError.description = @"页面加载失败，请检查网络连接后重试";
        
        [self.delegate renrenDialogPayError:payError];
    }
}

- (void)show
{
    [super show];
    
    NSURL *url = [ROUtility generateURL:self.url params:self.params];
	NSLog(@"start load URL: %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    [self.indicatorView startAnimating];
    
}

- (void)otherChangeOption:(ROBaseNavigationViewController *)newController
{
    NSURL *url = [ROUtility generateURL:self.url params:self.params];
	NSLog(@"start load URL: %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    [self.indicatorView startAnimating];
}

- (void)dealloc{
    self.webView = nil;
    self.url = nil;
    self.params = nil;
    self.indicatorView = nil;
    [super dealloc];
}

@end
