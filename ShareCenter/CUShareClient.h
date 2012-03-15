//
//  CUShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int kActiveIndicatorTag;

typedef enum _CUShareClientType
{
    SINACLIENT = 0,
    QQZONECLIENT = 1,
    RENRENCLIENT = 2,
}
CUShareClientType;

@protocol CUShareClientData <UIWebViewDelegate>

- (BOOL)isCUAuth;
- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
- (void)CULogout;

- (void)CUShowWithText:(NSString *)text;
- (void)CUShowWithText:(NSString *)text andImage:(UIImage *)image;
- (void)CUShowWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

- (UIViewController *)CUGetAuthViewController;

@end

@class CUShareClient;
@protocol CUShareClientDelegate <NSObject>

- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUShareSucceed:(CUShareClient *)client;
- (void)CUSHareCancel:(CUShareClient *)client;

- (void)CUAuthSucceed:(CUShareClient *)client;
- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error;

@end

@interface CUShareClient : UIViewController <UIWebViewDelegate>
{
    UIWebView *webView;
	UINavigationBar *navBar;
	
	UIInterfaceOrientation                      orientation;
	UIToolbar									*pinCopyPromptBar;    
    
    id<CUShareClientDelegate> delegate;
}

- (UIActivityIndicatorView *)getActivityIndicatorView;

- (void)CUNotifyShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUNotifyShareSucceed:(CUShareClient *)client;
- (void)CUNotifyShareCancel:(CUShareClient *)client;
- (void)CUNotifyAuthSucceed:(CUShareClient *)client;
- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error;

- (NSURLRequest *)CULoginURLRequest;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) id<CUShareClientDelegate> delegate;

@end
