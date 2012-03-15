//
//  CUSinaShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUShareClient.h"
#import "WBEngine.h"

@interface CUSinaShareClient : CUShareClient
<CUShareClientData, WBEngineDelegate>
{
    WBEngine *engine;
    
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
- (void)CUShowWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

- (NSURLRequest *)CULoginURLRequest;
- (UIViewController *)CUGetAuthViewController;

@end
