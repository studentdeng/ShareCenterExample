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
    UIWebView									*webView;
	UINavigationBar								*_navBar;
	//UIView										*_blockerView;
	
	UIInterfaceOrientation                      _orientation;
	BOOL										_loading, _firstLoad;
	UIToolbar									*_pinCopyPromptBar;    
    
    id<CUShareClientDelegate> delegate;
}

- (NSURLRequest *)CULoginURLRequest;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) id<CUShareClientDelegate> delegate;

@end
