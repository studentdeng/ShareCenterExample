//
//  ROPayDialogViewController.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-8-30.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ROBaseDialogViewController.h"
#import "ROPayError.h"

@protocol RenrenPayDialogDelegate <NSObject>

@optional
- (void)renrenDialogPaySuccess:(id)result;
- (void)renrenDialogPayError:(ROPayError*)error;
- (void)renrenDialogRepairSuccess:(id)result;
- (void)renrenDialogRepairError:(ROPayError*)error;
@end

@interface ROPayDialogViewController : ROBaseDialogViewController <UIWebViewDelegate> {
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
