//
//  WBWBAuthorizeWebView.h
//  SinaWeiBoSDK
//  Based on OAuth 2.0
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright 2011 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBWBAuthorizeWebView;

@protocol WBWBAuthorizeWebViewDelegate <NSObject>

- (void)authorizeWebView:(WBWBAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code;

@end

@interface WBWBAuthorizeWebView : UIView <UIWebViewDelegate> 
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
    id<WBWBAuthorizeWebViewDelegate> delegate;
}

@property (nonatomic, assign) id<WBWBAuthorizeWebViewDelegate> delegate;

- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

@end