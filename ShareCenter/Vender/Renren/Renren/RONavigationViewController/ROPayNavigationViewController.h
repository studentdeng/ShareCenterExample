//
//  ROPayNavigationViewController.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-13.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

#import "ROBaseNavigationViewController.h"

@interface ROPayNavigationViewController : ROBaseNavigationViewController <UIWebViewDelegate>{
    UIWebView *_webView;
    NSString *_url;
    NSMutableDictionary *_params;
    id<RenrenPayDialogDelegate> _delegate;
    UIActivityIndicatorView *_indicatorView;
}

@property (nonatomic,retain)UIWebView *webView;
@property (nonatomic,retain)NSString *url;
@property (nonatomic,retain)NSMutableDictionary *params;
@property (nonatomic,assign)id<RenrenPayDialogDelegate> delegate;
@property (nonatomic,retain)UIActivityIndicatorView *indicatorView;

@end
