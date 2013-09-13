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

#define TEST_IMAGEURL_NICE_GIRL     @"http://e.hiphotos.baidu.com/album/w%3D2048/sign=d7543108f636afc30e0c38658721eac4/e824b899a9014c08ba1d546d0b7b02087af4f4d0.jpg"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] addDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient] addDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] shareClient] addDelegate:self];

    
    BOOL bBind = [[CUShareCenter sharedInstanceWithType:SINACLIENT] isBind];
    sinaBindLabel.text = bBind ? @"sina bind" : @"sina unbind";
    
    bBind = [[CUShareCenter sharedInstanceWithType:RENRENCLIENT] isBind];
    renrenBindLabel.text = bBind ? @"renren bind" : @"renren unbind";
    
    bBind = [[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] isBind];
    tencentBindLabel.text = bBind ? @"tencent bind" : @"tencent unbind";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] removeDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient] removeDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] shareClient] removeDelegate:self];
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
    
    if (![[CUShareCenter sharedInstanceWithType:btn.tag] isBind]) {
        return [[CUShareCenter sharedInstanceWithType:btn.tag] Bind:self];
    }
    
    if (btn.tag == SINACLIENT) {
    
        [[CUShareCenter sharedInstanceWithType:SINACLIENT] sendWithText:@"test" 
                                                               andImage:[UIImage imageNamed:@"test.jpg"]];
        return;
    }
    
    [[CUShareCenter sharedInstanceWithType:btn.tag] sendWithText:@"tencent的sdk还是挺给力的，尽管啥都没有，不过总比人人的好使"
                                               andImageURLString:TEST_IMAGEURL_NICE_GIRL];
}

- (IBAction)showRENREN:(id)sender
{
    BOOL bBind = [[CUShareCenter sharedInstanceWithType:RENRENCLIENT] isBind];
    if (!bBind) {
        [[CUShareCenter sharedInstanceWithType:RENRENCLIENT] Bind:self];
    }
    else {
        
        CURenrenShareClient *renren = (CURenrenShareClient *)[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient];
        
        NSString *shareUrl    = @"http://www.imiknow.com/details.aspx?id=7466851";
        NSString *description = @"just do it";
        NSString *caption     = @"why is here"; 
        
        NSString *imagePath = TEST_IMAGEURL_NICE_GIRL;
        NSString *articleShort = @"same here";
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shareUrl, @"url",
                                       articleShort, @"name",
                                       @"iKnow英语", @"action_name",
                                       @"http://www.imiknow.com/", @"action_link",
                                       description, @"description",
                                       caption, @"caption",
                                       imagePath, @"image",
                                       nil];
        
        [renren sendWithDictionary:params];
    }
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

#pragma mark CUShareClientDelegate

- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error
{
    NSLog(@"CUShareFailed");
}

- (void)CUShareSucceed:(CUShareClient *)client
{
    NSLog(@"CUShareSucceed");
}

- (void)CUShareCancel:(CUShareClient *)client
{
    NSLog(@"CUShareCancel");
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
