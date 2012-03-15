//
//  CURenrenShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-14.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareClient.h"
#import "Renren.h"

@interface CURenrenShareClient : CUShareClient
<CUShareClientData, RenrenDelegate>
{
    Renren *renren;
    /**************************************
     * Inherited from CUShareClient:
     * 
     * UIWebView *webView;
     * UINavigationBar	*navBar;
     * UIInterfaceOrientation orientation;
     * UIToolbar *pinCopyPromptBar;    
     * id<CUShareClientDelegate> delegate;
     ***************************************/
}

//CUShareClientData
- (BOOL)isCUAuth;
- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
- (void)CULogout;

- (void)CUShowWithText:(NSString *)text;
- (void)CUShowWithText:(NSString *)text andImage:(UIImage *)image;

- (NSURLRequest *)CULoginURLRequest;
- (UIViewController *)CUGetAuthViewController;

@end
