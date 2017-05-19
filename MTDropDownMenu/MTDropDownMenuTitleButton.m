//
//  MTDropDownMenuTitleButton.m
//  HTMF
//
//  Created by admin on 16/7/5.
//  Copyright © 2016年 bilian shen All rights reserved.
//

#import "MTDropDownMenuTitleButton.h"
#import "MTDropMenuColor.h"

#define MARGIN_LEFT 30.0/2.0
#define MARGIN_TEXTANDIMAGE 10.0

#define ANIMATION_INTEVAL 0.25
#define IMAGE_SIZE (CGSizeMake(12, 6))


@interface MTDropDownMenuTitleButton ()

@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIColor *mainTitleColor;

@end

@implementation MTDropDownMenuTitleButton

- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color frame: (CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _mainTitle = title;
        _mainTitleColor = color;
        self.isImageView = NO;
        
        [self viewConfig];
    }
    return self;
}

- (instancetype)initWithIcon:(UIImageView *)iconImageView color:(UIColor *)color frame: (CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _iconImageView = iconImageView;
        _mainTitleColor = color;
        self.isImageView = YES;
        
        [self viewConfig];
    }
    return self;
}

#pragma mark - 布局

- (void)viewConfig {

    if (!self.isImageView) {
        CGRect tmp = [_mainTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.mainTitleLabel.font ,NSFontAttributeName, nil] context:nil];
        
        CGFloat titleWidth = tmp.size.width;
        CGFloat labelLeft = (self.frame.size.width - titleWidth - MARGIN_TEXTANDIMAGE - IMAGE_SIZE.width) * 0.5;
        
        // title
        self.mainTitleLabel.text = _mainTitle;
        [self addSubview:self.mainTitleLabel];
        self.mainTitleLabel.frame = CGRectMake(labelLeft, 0, titleWidth, self.frame.size.height);
        
        // image
        [self addSubview:self.arrowImageView];
        self.arrowImageView.frame = CGRectMake(CGRectGetMaxX(self.mainTitleLabel.frame) + MARGIN_TEXTANDIMAGE, (self.frame.size.height - IMAGE_SIZE.height)/2.0, IMAGE_SIZE.width, IMAGE_SIZE.height);
    }
    else {
        CGSize tmpSize = self.iconImageView.frame.size;
        CGFloat iconWidth = tmpSize.width;
        CGFloat iconLeft = (self.frame.size.width - iconWidth - MARGIN_TEXTANDIMAGE - IMAGE_SIZE.width) * 0.5;
        
        // icon
        [self addSubview:self.iconImageView];
        self.iconImageView.frame = CGRectMake(iconLeft, (self.frame.size.height - tmpSize.height) * 0.5, iconWidth, tmpSize.height);

        // image
        [self addSubview:self.arrowImageView];
        self.arrowImageView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + MARGIN_TEXTANDIMAGE, (self.frame.size.height - IMAGE_SIZE.height)/2.0, IMAGE_SIZE.width, IMAGE_SIZE.height);
    }
}

#pragma mark - lazy init

- (UILabel *)mainTitleLabel {
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc] init];
        _mainTitleLabel.textColor = DROPMENU_TEXTCOLOR;
        _mainTitleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _mainTitleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"Arrow"];
    }
    return _arrowImageView;
}

//- (UIImageView *)iconImageView {
//    if (!_iconImageView) {
//        _iconImageView = [[UIImageView alloc] init];
//    }
//    return _iconImageView;
//}

#pragma mark - select

- (void)setSelected:(BOOL)selected {
    [super setSelected: selected];
    self.userInteractionEnabled = NO;
    _mainTitleLabel.textColor = selected ? _mainTitleColor : DROPMENU_TEXTCOLOR;
    if (selected) {
        [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }
    else {
        [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
            self.arrowImageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - set

- (void)setMainTitle:(NSString *)mainTitle {
    _mainTitle = mainTitle;
    self.mainTitleLabel.text = _mainTitle;
    // 更新位置
    CGRect tmp = [_mainTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.mainTitleLabel.font ,NSFontAttributeName, nil] context:nil];
    // title宽度
    CGFloat titleWidth = tmp.size.width;
    CGFloat maxWidth = self.frame.size.width - MARGIN_TEXTANDIMAGE - IMAGE_SIZE.width;
    titleWidth = (titleWidth > maxWidth ? maxWidth : titleWidth);
    CGFloat labelLeft = (self.frame.size.width - titleWidth - MARGIN_TEXTANDIMAGE - IMAGE_SIZE.width) / 2.0;
    // 设置frame
    self.mainTitleLabel.frame = CGRectMake(labelLeft, 0, titleWidth, self.frame.size.height);
    self.arrowImageView.frame = CGRectMake(CGRectGetMaxX(self.mainTitleLabel.frame) + MARGIN_TEXTANDIMAGE, (self.frame.size.height - IMAGE_SIZE.height)/2.0, IMAGE_SIZE.width, IMAGE_SIZE.height);
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    self.iconImageView.image = iconImage;
}

@end
