//
//  MTDropDownMenuTableViewCell.h
//  HTMF
//
//  Created by admin on 16/7/5.
//  Copyright © 2016年 bilian shen All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTDropDownMenuTableViewCell : UITableViewCell

@property (nonatomic, strong) UIColor *selectedColor; // 选中颜色
@property (nonatomic, strong) UIImage *selectedImage; // 选中图片名称
@property (nonatomic, strong) NSString *contentString; // cell上的文字
@property (nonatomic, strong) UIImageView *iconView; // cell上的icon


- (void)configMenuCellWithColor:(UIColor *)mainColor selectedImage:(UIImage *)image contentString:(NSString *)contentString;

- (void)configMenuCellWithColor:(UIColor *)mainColor selectedImage:(UIImage *)image iconImageView:(UIImageView *)iconImageView;

- (void)configMenuWithSelectedState:(BOOL)selected;

@end
