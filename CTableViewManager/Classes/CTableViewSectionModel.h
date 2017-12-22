//
//  CTableViewSectionModel.h
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 
@class CTableViewHeaderFooterModel;

@protocol CTableViewHeaderFooterViewProtocol <NSObject>

@optional

/**
 从数据模型更新视图内容

 @param viewModel 数据模型
 */
- (void)setViewModel:(CTableViewHeaderFooterModel *)viewModel;

@end

@interface CTableViewSectionModel : NSObject

@property (nonatomic, weak, readonly) UITableView *tableView; // 所属的table view
@property (nonatomic, strong) CTableViewHeaderFooterModel *headerViewModel; // header数据模型
@property (nonatomic, strong) CTableViewHeaderFooterModel *footerViewModel; // footer数据模型
@property (nonatomic, assign) CGFloat headerHeight; // 只提供固定的间隔，仅header==nil时有效
@property (nonatomic, assign) CGFloat footerHeight; // 只提供固定的间隔，仅footer==nil时有效

@end

@interface CTableViewHeaderFooterModel : NSObject

/**
 视图的类型

 @return 视图的类型
 */
- (Class)headerFooterViewClass;

/**
 视图的高度

 @return 视图的高度
 */
- (CGFloat)headerFooterViewHeight;

@end

