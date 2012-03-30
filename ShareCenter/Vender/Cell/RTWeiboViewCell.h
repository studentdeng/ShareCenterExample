//
//  RTTableViewCell.h
//  iKnow
//
//  Abstract: 富文本单元格样式
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

#define TYPE_IMAGE_HEIGHT       16
#define TYPE_IMAGE_WIDTH        TYPE_IMAGE_HEIGHT

#define COVER_IMAGE_HEIGHT      160//135
#define COVER_IMAGE_WIDTH       160//190

#define COVER_BACKGROUND_HEIGHT 180//160
#define COVER_BACKGROUND_WIDTH  180//220

#define SUBTITLE_HEIGHT         40
#define AVATAR_WIDTH            32

#define TAG_WIDTH               14
#define TAG_HEIGHT              TAG_WIDTH

#define CELL_CONTENT_WIDTH   SCREEN_WIDTH


@interface RTWeiboViewCell : UITableViewCell 
{
    int _type;
    
    UILabel *_nameLabel;
    UILabel *_favoriteCountLabel;
    UILabel *_commentCountLabel;
    UILabel *_descriptionLabel;
    UILabel *_providerLabel;
    UILabel *_openCountLabel;
    UILabel *_publishDateLabel;
    
    UIImageView *_typeImageView;
    UIImageView *_subtitleBackgroundImageView;
    UIImageView *_coverBackgroundImageView;
    
    UIImageView* _avatarImageView;
    UIImageView* _coverImageView;
    NSString *coverImageUrl;
    
    UIButton *_avatarButton;
    
    UIImageView* _tagImageView;
    UIButton *_systemTagButton; //主标签，即系统标签
    UIButton *_seriesTagButton; //系列标签
    
    BOOL _bRead;
    
    //performance
    CGSize descriptionLabelSizeForPerformance;
}

@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) UILabel *favoriteCountLabel;
@property (nonatomic, readonly) UILabel *commentCountLabel;
@property (nonatomic, readonly) UILabel *descriptionLabel;
@property (nonatomic, readonly) UILabel *providerLabel;
@property (nonatomic, readonly) UILabel *openCountLabel;
@property (nonatomic, readonly) UILabel *publishDateLabel;

@property (nonatomic, readonly) UIImageView *typeImageView;
@property (nonatomic, readonly) UIImageView *subtitleBackgroundImageView;
@property (nonatomic, readonly) UIImageView *coverBackgroundImageView;

@property (nonatomic, readonly) UIImageView *avatarImageView;
@property (nonatomic, readonly) UIImageView *coverImageView;

@property (nonatomic, readonly) UIButton *avatarButton;

@property (nonatomic, readonly) UIImageView *tagImageView;
@property (nonatomic, readonly) UIButton *systemTagButton;
@property (nonatomic, readonly) UIButton *seriesTagButton;

- (void)setDataSource:(id)data;
- (void)setAvatarImageUrl:(NSString*)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector;

- (void)setRead:(BOOL)read;

+ (CGFloat)rowHeightForObject:(id)object;

@end
