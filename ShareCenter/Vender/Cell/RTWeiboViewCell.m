//
//  RTWeiboViewCell.m
//  iKnow
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "RTWeiboViewCell.h"
#import "UIImageView+WebCache.h"
#import "GlobalDef.h"
#import <QuartzCore/QuartzCore.h>


@implementation RTWeiboViewCell


static UIImage* defaultAvatarImage;
static UIImage* defaultCoverImage;
static UIImage* defaultCoverBackgroundImage;
static UIImage* defaultBackgroundImage;
static UIImage* defaultSubtitleBackgroundImage;
static UIImage* defaultTagImage;


@synthesize nameLabel = _nameLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize providerLabel = _providerLabel;
@synthesize openCountLabel = _openCountLabel;
@synthesize publishDateLabel = _publishDateLabel;
@synthesize typeImageView = _typeImageView;
@synthesize subtitleBackgroundImageView = _subtitleBackgroundImageView;
@synthesize coverBackgroundImageView = _coverBackgroundImageView;
@synthesize avatarImageView = _avatarImageView;
@synthesize coverImageView = _coverImageView;
@synthesize avatarButton = _avatarButton;
@synthesize tagImageView = _tagImageView;
@synthesize systemTagButton = _systemTagButton;
@synthesize seriesTagButton = _seriesTagButton;
@synthesize favoriteCountLabel = _favoriteCountLabel;
@synthesize commentCountLabel = _commentCountLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
        
        [self setBackgroundImage:nil];
        [self setSubtitleBackgoundImage];
	}
	
	return self;
}

static NSDateFormatter *s_format = nil;

- (void)setDataSource:(id)data
{
    if (data == nil) 
        return;
    
    Status *status = data;
    [self setBackgroundImage:nil];
    [self setName:status.text];
    //[self setFavoriteCount:status.retweetsCountText];
    [self setCommentCount:status.commentsCountText];
    [self setDescription:status.retweetedStatus.text];
    [self setProvider:status.user.screenName];
    [self setOpenCount:status.retweetsCountText];
     
    if (s_format == nil) {
        s_format = [[NSDateFormatter alloc] init];
        [s_format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:status.createdAt];
    
    [self setPublishDate:[s_format stringFromDate:date]];
    
    if (status.bmiddlePic) {
        [self setCoverImageUrl:status.bmiddlePic];
    }
    else {
        [self setCoverImageUrl:status.retweetedStatus.bmiddlePic];
    }
    
}


- (void)setType:(int)flag
{
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_typeImageView];
    }
}

+ (UIImage*)getDefaultCoverImage {
    
    if (defaultCoverImage == nil) {
        defaultCoverImage = [[UIImage imageNamed:@"DefaultCover.png"] retain];
    }
    
    return defaultCoverImage;
}

+ (UIImage*)getDefaultAvatarImage {
    
    if (defaultAvatarImage == nil) {
        defaultAvatarImage = [[UIImage imageNamed:@"Avatar1.png"] retain];
    }
    
    return defaultAvatarImage;
}

+ (UIImage*)getDefaultCoverBackgroundImage {

    if (defaultCoverBackgroundImage == nil) {
        defaultCoverBackgroundImage = [[UIImage imageNamed:@"ArticleCoverBackground.png"] retain];
    }
    
    return defaultCoverBackgroundImage;
}

+ (UIImage*)getDefaultBackgroundImage {
    
    if (defaultBackgroundImage == nil) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"CellBackground" ofType:@"png"];
        defaultBackgroundImage = [[UIImage imageWithContentsOfFile:imagePath]
                                    stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        [defaultBackgroundImage retain];
    }
    
    return defaultBackgroundImage;
}

+ (UIImage*)getDefaultSubtitleBackgroundImage {
    
    if (defaultSubtitleBackgroundImage == nil) {
        defaultSubtitleBackgroundImage = [[UIImage imageNamed:@"SubtitleBackground.png"] retain];
    }
    
    return defaultSubtitleBackgroundImage;
}

+ (UIImage*)getDefaultTagImage {
    
    if (defaultTagImage == nil) {
        defaultTagImage = [[UIImage imageNamed:@"tag.png"] retain];
    }
    
    return defaultTagImage;
}

- (void)setCoverImageUrl:(NSString*)url
{
    if ([url length] == 0)
        return;
    
    if (!_coverBackgroundImageView) {
        _coverBackgroundImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_coverBackgroundImageView];
    }

    _coverBackgroundImageView.image = [RTWeiboViewCell getDefaultCoverBackgroundImage];

    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_coverImageView];
    }
    
    coverImageUrl = [url copy];
    
    [_coverImageView setImageWithURL:[NSURL URLWithString:url] 
                    placeholderImage:[RTWeiboViewCell getDefaultCoverImage]
                             options:0];//SDWebImageLowPriority];
}

- (void)setDescription:(NSString *)newDescription
{
    if (!_descriptionLabel) {
		_descriptionLabel = [[UILabel alloc] init];
		_descriptionLabel.font = ZBSTYLE_font;
		_descriptionLabel.textColor = ZBSTYLE_tableSubTextColor;
		_descriptionLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
		_descriptionLabel.textAlignment = UITextAlignmentLeft;
		_descriptionLabel.contentMode = UIViewContentModeTop;
		_descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
		_descriptionLabel.numberOfLines = 0;
		
		[self.contentView addSubview:_descriptionLabel];
	}
    
    _descriptionLabel.text = newDescription ? newDescription : @"";
}

- (void)setOpenCount:(NSString *)newCount
{
    if (!_openCountLabel) {
		_openCountLabel = [[UILabel alloc] init];
		_openCountLabel.font = ZBSTYLE_font;
		_openCountLabel.textColor = ZBSTYLE_tableSubTextColor;
		_openCountLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
		_openCountLabel.textAlignment = UITextAlignmentLeft;
		_openCountLabel.contentMode = UIViewContentModeTop;
		_openCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_openCountLabel.numberOfLines = 1;
		
		[self.contentView addSubview:_openCountLabel];
	}
    
    NSString *openCount = @"";
    
    if ([newCount length] > 0) {
        openCount = [NSString stringWithFormat:@"转发：%@", newCount];
    }
    
    _openCountLabel.text = openCount;
}

- (void)setFavoriteCount:(NSString *)newCount
{
    if (!_favoriteCountLabel) {
        _favoriteCountLabel = [[UILabel alloc] init];
        _favoriteCountLabel.font = ZBSTYLE_font;
        _favoriteCountLabel.textColor = ZBSTYLE_tableSubTextColor;
        _favoriteCountLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _favoriteCountLabel.textAlignment = UITextAlignmentLeft;
        _favoriteCountLabel.contentMode = UIViewContentModeTop;
        _favoriteCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _favoriteCountLabel.numberOfLines = 1;
        
        //[self.contentView addSubview:_favoriteCountLabel];
    }
    
    NSString *favoriteCount = @"";
    
    if ([newCount length] > 0) {
        favoriteCount = newCount;
    }
    
    _favoriteCountLabel.text = favoriteCount;
}

- (void)setCommentCount:(NSString *)newCount
{
    if (!_commentCountLabel) {
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.font = ZBSTYLE_font;
        _commentCountLabel.textColor = ZBSTYLE_tableSubTextColor;
        _commentCountLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _commentCountLabel.textAlignment = UITextAlignmentLeft;
        _commentCountLabel.contentMode = UIViewContentModeTop;
        _commentCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _commentCountLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_commentCountLabel];
    }
    
    NSString *commentCount = @"";
    
    if ([newCount length] > 0) {
        commentCount = newCount;
    }
    
    _commentCountLabel.text = commentCount;
}

- (void)setPublishDate:(NSString *)newDate
{
    if (!_publishDateLabel) {
        _publishDateLabel = [[UILabel alloc] init];
        _publishDateLabel.font = ZBSTYLE_font;
        _publishDateLabel.textColor = ZBSTYLE_tableSubTextColor;
        _publishDateLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _publishDateLabel.textAlignment = UITextAlignmentRight;
        _publishDateLabel.contentMode = UIViewContentModeTop;
        _publishDateLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _publishDateLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_publishDateLabel];
    }
    
    NSString *createTime = @"";
    
    //去掉日期后面的时间
    if ([newDate length] > 0) {
        NSRange range = [newDate rangeOfString:@" "];
        if (range.location != NSNotFound) {
            range.length = range.location;
            range.location = 0;
            
            createTime = [newDate substringWithRange:range];
            _publishDateLabel.text = createTime;
        }
        else {
            _publishDateLabel.text = newDate;
        }
    }
    else {
        _publishDateLabel.text = @"";
    }

}

- (void)setProvider:(NSString *)newProvider
{
    if (!_providerLabel) {
        _providerLabel = [[UILabel alloc] init];
        _providerLabel.font = ZBSTYLE_font;
        _providerLabel.textColor = ZBSTYLE_tableSubTextColor;
        _providerLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _providerLabel.textAlignment = UITextAlignmentLeft;
        _providerLabel.contentMode = UIViewContentModeTop;
        _providerLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _providerLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_providerLabel];
    }
    
    NSString *provider = [newProvider length] > 0 ? newProvider : @"";
    
    _providerLabel.text = provider;
}

- (void)setName:(NSString *)newName
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = ZBSTYLE_tableFont;
        _nameLabel.textColor = ZBSTYLE_textColor;
        _nameLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _nameLabel.textAlignment = UITextAlignmentLeft;
        _nameLabel.contentMode = UIViewContentModeTop;
        _nameLabel.lineBreakMode = UILineBreakModeWordWrap;
        _nameLabel.numberOfLines = 0;
        
        [self.contentView addSubview:_nameLabel];
    }
    
    _nameLabel.text = newName ? newName : @"<未命名>";
}

- (void)setAvatarImageUrl:(NSString*)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector
{    
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:_avatarImageView];
        
        CALayer *layer = [_avatarImageView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:5];
    }
    
    if (!_avatarButton) {
        _avatarButton = [[UIButton alloc] init];
        
        if (target != nil && selector != nil)
            [_avatarButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_avatarButton];
    }
    
    _avatarButton.tag = tagId;

    [_avatarImageView setImageWithURL:[NSURL URLWithString:url]
                     placeholderImage:[RTWeiboViewCell getDefaultAvatarImage]
                              options:SDWebImageLowPriority];
}

-(void)setArticleTags:(NSArray*)tags target:(id)target action:(SEL)selector
{
    if ([tags count] == 0)
    {
        RELEASE_SAFELY(_systemTagButton);
        return;
    }
    
    if (!_tagImageView) {
        
        _tagImageView = [[UIImageView alloc] init];
        _tagImageView.image = [RTWeiboViewCell getDefaultTagImage]; 
        _tagImageView.frame = CGRectMake(0,
                                         0,
                                         TAG_WIDTH,
                                         TAG_HEIGHT);
        
        [self.contentView addSubview:_tagImageView];
    }
    
    if (!_systemTagButton) {
        _systemTagButton = [[UIButton alloc] init];
        
        _systemTagButton.titleLabel.font = ZBSTYLE_font_smaller;
        _systemTagButton.titleLabel.backgroundColor = RGBCOLOR(229,229,229);
        [_systemTagButton setTitleColor:ZBSTYLE_tableSubTextColor forState:UIControlStateNormal];
        
        if (target != nil && selector != nil)
            [_systemTagButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_systemTagButton];
    }
    
    [_systemTagButton setTitle:[tags objectAtIndex:0] forState:UIControlStateNormal];
    
    if ([tags count] > 1) {
        
        if (!_seriesTagButton) {
            _seriesTagButton = [[UIButton alloc] init];
            
            _seriesTagButton.titleLabel.font = ZBSTYLE_font_smaller;
            _seriesTagButton.titleLabel.backgroundColor = RGBCOLOR(229,229,229);
            [_seriesTagButton setTitleColor:ZBSTYLE_tableSubTextColor forState:UIControlStateNormal];
            
            if (target != nil && selector != nil)
                [_seriesTagButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:_seriesTagButton];
        }
        
        [_seriesTagButton setTitle:[tags objectAtIndex:1] forState:UIControlStateNormal];
    }
    else {
        [_seriesTagButton setTitle:@"" forState:UIControlStateNormal];
    }

}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _favoriteCountLabel.backgroundColor = [UIColor clearColor];
    _commentCountLabel.backgroundColor = [UIColor clearColor];
    _openCountLabel.backgroundColor = [UIColor clearColor];
    _publishDateLabel.backgroundColor = [UIColor clearColor];
    _providerLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
}


//theImage为nil时使用默认的CellBackground.png作为表格Cell背景
- (void)setBackgroundImage:(UIImage *)theImage
{
    UIImage *backgroundImage;
    
    if (theImage == nil) {

        backgroundImage = [RTWeiboViewCell getDefaultBackgroundImage];
    }
    else {
        backgroundImage = theImage;
    }
    
    if (self.backgroundView == nil) {
        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}

- (void)setSubtitleBackgoundImage {
    
    if (!_subtitleBackgroundImageView) {

        _subtitleBackgroundImageView = [[UIImageView alloc] init];
        _subtitleBackgroundImageView.image = [RTWeiboViewCell getDefaultSubtitleBackgroundImage]; 
        _subtitleBackgroundImageView.frame = CGRectMake(0, 
                                                        0, 
                                                        CELL_CONTENT_WIDTH, 
                                                        SUBTITLE_HEIGHT);
        
        [self.contentView addSubview:_subtitleBackgroundImageView];
    }
}

- (void)setRead:(BOOL)read {
    _bRead = read;
}


+ (CGFloat)rowHeightForObject:(id)object {

    if (object == nil)
        return 0.0;
    
    Status *status = object;

    CGFloat coverImageHeight = kTableCellSmallMargin;
    if ([status.bmiddlePic length]) {
        coverImageHeight = [status.bmiddlePic length] > 0 ? COVER_BACKGROUND_HEIGHT : kTableCellSmallMargin;
    } 
    else {
        coverImageHeight = [status.retweetedStatus.bmiddlePic length] > 0 ? COVER_BACKGROUND_HEIGHT : kTableCellSmallMargin;
    }
    
    //主标题
    CGSize titleLabelSize = [status.text sizeWithFont:ZBSTYLE_tableFont
                                   constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                       lineBreakMode:UILineBreakModeWordWrap];
    
    //子标题
    CGSize subtitleLabelSize = [@"Hello World" sizeWithFont:ZBSTYLE_font
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    CGSize descriptionLabelSize = {0};
    if ([status.retweetedStatus.text length] > 0)
    {
        descriptionLabelSize = [status.retweetedStatus.text sizeWithFont:ZBSTYLE_font
                                               constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                                   lineBreakMode:UILineBreakModeWordWrap];
    }
    
    CGFloat textHeight = coverImageHeight + titleLabelSize.height + subtitleLabelSize.height + SUBTITLE_HEIGHT 
        + descriptionLabelSize.height + (descriptionLabelSize.height > 0 ? kTableCellSmallMargin : 0); 
    
    return textHeight + kTableCellSmallMargin * 4;
}

#pragma mark -
#pragma mark UIView

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _nameLabel.text = nil;
    _providerLabel.text = nil;
    _openCountLabel.text = nil;
    _publishDateLabel.text = nil;
    _typeImageView.image = nil;
    _coverBackgroundImageView.image = nil;
    
    [_coverImageView cancelCurrentImageLoad];
    [_avatarImageView cancelCurrentImageLoad];
    
    _coverImageView.image = nil;
    _avatarImageView.image = nil;
    
    descriptionLabelSizeForPerformance = CGSizeZero;
    
    RELEASE_SAFELY(coverImageUrl);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //取得subtitle的高度
    /*
    CGSize subtitleLabelSize = [@"2011-09-13 " sizeWithFont:ZBSTYLE_font
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];*/
    
    //这里为了提高效率，去掉了动态获取大小，如果修改字体，需要修改这里的大小
    //这里为了提高效率，在320＊480分辨率下为 ｛78， 18｝这里统一
    //｛80， 18｝
    CGSize subtitleLabelSize = {80, 18};
    
    //当前View的x坐标
    CGFloat left = kTableCellSmallMargin;
    //当前View的y坐标
    CGFloat top = kTableCellSmallMargin;
    
    //设置_avatarImageView的坐标
    _avatarImageView.frame = CGRectMake(left - 2, kTableCellSmallMargin - 2, AVATAR_WIDTH, AVATAR_WIDTH);
    
    //设置_avatarButton的坐标
    _avatarButton.frame = CGRectMake(0, 0, AVATAR_WIDTH*3, subtitleLabelSize.height + kTableCellMargin*3);
    
    left += (kTableCellSmallMargin + AVATAR_WIDTH);
    
    //设置_providerLabel的坐标
    _providerLabel.frame = CGRectMake(left, 
                                      (SUBTITLE_HEIGHT - subtitleLabelSize.height) / 2, 
                                      CELL_CONTENT_WIDTH/2, 
                                      subtitleLabelSize.height);
    
    //设置_favoriteCountLabel的坐标
    _favoriteCountLabel.frame = CGRectMake(CELL_CONTENT_WIDTH - 70, 
                                      (SUBTITLE_HEIGHT - subtitleLabelSize.height) / 2, 
                                      30, 
                                      subtitleLabelSize.height);
    
    //设置_commentCountLabel的坐标
    _commentCountLabel.frame = CGRectMake(CELL_CONTENT_WIDTH - 24, 
                                      (SUBTITLE_HEIGHT - subtitleLabelSize.height) / 2, 
                                      29, 
                                      subtitleLabelSize.height);
    
    left = kTableCellSmallMargin;
    
    //y坐标下移
    top += SUBTITLE_HEIGHT;
    
    //取得文章标题的高度
    CGSize nameLabelSize = [_nameLabel.text sizeWithFont:ZBSTYLE_tableFont
                                        constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                            lineBreakMode:UILineBreakModeWordWrap];
    //CGSize nameLabelSize = {95, 21};
    _nameLabel.frame = CGRectMake(left, top, CELL_CONTENT_WIDTH - 2*kTableCellSmallMargin, nameLabelSize.height);
    
    //_coverImageView在_nameLabel之下
    top = (_nameLabel.frame.origin.y + _nameLabel.frame.size.height);
    left = (CELL_CONTENT_WIDTH - COVER_BACKGROUND_WIDTH) / 2;
    
    if ([coverImageUrl length] > 0) {
        _coverBackgroundImageView.frame = CGRectMake(left, top, COVER_BACKGROUND_WIDTH, COVER_BACKGROUND_HEIGHT);
        
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImageView.frame = CGRectMake(left + (COVER_BACKGROUND_WIDTH - COVER_IMAGE_WIDTH)/2, 
                                       top + (COVER_BACKGROUND_HEIGHT - COVER_IMAGE_HEIGHT)/2, 
                                       COVER_IMAGE_WIDTH, 
                                       COVER_IMAGE_HEIGHT);
        
        top += COVER_BACKGROUND_HEIGHT;
    } else {
        _coverImageView.frame = CGRectZero;
        
        top += kTableCellSmallMargin;
    }
    
    //取得_descriptionLabe的宽度和高度
    CGSize descriptionLabelSize = [_descriptionLabel.text sizeWithFont:ZBSTYLE_font
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeWordWrap];
    
    //设置_descriptionLabe的坐标
    _descriptionLabel.frame = CGRectMake(kTableCellSmallMargin, top, CELL_CONTENT_WIDTH - 2*kTableCellSmallMargin, descriptionLabelSize.height);
    
    if (descriptionLabelSize.height > 0) {
        top += descriptionLabelSize.height + kTableCellSmallMargin;
    }
    
    //取得_openCountLabel的高度和宽度
    CGSize openCountLabelSize = [_openCountLabel.text sizeWithFont:ZBSTYLE_font
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    //设置_openCountLabel坐标
    _openCountLabel.frame = CGRectMake(kTableCellSmallMargin, 
                                       top, 
                                       openCountLabelSize.width, 
                                       openCountLabelSize.height);
    
    //设置_typeImageView的坐标
    if (_typeImageView.image != nil)
    {
        _typeImageView.frame = CGRectMake(2 * kTableCellSmallMargin + openCountLabelSize.width, 
                                          top, 
                                          TYPE_IMAGE_WIDTH, 
                                          TYPE_IMAGE_HEIGHT);
    }
    
    left = CELL_CONTENT_WIDTH - subtitleLabelSize.width - kTableCellSmallMargin;
    
    //设置_publishDateLabel的坐标 
    _publishDateLabel.frame = CGRectMake(left, top, subtitleLabelSize.width, subtitleLabelSize.height);
    
    left = 2 * kTableCellSmallMargin;
    top += subtitleLabelSize.height + kTableCellSmallMargin;
    
    /*
    //取得systemTagLabelSize的宽度和高度
    CGSize systemTagButtonSize = [[_systemTagButton titleForState:UIControlStateNormal] 
                                  sizeWithFont:ZBSTYLE_font
                                  constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    //设置_tagImageView的坐标
    _tagImageView.frame = CGRectMake(left, 
                                     top + (systemTagButtonSize.height - TAG_HEIGHT) / 2, 
                                     TAG_WIDTH, 
                                     TAG_HEIGHT);
    
    left += TAG_WIDTH + kTableCellSmallMargin;
    
    //设置_systemTagButton的坐标
    _systemTagButton.frame = CGRectMake(left, 
                                        top, 
                                        systemTagButtonSize.width, 
                                        systemTagButtonSize.height);
    
    left += systemTagButtonSize.width;
    
    //取得seriesTagLabelSize的宽度和高度
    CGSize seriesTagButtonSize = [[_seriesTagButton titleForState:UIControlStateNormal] 
                                  sizeWithFont:ZBSTYLE_font
                                  constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    //设置_seriesTagButton的坐标
    _seriesTagButton.frame = CGRectMake(left, 
                                        top, 
                                        seriesTagButtonSize.width, 
                                        seriesTagButtonSize.height);*/
}


- (void)dealloc {
    
    RELEASE_SAFELY(_nameLabel);
    RELEASE_SAFELY(_favoriteCountLabel);
    RELEASE_SAFELY(_commentCountLabel);
    RELEASE_SAFELY(_providerLabel);
    RELEASE_SAFELY(_openCountLabel);
    RELEASE_SAFELY(_publishDateLabel);
    RELEASE_SAFELY(_typeImageView);
    RELEASE_SAFELY(_subtitleBackgroundImageView);
    RELEASE_SAFELY(_coverBackgroundImageView);
    RELEASE_SAFELY(_coverImageView);
    RELEASE_SAFELY(_avatarImageView);
    RELEASE_SAFELY(_avatarButton);
    RELEASE_SAFELY(coverImageUrl);
    RELEASE_SAFELY(_tagImageView);
    RELEASE_SAFELY(_systemTagButton);
    RELEASE_SAFELY(_seriesTagButton);
    
    [super dealloc];
}

@end
