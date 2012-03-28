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

#import "CUShareOAuthView.h"

@interface CUSinaShareClient : CUShareClient
<CUShareClientData, WBEngineDelegate>
{
    WBEngine *engine;
    
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
- (void)CULogout;

- (void)CUShowWithText:(NSString *)text;
- (void)CUShowWithText:(NSString *)text andImage:(UIImage *)image;
- (void)CUShowWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

- (NSString *)requestToken;

- (NSURLRequest *)CULoginURLRequest;

@end
