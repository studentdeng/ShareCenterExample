//
//  CUShareViewClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int kActiveIndicatorTag;

@interface CUShareViewClient : UIViewController <UIWebViewDelegate>
{
    UIWebView *webView;
	UINavigationBar *navBar;
	
	UIInterfaceOrientation                      orientation;
	UIToolbar									*pinCopyPromptBar;    
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURLRequest *loginRequest;

- (UIActivityIndicatorView *)getActivityIndicatorView;

@end
