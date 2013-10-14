//
//  AppDelegate.m
//  Example
//
//  Created by curer on 10/13/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "CUViewController.h"
#import "CUConfig.h"
#import "CUShareCenter.h"
#import "CUSinaShareClient.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kOAuthConsumerKey_sina];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[CUViewController alloc] initWithNibName:@"CUViewController" bundle:nil];
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
