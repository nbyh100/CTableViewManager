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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView.c_sectionModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[section];
    return CSectionGetCells(sectionModel).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[indexPath.section];
    id<CTableViewCellModel> cellModel = CSectionGetCells(sectionModel)[indexPath.row];
    NSString *cellId = NSStringFromClass([cellModel cellClass]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[cellModel cellClass] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[section];
    UITableViewHeaderFooterView *view;
    if ([(NSObject *)sectionModel respondsToSelector:@selector(headerViewModel)]) {
        Class headerViewClass = [[sectionModel headerViewModel] viewClass];
        NSString *headerId = NSStringFromClass(headerViewClass);
        [tableView registerClass:headerViewClass forHeaderFooterViewReuseIdentifier:headerId];
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
        if (!view) {
            view = [[headerViewClass alloc] initWithReuseIdentifier:headerId];
        }
    } else {
        // 防止出现白条
        view = (UITableViewHeaderFooterView *)[UIView new];
    }
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[section];
    UITableViewHeaderFooterView *view;
    if ([(NSObject *)sectionModel respondsToSelector:@selector(footerViewModel)]) {
        Class footerViewClass = [[sectionModel footerViewModel] viewClass];
        NSString *footerId = NSStringFromClass(footerViewClass);
        [tableView registerClass:footerViewClass forHeaderFooterViewReuseIdentifier:footerId];
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerId];
        if (!view) {
            view = [[footerViewClass alloc] initWithReuseIdentifier:footerId];
        }
    } else {
        // 防止出现白条
        view = (UITableViewHeaderFooterView *)[UIView new];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSMutableDictionary *tmpCells;

    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[indexPath.section];
    id<CTableViewCellModel> cellModel = CSectionGetCells(sectionModel)[indexPath.row];
    if ([(NSObject *)cellModel respondsToSelector:@selector(cellHeight)]) {
        CGFloat cellHeight = [cellModel cellHeight];
        if (cellHeight == UITableViewAutomaticDimension) {
            if (!tmpCells) {
                tmpCells = [NSMutableDictionary dictionary];
            }
            Class cellClass = [cellModel cellClass];
            NSString *cellClassString = NSStringFromClass(cellClass);
            UITableViewCell *tmpCell = tmpCells[cellClassString];
            if (!tmpCell) {
                tmpCell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellClassString];
                tmpCells[cellClassString] = tmpCell;
            }
            if ([(NSObject *)cellModel respondsToSelector:@selector(willDisplay:)]) {
                [cellModel willDisplay:tmpCell];
            }
            CGSize size = [tmpCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            return size.height;
        } else {
            return cellHeight;
        }
    } else {
        return tableView.rowHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[section];
    if ([(NSObject *)sectionModel respondsToSelector:@selector(headerViewModel)] && [(NSObject *)[sectionModel headerViewModel] respondsToSelector:@selector(viewHeight)]) {
        return [[sectionModel headerViewModel] viewHeight];
    } else {
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[section];
    if ([(NSObject *)sectionModel respondsToSelector:@selector(footerViewModel)] && [(NSObject *)[sectionModel footerViewModel] respondsToSelector:@selector(viewHeight)]) {
        return [[sectionModel footerViewModel] viewHeight];
    } else {
        return 0.01;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[indexPath.section];
    id<CTableViewCellModel> cellModel = CSectionGetCells(sectionModel)[indexPath.row];
    if ([(NSObject *)cellModel respondsToSelector:@selector(willDisplay:)]) {
        [cellModel willDisplay:cell];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[indexPath.section];
    id<CTableViewCellModel> cellModel = CSectionGetCells(sectionModel)[indexPath.row];
    if ([(NSObject *)cellModel respondsToSelector:@selector(didEndDisplay:)]) {
        [cellModel didEndDisplay:cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[indexPath.section];
    id<CTableViewCellModel> cellModel = CSectionGetCells(sectionModel)[indexPath.row];
    if ([(NSObject *)cellModel respondsToSelector:@selector(didSelect)]) {
        [cellModel didSelect];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CTableViewSectionModel> sectionModel = tableView.c_sectionModels[indexPath.section];
    id<CTableViewCellModel> cellModel = CSectionGetCells(sectionModel)[indexPath.row];
    if ([(NSObject *)cellModel respondsToSelector:@selector(didDeselect)]) {
        [cellModel didDeselect];
    }
}

@end
