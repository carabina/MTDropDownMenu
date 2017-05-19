//
//  MTDropDownMenu.h
//  HTMF
//
//  Created by admin on 16/7/5.
//  Copyright © 2016年 bilian shen All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTIndexPath : NSObject

/**
 * 按钮所在为column
 */
@property (nonatomic, assign) NSInteger column;

/**
 * 下拉菜单每一行为row
 */
@property (nonatomic, assign) NSInteger row;

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row;

@end


@class MTDropDownMenu;

#pragma mark - dataSource

@protocol MTDropDownMenuDataSource <NSObject>

@required
/**
 * 共有几列，按钮个数
 */
- (NSInteger)numberOfColumsInMenu:(MTDropDownMenu *)menu;

/**
 * 一列有几行
 */
- (NSInteger)menu:(MTDropDownMenu *)menu numberOfRowsInColums:(NSInteger)column;


@optional

/**
 * 菜单主题色
 * 不实现则主题色为 MTDropMenuColor.h 文件中的 DROPMENU_MAINCOLOR
 */
- (UIColor *)menuMainColor:(MTDropDownMenu *)menu;

/**
 * row选中图片
 * 不实现则选中图片为 DropMenuImages 文件中的 Item_Selected
 */
- (UIImage *)menuSelectedImage:(MTDropDownMenu *)menu;

/**
 * 在column列自定义的view
 */
- (UIView *)menuDesignedView:(MTDropDownMenu *)menu;

/**
 * 每一列标题：按钮标题
 */
- (NSString *)menu:(MTDropDownMenu *)menu titleForColumn:(NSInteger)column;

/**
 * 每一行标题：下拉菜单的标题
 */
- (NSString *)menu:(MTDropDownMenu *)menu titleForRowAtIndexPath:(MTIndexPath *)indexPath;

/**
 * 每一列图标：按钮图标
 */
- (UIImageView *)menu:(MTDropDownMenu *)menu iconViewForColumn:(NSInteger)column;

/**
 * 每一行图标：下拉菜单的图标
 */
- (UIImageView *)menu:(MTDropDownMenu *)menu iconForRowAtIndexPath:(MTIndexPath *)indexPath;

@end


#pragma mark - delegate

@protocol MTDropDownMenuDelegate <NSObject>

@optional
/**
 * 点击下拉菜单每一行的响应事件
 */
- (void)menu:(MTDropDownMenu *)menu didSelectRowAtIndexPath:(MTIndexPath *)indexPath;

@end

#define MT_SUGESTED_DROPDOWNMENU_HEIGHT 44.0

@interface MTDropDownMenu : UIView

@property (nonatomic, weak) id<MTDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id<MTDropDownMenuDelegate> delegate;

/**
 * 收起下拉菜单
 */
- (void)closeDropDownMenu;

/**
 * 重载菜单数据
 */
- (void)reloadMenuData;

@end
