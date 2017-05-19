//
//  MTDropDownMenuTitleButton.h
//  HTMF
//
//  Created by admin on 16/7/5.
//  Copyright © 2016年 bilian shen All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTDropDownMenuTitleButton : UIButton


/**
 * 按钮文字
 */
@property (nonatomic, copy) NSString *mainTitle;

/**
 * 按钮icon
 */
@property (nonatomic, copy) UIImage *iconImage;

/**
 * 按钮序号
 */
@property (nonatomic, assign) NSInteger index;

/**
 * title是按钮标题， color是按钮选中之后的颜色
 */
- (instancetype)initWithTitle:(NSString *)title color:(UIColor *)color frame: (CGRect)frame;

/**
 * iconImageView是按钮图标， color是按钮选中之后的颜色
 */
- (instancetype)initWithIcon:(UIImageView *)iconImageView color:(UIColor *)color frame: (CGRect)frame;


/**
 * 图标还是文字
 */
@property (nonatomic, assign) BOOL isImageView;

@end
