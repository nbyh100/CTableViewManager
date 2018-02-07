//
//  CTableViewManager.m
//  CTableViewManager
//
//  Created by 张九州 on 16/2/26.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "CTableViewManager.h"
#import "UITableView+Private.h"

@implementation CTableViewManager

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView.c_sectionModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[section];
    return sectionModel.cellModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *section = tableView.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = section.cellModels[indexPath.row];
    NSString *cellId = NSStringFromClass([cellModel cellClass]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[cellModel cellClass] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[section];
    UITableViewHeaderFooterView *view;
    if (sectionModel.headerViewModel && [sectionModel.headerViewModel headerFooterViewClass]) {
        NSString *headerId = NSStringFromClass([sectionModel.headerViewModel headerFooterViewClass]);
        [tableView registerClass:[sectionModel.headerViewModel headerFooterViewClass] forHeaderFooterViewReuseIdentifier:headerId];
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
        if (!view) {
            view = [[[sectionModel.headerViewModel headerFooterViewClass] alloc] initWithReuseIdentifier:headerId];
        }
        if ([view respondsToSelector:@selector(setViewModel:)]) {
            [view performSelector:@selector(setViewModel:) withObject:sectionModel.headerViewModel];
        }
    } else {
        // 防止出现白条
        view = (UITableViewHeaderFooterView *)[UIView new];
    }
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[section];
    UITableViewHeaderFooterView *view;
    if (sectionModel.footerViewModel && [sectionModel.footerViewModel headerFooterViewClass]) {
        NSString *footerId = NSStringFromClass([sectionModel.footerViewModel headerFooterViewClass]);
        [tableView registerClass:[sectionModel.footerViewModel headerFooterViewClass] forHeaderFooterViewReuseIdentifier:footerId];
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerId];
        if (!view) {
            view = [[[sectionModel.footerViewModel headerFooterViewClass] alloc] initWithReuseIdentifier:footerId];
        }

        if ([view respondsToSelector:@selector(setViewModel:)]) {
            [view performSelector:@selector(setViewModel:) withObject:sectionModel.footerViewModel];
        }
    } else {
        // 防止出现白条
        view = (UITableViewHeaderFooterView *)[UIView new];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSMutableDictionary *tmpCells;

    CTableViewSectionModel *section = tableView.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = section.cellModels[indexPath.row];
    if ([cellModel respondsToSelector:@selector(cellHeight)]) {
        CGFloat cellHeight = [cellModel cellHeight];
        if (cellHeight == UITableViewAutomaticDimension) {
            if (!tmpCells) {
                tmpCells = [NSMutableDictionary dictionary];
            }
            Class cellClass = [cellModel cellClass];
            NSString *cellClassString = NSStringFromClass(cellClass);
            UITableViewCell<CTableViewCellProtocol> *tmpCell = tmpCells[cellClassString];
            if (!tmpCell) {
                tmpCell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellClassString];
                tmpCells[cellClassString] = tmpCell;
            }
            [tmpCell setCellModel:cellModel];
            CGSize size = [tmpCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            return size.height;
        } else {
            return cellHeight;
        }
    } else {
        return tableView.rowHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[section];
    if (sectionModel.headerViewModel && [sectionModel.headerViewModel respondsToSelector:@selector(headerFooterViewHeight)]) {
        return [sectionModel.headerViewModel headerFooterViewHeight];
    } else {
        if (sectionModel.headerHeight > 0) {
            return sectionModel.headerHeight;
        }
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[section];
    if (sectionModel.footerViewModel && [sectionModel.footerViewModel respondsToSelector:@selector(headerFooterViewHeight)]) {
        return [sectionModel.footerViewModel headerFooterViewHeight];
    } else {
        if (sectionModel.footerHeight > 0) {
            return sectionModel.headerHeight;
        }
        return 0.01;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = sectionModel.cellModels[indexPath.row];
    cell.selectionStyle = (cellModel.cellActionEnabled && cellModel.highlightWhenTapCell) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setCellModel:)]) {
        [cell performSelector:@selector(setCellModel:) withObject:cellModel];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(didEndDisplay)]) {
        [cell performSelector:@selector(didEndDisplay)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *sectionModel = tableView.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = sectionModel.cellModels[indexPath.row];
    BOOL selectionIsChanged = cellModel != tableView.c_selectedCellModel;
    tableView.c_selectedCellModel = cellModel;

    if (cellModel.cellActionEnabled) {
        if (cellModel.didSelectCellBlock) {
            cellModel.didSelectCellBlock(cellModel, selectionIsChanged);
        }
        if (tableView.c_didSelectCellBlock) {
            tableView.c_didSelectCellBlock(cellModel, selectionIsChanged);
        }
    }

    if (cellModel.autoDeselect) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
