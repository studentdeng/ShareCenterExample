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
#import "CUTimelineViewController.h"

#define TEST_IMAGEURL_NICE_GIRL     @"http://www.imiknow.com/iks/res/MGMxMDA5NzUyNTQ4ZWU4ZmUyMWZiNGRlM2Y1NDM1ZGE/YXBwbGljYXRpb24vb2N0ZXQtc3RyZWFt/bf980271-5f1e-458c-a513-4a49457e0268.jpg"

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
    
    CURenrenShareClient *renrenClient = [[[CURenrenShareClient alloc] initWithAppKey:kAPP_ID_renren
                                                                           appSecret:kAPI_Key_renren] autorelease];
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
    
    if (btn.tag == SINACLIENT) {
    
        [[CUShareCenter sharedInstanceWithType:SINACLIENT] showWithText:@"hi" 
                                                               andImage:[UIImage imageNamed:@"test.jpg"]];
        return;
    }
    
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

- (IBAction)showTimeline:(id)sender
{
    NSString *token = [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] requestToken];
    //NSString *token = @"123123123";
    if ([token length] == 0) {
        
        [[CUShareCenter sharedInstanceWithType:SINACLIENT] Bind];
        
        return;
    }
    
    CUTimelineViewController *vc = [[CUTimelineViewController alloc] initWithToken:token];
    
    [self presentModalViewController:vc animated:YES];
    
    [vc release];
}

#pragma mark CUShareClientDelegate

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
