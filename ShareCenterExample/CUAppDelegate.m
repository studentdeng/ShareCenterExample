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
#import "CUSinaShareClient.h"

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
    [WeiboSDK registerApp:kOAuthConsumerKey_sina];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[CUViewController alloc] initWithNibName:@"CUViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    CUSinaShareClient *sinaClient =
        (CUSinaShareClient *)[CUShareCenter sharedInstanceWithType:SINACLIENT].shareClient;
    
    return [ WeiboSDK handleOpenURL:url delegate:sinaClient ];
}

@end
