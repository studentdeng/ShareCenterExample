//
//  CUSinaShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUShareClient.h"
#import "OAuthEngine.h"

@interface CUSinaShareClient : CUShareClient
<CUShareClientData>
{
    OAuthEngine *engine;
    
    //CUShareClient
    /*
     UIWebView									*webView;
     UINavigationBar								*_navBar;
     UIView										*_blockerView;
     
     UIInterfaceOrientation                      _orientation;
     BOOL										_loading, _firstLoad;
     UIToolbar									*_pinCopyPromptBar;    
     
     id<CUShareClientDelegate> delegate;
     */
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
