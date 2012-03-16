//
//  CUShareCenter.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUShareClient.h"

@interface CUShareCenter : NSObject
{
    CUShareClientType type;
    id<CUShareClientData> shareClient;
    
    UIViewController *clientContainerVC;
}

+ (CUShareCenter *)sharedInstanceWithType:(CUShareClientType)type;

+ (void)destory:(CUShareCenter *)instance;

+ (void)setupClient:(id<CUShareClientData>)client 
           withType:(CUShareClientType)type;

+ (void)setupContainer:(UIViewController *)containerVC
              withType:(CUShareClientType)type;

- (void)showWithText:(NSString *)text;
- (void)showWithText:(NSString *)text andImage:(UIImage *)image;
- (void)showWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

- (BOOL)isBind;
- (void)unBind;
- (void)Bind;

@property (nonatomic, assign) CUShareClientType type;
@property (nonatomic, retain) UIViewController *clientContainerVC;

//it really should be retain!
@property (nonatomic, retain) id<CUShareClientData> shareClient;

@end
