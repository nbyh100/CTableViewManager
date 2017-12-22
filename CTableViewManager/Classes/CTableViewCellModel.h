//
//  CTableViewCellModel.h
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CTableViewSectionModel;
@class CTableViewCellModel;

@protocol CTableViewCellProtocol <NSObject>

@optional

/**
 从数据模型更新cell内容

 @param cellModel 数据模型
 */
- (void)setCellModel:(CTableViewCellModel *)cellModel;

/**
 cell结束展示后调用
 */
- (void)didEndDisplay;

@end

@interface CTableViewCellModel : NSObject

@property (nonatomic, weak, readonly) CTableViewSectionModel *sectionModel; // cell模型关联的section模型
@property (nonatomic, assign) BOOL autoDeselect; // 点击后自动取消选中，默认YES
@property (nonatomic, assign) BOOL isLastRow; // 是否为最后一行，可以用来隐藏cell下面的横线
                                              // 本属性需要调用者自己控制
@property (nonatomic, assign) BOOL highlightWhenTapCell; // 点击时是否显示高亮，默认NO，当cellActionEnabled为NO时没有效果
@property (nonatomic, assign) BOOL cellActionEnabled; // 是否支持点击，触发didSelectCellBlock，默认YES
@property (nonatomic, copy) void (^didSelectCellBlock)(CTableViewCellModel *cellModel, BOOL selectionIsChanged); // 点击cell执行的block，selectionIsChanged为YES表示此cell之前未被选中

/**
 空白cell模型

 @return self
 */
+ (instancetype)blankCellModel;

/**
 指定高度的空白cell模型

 @param height 固定的高度

 @return self
 */
+ (instancetype)blankCellModelWithHeight:(CGFloat)height;

/**
 设置点击cell执行的block，selectionIsChanged为YES表示此cell之前未被选中

 @param didSelectCellBlock 点击cell执行的block
 */
- (void)setDidSelectCellBlock:(void (^)(CTableViewCellModel *cellModel, BOOL selectionIsChanged))didSelectCellBlock;

/**
 cell类型

 @return cell类型
 */
- (Class)cellClass;

/**
 cell高度

 @return cell高度
 */
- (CGFloat)cellHeight;

@end

