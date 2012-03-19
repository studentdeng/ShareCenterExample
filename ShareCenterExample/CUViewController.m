//
//  CUViewController.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUViewController.h"
#import "CUShareCenter.h"
#import "CUSinaShareClient.h"
#import "CURenrenShareClient.h"
#import "CUTencentShareClient.h"

#define TEST_IMAGEURL_NICE_GIRL     @"http://www.imiknow.com/iks/res/MGMxMDA5NzUyNTQ4ZWU4ZmUyMWZiNGRlM2Y1NDM1ZGE/YXBwbGljYXRpb24vb2N0ZXQtc3RyZWFt/bf980271-5f1e-458c-a513-4a49457e0268.jpg"


#define kOAuthConsumerKey_sina				@"1128481868"
#define kOAuthConsumerSecret_sina			@"024e9c1c0aca2d28c03f182e5924de67"

#define kOAuthConsumerKey_tencent			@"801111961"
#define kOAuthConsumerSecret_tencent		@"782bbf09d7b33223cf60b83bcdfb728f"

@interface CUViewController ()

@end

@implementation CUViewController

@synthesize renrenBindLabel;
@synthesize sinaBindLabel;
@synthesize tencentBindLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CUSinaShareClient *sinaClient = [[[CUSinaShareClient alloc] initWithAppKey:kOAuthConsumerKey_sina 
                                                                     appSecret:kOAuthConsumerSecret_sina] autorelease];
    sinaClient.delegate = self;
    [CUShareCenter setupClient:sinaClient withType:SINACLIENT];
    [CUShareCenter setupContainer:self withType:SINACLIENT];
    
    CURenrenShareClient *renrenClient = [[[CURenrenShareClient alloc] initWithAppKey:nil
                                                                           appSecret:nil] autorelease];
    renrenClient.delegate = self;
    [CUShareCenter setupClient:renrenClient withType:RENRENCLIENT];
    [CUShareCenter setupContainer:self withType:RENRENCLIENT];
    
    CUTencentShareClient *tencentClient = [[[CUTencentShareClient alloc] initWithAppKey:kOAuthConsumerKey_tencent
                                                                              appSecret:kOAuthConsumerSecret_tencent] autorelease];
    tencentClient.delegate = self;
    [CUShareCenter setupClient:tencentClient withType:TTWEIBOCLIENT];
    [CUShareCenter setupContainer:self withType:TTWEIBOCLIENT];
    
    BOOL bBind = [[CUShareCenter sharedInstanceWithType:SINACLIENT] isBind];
    sinaBindLabel.text = bBind ? @"sina bind" : @"sina unbind";
    
    bBind = [[CUShareCenter sharedInstanceWithType:RENRENCLIENT] isBind];
    renrenBindLabel.text = bBind ? @"renren bind" : @"renren unbind";
    
    bBind = [[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] isBind];
    tencentBindLabel.text = bBind ? @"tencent bind" : @"tencent unbind";
}    

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)share:(id)sender
{
    UIButton *btn = sender;
    
    [[CUShareCenter sharedInstanceWithType:btn.tag] showWithText:@"tencent的sdk还是挺给力的，尽管啥都没有，不过总比人人的好使"
                                               andImageURLString:TEST_IMAGEURL_NICE_GIRL];
}

- (IBAction)logout:(id)sender
{
    UIButton *btn = sender;
    [[CUShareCenter sharedInstanceWithType:btn.tag] unBind];
}

- (IBAction)logoutRenren:(id)sender
{
    [[CUShareCenter sharedInstanceWithType:RENRENCLIENT] unBind];
}

- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error
{
    NSLog(@"CUShareFailed");
}

- (void)CUShareSucceed:(CUShareClient *)client
{
    NSLog(@"CUShareSucceed");
}

- (void)CUSHareCancel:(CUShareClient *)client
{
    NSLog(@"CUSHareCancel");
}

- (void)CUAuthSucceed:(CUShareClient *)client
{
    NSLog(@"CUAuthSucceed");
}

- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
    NSLog(@"CUAuthFailed");
}

@end
