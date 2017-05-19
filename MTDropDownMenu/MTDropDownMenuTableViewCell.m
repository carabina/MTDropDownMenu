 //
//  MTDropDownMenuTableViewCell.m
//  HTMF
//
//  Created by admin on 16/7/5.
//  Copyright © 2016年 bilian shen All rights reserved.
//

#import "MTDropDownMenuTableViewCell.h"
#import "MTDropMenuColor.h"

#define MARGIN_LEFT 30.0/2.0

@interface MTDropDownMenuTableViewCell ()

@property (nonatomic, strong) UILabel *label; // 文字
@property (nonatomic, strong) UIImageView *iconImageView; // icon
@property (nonatomic, strong) UIImageView *selectImageView; // 选中标识图片

@end

@implementation MTDropDownMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - cell init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)layoutSubviews {
    
    // 解决切换展开都布局一遍的问题（不加判断会有sepLine下移的效果，会不舒服）
    if ([self.contentView.subviews containsObject:self.label] || [self.contentView.subviews containsObject:self.iconImageView]) {
        return;
    }
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    // sepLine
    UIView *sepLine = [[UIView alloc]init];
    [sepLine setBackgroundColor:DROPMENU_LINECOLOR];
//    sepLine.backgroundColor = [UIColor redColor];
    
    [self.contentView addSubview:sepLine];
    sepLine.frame = CGRectMake(0, height - 0.5, width, 0.5);
    
    // image
    [self.contentView addSubview:self.selectImageView];
    self.selectImageView.frame = CGRectMake(width - 40, (height - 24)/2.0, 24, 24);
    
    // label
    [self.contentView addSubview:self.label];
    self.label.frame = CGRectMake(15, 0, width - 60, height);
    
    // icon
    [self.contentView addSubview:self.iconImageView];
}


#pragma mark - public method

- (void)configMenuCellWithColor:(UIColor *)mainColor selectedImage:(UIImage *)image contentString:(NSString *)contentString {
    // 主题色
    self.selectedColor = mainColor;
    // 选中图片
    self.selectedImage = image;
    self.selectImageView.image = image;
    // text
    self.contentString = contentString;
    self.label.text = self.contentString;
    
    self.iconImageView.hidden = YES;
    self.label.hidden = NO;
}

- (void)configMenuCellWithColor:(UIColor *)mainColor selectedImage:(UIImage *)image iconImageView:(UIImageView *)iconImageView {
    // 主题色
    self.selectedColor = mainColor;
    // 选中图片
    self.selectedImage = image;
    self.selectImageView.image = image;
    // icon
    CGFloat height = iconImageView.frame.size.height;
    self.iconView = iconImageView;
    self.iconImageView.image = iconImageView.image;
    self.iconImageView.frame = CGRectMake(15, (self.frame.size.height - height) * 0.5, iconImageView.frame.size.width, height);
    
    self.label.hidden = YES;
    self.iconImageView.hidden = NO;
}

- (void)configMenuWithSelectedState:(BOOL)selected {
    self.label.textColor = selected ? self.selectedColor : DROPMENU_TEXTCOLOR;
    self.selectImageView.hidden = !selected;
}

#pragma mark - lazy init

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:16];
        _label.textColor = DROPMENU_TEXTCOLOR;
        _label.adjustsFontSizeToFitWidth = YES;
    }
    return _label;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = self.selectedImage;
    }
    return _selectImageView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

@end
