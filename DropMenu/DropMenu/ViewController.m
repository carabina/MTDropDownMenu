//
//  ViewController.m
//  DropMenu
//
//  Created by bilian shen on 2017/5/4.
//  Copyright © 2017年 bilian shen. All rights reserved.
//

#import "ViewController.h"
#import "MTDropDownMenu.h"

@interface ViewController ()<MTDropDownMenuDelegate, MTDropDownMenuDataSource>

@property (nonatomic, strong) MTDropDownMenu *menu;

/**
 * 数据源数据
 */
@property (nonatomic, strong) NSMutableArray *mainTitleArray;
@property (nonatomic, strong) NSMutableArray *subTitleArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 数据源
//    self.mainTitleArray = [NSMutableArray arrayWithArray:@[@"水果", @"饮料"]];
//    NSArray *sub1 = @[@"苹果", @"香蕉", @"西瓜", @"凤梨", @"牛油果"];
//    NSArray *sub2 = @[@"雪碧", @"可乐", @"橙子汁", @"无敌好喝的草莓汁"];
//    self.subTitleArray = [NSMutableArray arrayWithArray:@[sub1, sub2]];
    
    
    self.mainTitleArray = [NSMutableArray arrayWithArray:@[@"fruits", @"gift"]];
    NSArray *sub1 = @[@"flower1", @"flower2", @"flower3", @"flower4"];
    NSArray *sub2 = @[@"gift1", @"gift2", @"gift3"];
    self.subTitleArray = [NSMutableArray arrayWithArray:@[sub1, sub2]];

    // add menu
    self.menu = [[MTDropDownMenu alloc] initWithFrame:(CGRect){100, 50, 200, 50}];
    self.menu.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.menu.delegate = self;
    self.menu.dataSource = self;
    [self.view addSubview: self.menu];
}


#pragma mark - MTDropDownMenuDataSource

/**
 * 共有几列，按钮个数
 */
- (NSInteger)numberOfColumsInMenu:(MTDropDownMenu *)menu {
    return  self.mainTitleArray.count;
}

/**
 * 一列有几行
 */
- (NSInteger)menu:(MTDropDownMenu *)menu numberOfRowsInColums:(NSInteger)column {
    NSArray *sub = [self.subTitleArray objectAtIndex:column];
    return  sub.count;
}

// 以下四个方法成套出现
// 选择其中之一, 暂不支持图文


/**
 * 每一列标题：按钮标题
 */
//- (NSString *)menu:(MTDropDownMenu *)menu titleForColumn:(NSInteger)column {
//    return  self.mainTitleArray[column];
//}


/**
 * 每一行标题：下拉菜单的标题
 */
//- (NSString *)menu:(MTDropDownMenu *)menu titleForRowAtIndexPath:(MTIndexPath *)indexPath {
//    NSArray *sub = [self.subTitleArray objectAtIndex:indexPath.column];
//
//    return  sub[indexPath.row];
//}

- (UIImageView *)menu:(MTDropDownMenu *)menu iconViewForColumn:(NSInteger)column {
    // size有用, origin随意传
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, 30, 30}];
    imageView.image = [UIImage imageNamed: self.mainTitleArray[column]];
    return imageView;
}


- (UIImageView *)menu:(MTDropDownMenu *)menu iconForRowAtIndexPath:(MTIndexPath *)indexPath {
    
    NSArray *sub = [self.subTitleArray objectAtIndex:indexPath.column];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, 20, 25}];
    imageView.image = [UIImage imageNamed: sub[indexPath.row]];

    return  imageView;
}

#pragma mark - MTDropDownMenuDelegate

/**
 * 点击下拉菜单每一行的响应事件
 */
- (void)menu:(MTDropDownMenu *)menu didSelectRowAtIndexPath:(MTIndexPath *)indexPath {
    NSLog(@"colum: %ld, row: %ld", indexPath.column, indexPath.row);
}

@end
