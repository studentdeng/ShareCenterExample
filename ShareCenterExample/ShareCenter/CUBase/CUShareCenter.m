//
//  CUShareCenter.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareCenter.h"

@implementation CUShareCenter

static CUShareCenter *s_instance1 = nil;
static CUShareCenter *s_instance2 = nil;
static CUShareCenter *s_instance3 = nil;

@synthesize type;
@synthesize shareClient;
@synthesize clientContainerVC;

#pragma mark - life

- (id)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (id)initWithType:(CUShareClientType)aType
{
    if (self = [self init]) {
        type = aType;
    }
    
    return self;
}

- (void)dealloc
{
    [shareClient release];
    [clientContainerVC release];
    
    [super dealloc];
}

//not thread safe
+ (CUShareCenter *)sharedInstance:(CUShareCenter *)instance {
    if (instance == nil)
    {
        instance = [[CUShareCenter alloc] init];
    }
    
    return instance;
}

+ (CUShareCenter *)sharedInstanceWithType:(CUShareClientType)type
{
    CUShareCenter *center = nil;
    
    switch (type) {
        case SINACLIENT:
            
            center = [CUShareCenter sharedInstance:s_instance1];
            s_instance1 = center;
            
            break;
        case TTWEIBOCLIENT:
            center = [CUShareCenter sharedInstance:s_instance2];
            s_instance2 = center;
            
            break;    
        case RENRENCLIENT:
            center = [CUShareCenter sharedInstance:s_instance3];
            s_instance3 = center;
            
            break;
            
        default:
            break;
    }
    
    return center;
}

//not thread fault
+ (void)destory:(CUShareCenter *)instance
{
    if (instance != nil) {
        [instance release];
        instance = nil;
    }
    
    return;
}

+ (void)setupClient:(id<CUShareClientData>)client 
           withType:(CUShareClientType)aType
{
    [CUShareCenter sharedInstanceWithType:aType].type = aType;
    [CUShareCenter sharedInstanceWithType:aType].shareClient = client;
}

+ (void)setupContainer:(UIViewController *)containerVC
              withType:(CUShareClientType)type
{
    [CUShareCenter sharedInstanceWithType:type].clientContainerVC = containerVC;
}

#pragma mark - common method

- (void)showWithText:(NSString *)text
{
    return [self showWithText:text andImage:nil];
}

- (void)showWithText:(NSString *)text andImage:(UIImage *)image
{
    if (![self isBind]) {
        [shareClient CUOpenAuthViewInViewController:clientContainerVC];
    }
    else {
        [shareClient CUShowWithText:text andImage:image];
    }
}

- (void)showWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    if (![self isBind]) {
        [shareClient CUOpenAuthViewInViewController:clientContainerVC];
    }
    else {
        [shareClient CUShowWithText:text andImageURLString:imageURLString];
    }
}

- (BOOL)isBind
{
    return [shareClient isCUAuth];
}

- (void)unBind
{
    return [shareClient CULogout];
}

- (void)Bind;
{    
    [shareClient CUOpenAuthViewInViewController:clientContainerVC];
   // [clientContainerVC presentModalViewController:[shareClient CUGetAuthViewController] animated:YES];
    
    return;
}

@end
