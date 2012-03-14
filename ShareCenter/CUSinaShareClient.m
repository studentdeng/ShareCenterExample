//
//  CUSinaShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUSinaShareClient.h"
#import "OAMutableURLRequest.h"
#import "ASIFormDataRequest.h"
#import "StringUtil.h"

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
            engine = [[OAuthEngine alloc] initOAuthWithDelegate: self];
            engine.consumerKey = kOAuthConsumerKey;
            engine.consumerSecret = kOAuthConsumerSecret;
            
            if (!engine.OAuthSetup) 
            {
                [engine requestRequestToken];
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [engine release];
    
    [super dealloc];
}

#pragma mark CUShareClientData

- (BOOL)isCUAuth
{
    return [engine isAuthorized];
}

- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
{
    UIViewController *controller = [self CUGetAuthViewController];
    
    [vc presentModalViewController:controller animated:YES];
    
    return;
}

- (void)CULogout
{
    [self removeCachedOAuthDataForUsername:@""];
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
    return engine.authorizeURLRequest;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!engine.OAuthSetup) 
    {
        [engine requestRequestToken];
    }
}

#pragma mark webview

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIActivityIndicatorView *activeIndicator = (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
    [activeIndicator sizeToFit];
    [activeIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    NSString *authPin = [self locateAuthPinInWebView:webView];
	
	if (authPin.length) {
		[self gotPin: authPin];
		return;
	}  
    
    UIActivityIndicatorView *activeIndicator = (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
    activeIndicator.hidden = YES;
    [activeIndicator stopAnimating];    
    
    [UIView beginAnimations: nil context: nil];
	//_blockerView.alpha = 0.0;
	[UIView commitAnimations];
	
	if ([webView isLoading]) {
		webView.alpha = 0.0;
	} else {
		webView.alpha = 1.0;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {    
    
    if ([delegate respondsToSelector:@selector(CUAuthFailed:withError:)])
    {
        [delegate CUAuthFailed:self withError:error];
    }
    
    UIActivityIndicatorView *activeIndicator = (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
    activeIndicator.hidden = YES;
    [activeIndicator stopAnimating];    
    
    //[self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0f];
    //[self cancel:nil];
    [self performSelector:@selector(cancel:) withObject:nil afterDelay:1.0f];
}

#pragma mark Actions

- (void)gotPin:(NSString *)pin {
	engine.pin = pin;
	[engine requestAccessToken];
	
	//if ([delegate respondsToSelector: @selector(OAuthController:authenticatedWithUsername:)]) 
    //    [delegate OAuthController: self authenticatedWithUsername: engine.username];
    
    if ([delegate respondsToSelector:@selector(CUAuthSucceed:)]) {
        [delegate CUAuthSucceed:self];
    }
    
    [self.webView loadHTMLString:nil baseURL:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)denied {
	if ([delegate respondsToSelector:@selector(CUAuthFailed:withError:)]) {
        [delegate CUAuthFailed:self withError:nil];
    }
    
    [self.webView loadHTMLString:nil baseURL:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancel:(id)sender {
    if ([delegate respondsToSelector:@selector(CUSHareCancel:)]) {
        [delegate CUSHareCancel:self];
    }
    
    [self.webView loadHTMLString:nil baseURL:nil];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark OAuthEngineDelegate

- (void)storeCachedOAuthData:(NSString *)data forUsername:(NSString *)username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *)cachedOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"authData"];
}

- (void)removeCachedOAuthDataForUsername:(NSString *)username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults removeObjectForKey: @"authData"];
	[defaults synchronize];
}

#pragma mark common method

/*********************************************************************************************************
 I am fully aware that this code is chock full 'o flunk. That said:
 
 - first we check, using standard DOM-diving, for the pin, looking at both the old and new tags for it.
 - if not found, we try a regex for it. This did not work for me (though it did work in test web pages).
 - if STILL not found, we iterate the entire HTML and look for an all-numeric 'word', 7 characters in length
 
 Ugly. I apologize for its inelegance. Bleah.
 
 *********************************************************************************************************/

- (NSString *)locateAuthPinInWebView:(UIWebView *)webView {
    
    NSString *pin;
	
	NSString *html = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerText"];
	NSLog(@"html:%@", [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"]);
	
	if (html.length == 0) 
        return nil;
	
	const char			*rawHTML = (const char *) [html UTF8String];
	int					length = strlen(rawHTML), chunkLength = 0;
	
	for (int i = 0; i < length; i++) {
		if (rawHTML[i] < '0' || rawHTML[i] > '9') {
			if (chunkLength == 6) {
				char				*buffer = (char *) malloc(chunkLength + 1);
				
				memmove(buffer, &rawHTML[i - chunkLength], chunkLength);
				buffer[chunkLength] = 0;
				
				pin = [NSString stringWithUTF8String: buffer];
				free(buffer);
				return pin;
			}
			chunkLength = 0;
		} else
			chunkLength++;
	}
	
	return nil;
}

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    NSString *path = (image ? kSinaPostImagePath : kSinaPostPath);
    
    NSString *postString = [NSString stringWithFormat:@"status=%@", [text encodeAsURIComponent]];
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)path, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
    NSURL *finalURL = [NSURL URLWithString:URL];
    OAMutableURLRequest* req = [[[OAMutableURLRequest alloc] initWithURL:finalURL
                                                                consumer:engine.consumer 
                                                                   token:engine.accessToken 
                                                                   realm:nil
                                                       signatureProvider:nil] autorelease];
    [req setHTTPMethod:@"POST"];
    [req setHTTPShouldHandleCookies:NO];
    
    NSString *textBody = [NSString stringWithString:postString];
    textBody = [textBody stringByAppendingString:[NSString stringWithFormat:@"%@source=%@", 
                                                  (postString) ? @"&" : @"?" , 
                                                  engine.consumerKey]];
    
    [req setHTTPBody:[textBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *err = nil;
    
    [(OAMutableURLRequest *)req prepare];
    
    ASIFormDataRequest *asiReq = [ASIFormDataRequest requestWithURL:[req URL]];
    [asiReq setRequestHeaders:[NSMutableDictionary dictionaryWithCapacity:1]];
    [asiReq.requestHeaders setDictionary:[req allHTTPHeaderFields]];
    [asiReq setPostValue:text forKey:@"status"];
    [asiReq setPostValue:engine.consumerKey forKey:@"source"];
    if (image)
    {
        NSData *jpegImageData = UIImageJPEGRepresentation(image, 1.0f);
        [asiReq addData:jpegImageData withFileName:@"image.jpeg" andContentType:@"image/jpeg" forKey:@"pic"];
    }
    
    [asiReq startSynchronous];
    
    err = asiReq.error;
    
    if (err)
    {
        //< Error Handle
        NSLog(@"Error %@", err);
        if ([delegate respondsToSelector:@selector(CUShareFailed:withError:)]) {
            [delegate CUShareFailed:self withError:nil];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(CUShareSucceed:)])
        {
            [delegate CUShareSucceed:self];
            //[self.delegate shareFailedWithError:err];
        }
    }

}

@end
