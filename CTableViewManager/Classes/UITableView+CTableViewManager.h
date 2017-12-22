//
//  UITableView+CTableViewManager.h
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CTableViewManagerException @"CTableViewManagerException"

@class CTableViewSectionModel;
@class CTableViewCellModel;
 
@interface UITableView (CTableViewManager)

@property (nonatomic, strong, readonly) CTableViewSectionModel *c_defaultSection; // 第一个section，没有会自动创建
@property (nonatomic, strong, readonly) CTableViewCellModel *c_selectedCellModel; // 选中的cell
@property (nonatomic, copy) void (^c_didSelectCellBlock)(CTableViewCellModel *cellModel, BOOL selectionIsChanged); // 选中cell的回调，selectionIsChanged表示是否为第一次选中。如果cell的种类比较多，不推荐使用。建议使用CTableViewCellModel的didSelectCellBlock

/**
 重新加载数据源，会调用reloadData方法
 用于第一次初始化，或者全部刷新数据
 不在此方法的block中操作数据，会发生实时的列表操作，如insertRowsAtIndexPaths:

 @param block 刷新block
 */
- (void)c_reloadDataWithBlock:(void (^)(void))block;

/**
 清空列表所有的数据
 */
- (void)c_removeAllSections;

/**
 检查section是否已经加入tableview

 @param sectionModel section数据模型

 @return 是否加入
 */
- (BOOL)c_sectionInTableView:(CTableViewSectionModel *)sectionModel;


/**
 检查cell是否已经加入tableview

 @param cellModel cell数据模型

 @return 是否加入
 */
- (BOOL)c_cellInTableView:(CTableViewCellModel *)cellModel;


/**
 获取cell对应的indexPath

 @param cellModel cell数据模型

 @return NSIndexPath
 */
- (NSIndexPath *)c_indexPathForCell:(CTableViewCellModel *)cellModel;

/**
 添加section

 @param sectionModel section数据模型
 */
- (void)c_addSection:(CTableViewSectionModel *)sectionModel;

/**
 在一个section后插入section

 @param sectionModel        要插入的section数据模型
 @param anotherSectionModel 目标section数据模型
 */
- (void)c_insertSection:(CTableViewSectionModel *)sectionModel
             afterSection:(CTableViewSectionModel *)anotherSectionModel;

/**
 在一个section前插入section

 @param sectionModel        要插入的section数据模型
 @param anotherSectionModel 目标section数据模型
 */
- (void)c_insertSection:(CTableViewSectionModel *)sectionModel
            beforeSection:(CTableViewSectionModel *)anotherSectionModel;

/**
 重新加载section

 @param sectionModel section数据模型
 */
- (void)c_reloadSection:(CTableViewSectionModel *)sectionModel;

/**
 删除section

 @param sectionModel section数据模型
 */
- (void)c_deleteSection:(CTableViewSectionModel *)sectionModel;

/**
 在第一个section添加一个cell。如果没有第一个section，则自动创建

 @param cellModel cell数据模型
 */
- (void)c_addCell:(CTableViewCellModel *)cellModel;

/**
 在第一个section添加多个cell。如果没有第一个section，则自动创建

 @param cellModels cell数据模型
 */
- (void)c_addCells:(NSArray<CTableViewCellModel *> *)cellModels;

/**
 在第一个section的cell后面插入cell。如果没有第一个section，则自动创建

 @param cellModel        cell数据模型
 @param anotherCellModel 目标cell数据模型
 */
- (void)c_insertCell:(CTableViewCellModel *)cellModel
             afterCell:(CTableViewCellModel *)anotherCellModel;

/**
 在第一个section的cell后面批量插入cell。如果没有第一个section，则自动创建

 @param cellModels       cell数据模型数组
 @param anotherCellModel 目标cell数据模型
 */
- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels
              afterCell:(CTableViewCellModel *)anotherCellModel;

/**
 在第一个section的cell前面插入cell。如果没有第一个section，则自动创建

 @param cellModel        cell数据模型
 @param anotherCellModel 目标cell数据模型
 */
- (void)c_insertCell:(CTableViewCellModel *)cellModel
            beforeCell:(CTableViewCellModel *)anotherCellModel;

/**
 在第一个section的cell前面批量插入cell。如果没有第一个section，则自动创建

 @param cellModels       cell数据模型数组
 @param anotherCellModel 目标cell数据模型
 */

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels
             beforeCell:(CTableViewCellModel *)anotherCellModel;

/**
 添加一个cell

 @param cellModel    cell数据模型
 @param sectionModel 目标section数据模型
 */
- (void)c_addCell:(CTableViewCellModel *)cellModel
          inSection:(CTableViewSectionModel *)sectionModel;

/**
 添加多个cell

 @param cellModels   cell数据模型数组
 @param sectionModel 目标section数据模型
 */
- (void)c_addCells:(NSArray<CTableViewCellModel *> *)cellModels
           inSection:(CTableViewSectionModel *)sectionModel;

/**
 在cell后面插入cell

 @param cellModel        cell数据模型
 @param anotherCellModel 目标cell数据模型
 @param sectionModel     目标section数据模型
 */
- (void)c_insertCell:(CTableViewCellModel *)cellModel
             afterCell:(CTableViewCellModel *)anotherCellModel
             inSection:(CTableViewSectionModel *)sectionModel;

/**
 在cell后面批量插入cell

 @param cellModels       cell数据模型数组
 @param anotherCellModel 目标cell数据模型
 @param sectionModel     目标section数据模型
 */
- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels
              afterCell:(CTableViewCellModel *)anotherCellModel
              inSection:(CTableViewSectionModel *)sectionModel;

/**
 在cell前面插入cell

 @param cellModel        cell数据模型
 @param anotherCellModel 目标cell数据模型
 @param sectionModel     目标section数据模型
 */
- (void)c_insertCell:(CTableViewCellModel *)cellModel
            beforeCell:(CTableViewCellModel *)anotherCellModel
             inSection:(CTableViewSectionModel *)sectionModel;

/**
 在cell前面批量插入cell

 @param cellModels       cell数据模型数组
 @param anotherCellModel 目标cell数据模型
 @param sectionModel     目标section数据模型
 */

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels
             beforeCell:(CTableViewCellModel *)anotherCellModel
              inSection:(CTableViewSectionModel *)sectionModel;

/**
 重新加载cell

 @param cellModel cell数据模型
 */
- (void)c_reloadCell:(CTableViewCellModel *)cellModel;

/**
 批量重新加载cell

 @param cellModels cell数据模型数组
 */
- (void)c_reloadCells:(NSArray<CTableViewCellModel *> *)cellModels;

/**
 删除cell

 @param cellModel cell数据模型
 */
- (void)c_deleteCell:(CTableViewCellModel *)cellModel;

/**
 批量删除cell

 @param cellModels cell数据模型数组
 */
- (void)c_deleteCells:(NSArray<CTableViewCellModel *> *)cellModels;

/**
 选择cell

 @param cellModel cell数据模型
 */
- (void)c_selectCell:(CTableViewCellModel *)cellModel;

/**
 取消选择cell

 @param cellModel cell数据模型
 */
- (void)c_deselectCell:(CTableViewCellModel *)cellModel;

@end

