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

@interface CUViewController ()

@end

@implementation CUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CUSinaShareClient *sinaClient = [[[CUSinaShareClient alloc] init] autorelease];
    sinaClient.delegate = self;
    
    [CUShareCenter setupClient:sinaClient withType:SINACLIENT];
    [CUShareCenter setupContainer:self withType:SINACLIENT];
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

- (IBAction)shareSina:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    [[CUShareCenter sharedInstanceWithType:SINACLIENT] showWithText:@"test" andImage:image];
}

- (IBAction)logoutSina:(id)sender
{
    [[CUShareCenter sharedInstanceWithType:SINACLIENT] unBind];
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
