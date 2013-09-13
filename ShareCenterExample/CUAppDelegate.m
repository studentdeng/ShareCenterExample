//
//  CUAppDelegate.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUAppDelegate.h"
#import "WeiboSDK.h"
#import "CUViewController.h"
#import "CUConfig.h"
#import "CUShareCenter.h"

@implementation CUAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WeiboSDK enableDebugMode:YES];
    BOOL bRes = [WeiboSDK registerApp:kOAuthConsumerKey_sina];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[CUViewController alloc] initWithNibName:@"CUViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [ WeiboSDK handleOpenURL:url delegate:[CUShareCenter sharedInstanceWithType:SINACLIENT].shareClient ];
}


//- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
//{
//    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
//    {
//        NSLog(@"didReceiveWeiboRequest");
//        /*
//        ProvideMessageForWeiboViewController *controller = [[[ProvideMessageForWeiboViewController alloc] init] autorelease];
//        [self.viewController presentModalViewController:controller animated:YES];*/
//    }
//}

@end
