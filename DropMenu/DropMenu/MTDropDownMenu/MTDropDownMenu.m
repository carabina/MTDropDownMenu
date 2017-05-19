//
//  MTDropDownMenu.m
//  HTMF
//
//  Created by admin on 16/7/5.
//  Copyright © 2016年 bilian shen All rights reserved.
//

#import "MTDropDownMenu.h"
#import "MTDropDownMenuTitleButton.h"
#import "MTDropDownMenuTableViewCell.h"
#import "MTDropMenuColor.h"

#define ANIMATION_INTEVAL 0.30
#define CELL_HEIGHT 50.0
#define DESIGN_COLUMN 1000

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


typedef void(^MTDropDownMenuAnimateCompleteHandler)(void);

static NSInteger clickCount;
static NSString * const tableViewCellID = @"MTDropDownMenutableViewCell";
static NSString * const tableViewCellImageID = @"MTDropDownMenutableViewCellImage";
static NSString * const tableViewDesignCellID = @"MTDropDownMenutableViewDesignCell";

@implementation MTIndexPath

/**
 * column : 按钮个数
   row    : 对应按钮下拉菜单的行数
 */
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    if (self = [super init]) {
        _column = column;
        _row = row;
    }
    return self;
}

// 生成类方法，便于调用
+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row {
    MTIndexPath *indexPath = [[self alloc] initWithColumn:column row:row];
    return indexPath;
}

@end


@interface MTDropDownMenu () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIColor *mainColor; // 主题色
@property (nonatomic, strong) UIImage *selectedImage; // row选中图片
@property (nonatomic, assign) NSInteger currentSelectedMenuIndex; // 当前选中的菜单序号，与button的index对应
@property (nonatomic, assign) NSInteger numOfMenu; // 几个下拉菜单
@property (nonatomic, strong) UIView *backgroundView; // 整体背景view
@property (nonatomic, assign, getter = isShow) BOOL show; // 控制是否显示菜单
@property (nonatomic, strong) UITableView *tableView; // 下拉的菜单

@property (nonatomic, copy) NSArray *array; // dataSource
@property (nonatomic, strong) NSMutableArray *titleButtons; // 按钮标题数组
@property (nonatomic, weak) MTDropDownMenuTitleButton *selectedButton; // 按钮
@property (nonatomic, weak) MTDropDownMenuTableViewCell *defaultSelectedCell ; // 默认选中的cell


@end


@implementation MTDropDownMenu

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentSelectedMenuIndex = -1;
        _show = NO;
        clickCount = 0;
    }
    return self;
}

# pragma mark - lazy init
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = DROPMENU_BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        
        _backgroundView.opaque = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap:)];
        [_backgroundView addGestureRecognizer:tapGesture];
    }
    return _backgroundView;
}

#pragma mark - setter

- (void)setDataSource:(id<MTDropDownMenuDataSource>)dataSource {
    // 防止在设置多次dataSource
    if (_dataSource) {
        return;
    }
    _dataSource = dataSource;
    if ([_dataSource respondsToSelector:@selector(numberOfColumsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumsInMenu:self];
    }
    if ([_dataSource respondsToSelector:@selector(menuMainColor:)]) {
        _mainColor = [_dataSource menuMainColor:self];
    }
    else {
        _mainColor = DROPMENU_MAINCOLOR;
    }
    
    if ([_dataSource respondsToSelector:@selector(menuSelectedImage:)]) {
        _selectedImage = [_dataSource menuSelectedImage:self];
    }
    else {
        _selectedImage = [UIImage imageNamed:@"Item_Selected"];
    }
    
    CGFloat buttonWidth = self.frame.size.width / _numOfMenu;
    _titleButtons = [NSMutableArray arrayWithCapacity:_numOfMenu];
    MTDropDownMenuTitleButton *lastTitleButton = nil;
    
    // 判断图标和文字二选一
    if ([_dataSource respondsToSelector:@selector(menu:titleForColumn:)]) {
        // 设置button
        for (NSInteger index = 0; index < _numOfMenu; index++) {
            NSString *title = [_dataSource menu:self titleForColumn:index];
            CGFloat left = (lastTitleButton ? CGRectGetMaxX(lastTitleButton.frame) : 0);
            CGRect buttonFrame = CGRectMake(left, 0, buttonWidth, self.frame.size.height);
            
            MTDropDownMenuTitleButton *button = [[MTDropDownMenuTitleButton alloc] initWithTitle:title color:_mainColor frame: (CGRect)buttonFrame];
            
            button.index = index;
            [button addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.titleButtons addObject:button];
            [self addSubview:button];
            lastTitleButton = button;
        }
    }
    if ([_dataSource respondsToSelector:@selector(menu:iconViewForColumn:)]) {
        // 设置button
        for (NSInteger index = 0; index < _numOfMenu; index++) {
            UIImageView *imageView = [_dataSource menu:self iconViewForColumn:index];
            
            CGFloat left = (lastTitleButton ? CGRectGetMaxX(lastTitleButton.frame) : 0);
            CGRect buttonFrame = CGRectMake(left, 0, buttonWidth, self.frame.size.height);
            
            MTDropDownMenuTitleButton *button = [[MTDropDownMenuTitleButton alloc] initWithIcon:imageView color:_mainColor frame:(CGRect)buttonFrame];
            
            button.index = index;
            [button addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.titleButtons addObject:button];
            [self addSubview:button];
            lastTitleButton = button;
        }

    }
}

#pragma mark - tableview dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(menu:numberOfRowsInColums:)] && _currentSelectedMenuIndex != DESIGN_COLUMN) {
        return [self.dataSource menu:self numberOfRowsInColums:self.currentSelectedMenuIndex];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentSelectedMenuIndex == DESIGN_COLUMN && [self.dataSource respondsToSelector:@selector(menuDesignedView:)]) {
        UIView *subView = [self.dataSource menuDesignedView: self];
        return subView.frame.size.height;
    }
    else {
        return CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // DESIGN_COLUMN ： 定制的cell
    if (_currentSelectedMenuIndex == DESIGN_COLUMN) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewDesignCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if ([self.dataSource respondsToSelector:@selector(menuDesignedView:)]) {
            UIView *subView = [self.dataSource menuDesignedView:self];
            [cell addSubview:subView];
        }
        
        return cell;
    }
    else {
        if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {
            MTDropDownMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID];
            if (!cell) {
                cell = [[MTDropDownMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellID];
            }
            MTIndexPath *menuIndexPath = [MTIndexPath indexPathWithColumn:_currentSelectedMenuIndex row:indexPath.row];
            
            NSString *cellTitleText;
            cellTitleText = [self.dataSource menu:self titleForRowAtIndexPath:menuIndexPath];

            [cell configMenuCellWithColor:_mainColor selectedImage:_selectedImage contentString:cellTitleText];
            
            NSString *currentButtonText = [self.titleButtons[self.currentSelectedMenuIndex] mainTitle];
            
            // 根据text判断是否为选中
            if ([cell.contentString isEqualToString:currentButtonText]) {
                [cell configMenuWithSelectedState:YES];
                self.defaultSelectedCell = cell;
            }
            else {
                [cell configMenuWithSelectedState:NO];
            }
            return cell;
        }
        
        if ([self.dataSource respondsToSelector:@selector(menu:iconViewForColumn:)]) {
            MTDropDownMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellImageID];
            if (!cell) {
                cell = [[MTDropDownMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellImageID];
            }
            MTIndexPath *menuIndexPath = [MTIndexPath indexPathWithColumn:_currentSelectedMenuIndex row:indexPath.row];
            
            UIImageView *cellIcon;
            cellIcon = [self.dataSource menu:self iconForRowAtIndexPath:menuIndexPath];
            
            [cell configMenuCellWithColor:_mainColor selectedImage:_selectedImage iconImageView:cellIcon];
            
            UIImage *currentButtonImage = [self.titleButtons[self.currentSelectedMenuIndex] iconImage];
            
            // 根据text判断是否为选中
            if ([cell.iconView.image isEqual:currentButtonImage]) {
                [cell configMenuWithSelectedState:YES];
                self.defaultSelectedCell = cell;
            }
            else {
                [cell configMenuWithSelectedState:NO];
            }
            return cell;
        }
    }
    NSLog(@"heloo");
    return nil;
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && _currentSelectedMenuIndex != DESIGN_COLUMN) {
        MTIndexPath *menuIndexPath = [MTIndexPath indexPathWithColumn:_currentSelectedMenuIndex row:indexPath.row];

        if ([self.delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            [_delegate menu:self didSelectRowAtIndexPath:menuIndexPath];
        }
        
        [self configMenuMainTitleWithSelectRow:indexPath.row];
    }
}

- (void)configMenuMainTitleWithSelectRow:(NSInteger)row
{
    MTDropDownMenuTitleButton *button = _titleButtons[self.currentSelectedMenuIndex];
    
    if (button.isImageView && [self.dataSource respondsToSelector:@selector(menu:iconForRowAtIndexPath:)]) {
        UIImageView *iconImageView = [self.dataSource menu:self iconForRowAtIndexPath:[MTIndexPath indexPathWithColumn:self.currentSelectedMenuIndex row:row]];
        
        button.iconImage = iconImageView.image;
        
        if (![self.defaultSelectedCell.imageView.image isEqual:iconImageView.image]) {
            [self.defaultSelectedCell configMenuWithSelectedState:NO];
        }
        
        [self animationWithTitleButton:button BackgroundView:self.backgroundView tableView:self.tableView show:NO complete:^{
            self.show = NO;
        }];
    }
    
    else {
        if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {
            NSString *currentSelectedTitle = [self.dataSource menu:self titleForRowAtIndexPath:[MTIndexPath indexPathWithColumn:self.currentSelectedMenuIndex row:row]];
            button.mainTitle = currentSelectedTitle;
            if (![self.defaultSelectedCell.contentString isEqualToString:currentSelectedTitle]) {
                //        self.defaultSelectedCell.selected = NO;
                [self.defaultSelectedCell configMenuWithSelectedState:NO];
            }
            [self animationWithTitleButton:button BackgroundView:self.backgroundView tableView:self.tableView show:NO complete:^{
                self.show = NO;
            }];

        }
    }
}

#pragma mark - 点击事件

- (void)backgroundViewDidTap:(UIGestureRecognizer *)tap {
    MTDropDownMenuTitleButton *titleButton = self.titleButtons[self.currentSelectedMenuIndex];
    [self animationWithTitleButton:titleButton BackgroundView:self.backgroundView tableView:self.tableView show:NO complete:^{
        self.show = NO;
    }];
}

- (void)titleButtonDidClick:(MTDropDownMenuTitleButton *)titleButton {
    clickCount ++;
    if (titleButton.index == self.currentSelectedMenuIndex && self.isShow) {
        // 隐藏
        [self animationWithTitleButton:titleButton BackgroundView:self.backgroundView tableView:self.tableView show:NO complete:^{
            self.currentSelectedMenuIndex = titleButton.index;
            self.show = NO;
        }];
    }
    else {
        // 显示
        self.currentSelectedMenuIndex = titleButton.index;
        [self.tableView reloadData];
        [self animationWithTitleButton:titleButton BackgroundView:self.backgroundView tableView:self.tableView show:YES complete:^{
            self.show = YES;
        }];
    }
}


#pragma mark - animation

// button的setSelected 方法， 给button加动画
- (void)animationWithTitleButton:(MTDropDownMenuTitleButton *)button BackgroundView:(UIView *)backgroundView
                  tableView:(UITableView *)tableView
                            show:(BOOL)isShow
                        complete:(MTDropDownMenuAnimateCompleteHandler)complete
{
    __weak __typeof(&*self)(weakSelf) = self;
    if (self.selectedButton == button) {
        button.selected = isShow;
    } else {
        button.selected = YES;
        self.selectedButton.selected = NO;
        self.selectedButton = button;
    }
    [self animationWithBackgroundView:backgroundView show:isShow complete:^{
        [weakSelf animationWithTableView:tableView show:isShow complete:nil];
    }];
    if (complete) {
        complete();
    }
}

// 给backgroundView 加动画
- (void)animationWithBackgroundView:(UIView *)backgroundView
                               show:(BOOL)isShow
                           complete:(MTDropDownMenuAnimateCompleteHandler)complete
{
    __weak __typeof(&*self)(weakSelf) = self;
    
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    // menu相对于keyWindow的frame
    CGRect menuRect = [self convertRect:self.bounds toView:superView];
    
    if (isShow) {
        if (1 == clickCount) {
            [superView addSubview:backgroundView];
            backgroundView.frame = CGRectMake(0, CGRectGetMaxY(menuRect), SCREEN_WIDTH, superView.frame.size.height - CGRectGetMaxY(weakSelf.frame));
        }
        [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
            backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
            backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
            clickCount = 0;
        }];
    }
    if (complete) {
        complete();
    }
}

// 给tableview 加动画
- (void)animationWithTableView:(UITableView *)tableView
                               show:(BOOL)isShow
                           complete:(MTDropDownMenuAnimateCompleteHandler)complete
{
    __weak __typeof(&*self)(weakSelf) = self;
    
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    // menu相对于keyWindow的frame
    CGRect menuRect = [self convertRect:self.bounds toView:superView];
    
    // 收起的tableView frame
    CGRect closeFrame = CGRectMake(0, CGRectGetMaxY(menuRect), SCREEN_WIDTH, 0);
    
    if (isShow) {
        CGFloat tableViewHeight = 0.0f;
        if (tableView) {
            NSInteger rowCount = [tableView numberOfRowsInSection:0];
//            UIView *superView = [weakSelf superview];

            if (_currentSelectedMenuIndex == DESIGN_COLUMN && [weakSelf.dataSource respondsToSelector:@selector(menuDesignedView:)]) {
                UIView *subView = [weakSelf.dataSource menuDesignedView: weakSelf];
                tableViewHeight = subView.frame.size.height;
            }
            else {
                tableViewHeight = rowCount * CELL_HEIGHT;
            }
            CGFloat maxHeight = superView.frame.size.height - CGRectGetMaxY(weakSelf.frame);
            tableViewHeight = tableViewHeight > maxHeight ? maxHeight : tableViewHeight;
            
            // 展开的tableView frame
            CGRect openFrame = CGRectMake(0, CGRectGetMaxY(menuRect), SCREEN_WIDTH, tableViewHeight);
            
            // clickCount 控制是否展开
            if (1 == clickCount) {
                [superView addSubview:tableView];
                tableView.frame = closeFrame;
                
                // 加上beginUpdates、endUpdates这一对可以防止首次展开tableView的subView从左往右移动的动画
                [tableView beginUpdates];
                [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
                    tableView.frame = openFrame;
                }];
                [tableView endUpdates];
            } else {
                [tableView beginUpdates];
                [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
                    tableView.frame = openFrame;
                }];
                [tableView endUpdates];
            }
        }
        
    } else {
        if (tableView) {
            [UIView animateWithDuration:ANIMATION_INTEVAL animations:^{
                tableView.frame = closeFrame;
            } completion:^(BOOL finished) {
                [tableView removeFromSuperview];
                clickCount = 0;
            }];
        }
    }
    if (complete) {
        complete();
    }
}

#pragma mark - public method

- (void)closeDropDownMenu{
    if (_currentSelectedMenuIndex == -1) {
        return;
    }
    MTDropDownMenuTitleButton *titleButton = self.titleButtons[_currentSelectedMenuIndex];
    [self animationWithTitleButton:titleButton BackgroundView:self.backgroundView tableView:self.tableView show:NO complete:^{
        self.currentSelectedMenuIndex = titleButton.index;
        self.show = NO;
    }];
}

- (void)reloadMenuData {
    // 重新调用dataSource
    self.dataSource = _dataSource;
    self.currentSelectedMenuIndex = 0;
    [self.tableView reloadData];
}

@end
