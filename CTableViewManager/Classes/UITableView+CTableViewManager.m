//
//  UITableView+CTableViewManager.m
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "UITableView+CTableViewManager.h"
#import <objc/runtime.h>
#import "CTableViewSectionModel.h"
#import "CTableViewCellModel.h"

#ifndef DEBUG
    #define DEBUG 0
#endif

@interface CTableViewSectionModel (CellModels)

@property (nonatomic, strong, readonly) NSMutableArray *cellModels;

@end

@implementation CTableViewSectionModel (CellModels)

- (NSMutableArray *)cellModels
{
    NSMutableArray *cellModels = objc_getAssociatedObject(self, @selector(cellModels));
    if (!cellModels) {
        cellModels = [NSMutableArray array];
        objc_setAssociatedObject(self, @selector(cellModels), cellModels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cellModels;
}

@end

@interface CTableViewSectionModel (Private)

@property (nonatomic, weak) UITableView *tableView;

@end

@interface CTableViewCellModel (Private)

@property (nonatomic, weak) CTableViewSectionModel *sectionModel;

@end

@interface UITableView ()

@property (nonatomic, strong) NSMutableArray *c_sectionModels;
@property (nonatomic, strong) NSMutableSet *c_cellModels;
@property (nonatomic, assign) BOOL c_isReload;
@property (nonatomic, strong, readonly) CTableViewSectionModel *c_defaultSection;
@property (nonatomic, strong) CTableViewCellModel *c_selectedCellModel;

@end

@implementation UITableView (CTableViewManager)

#pragma mark - public

- (void)c_reloadDataWithBlock:(void (^)(void))block
{
    [self.c_sectionModels removeAllObjects];
    [self.c_cellModels removeAllObjects];

    self.c_isReload = YES;
    block();
    self.c_isReload = NO;

    [self reloadData];
}

- (void)c_removeAllSections
{
    [self.c_sectionModels removeAllObjects];
    [self.c_cellModels removeAllObjects];
    [self reloadData];
}

- (BOOL)c_sectionInTableView:(CTableViewSectionModel *)sectionModel
{
    return [self.c_sectionModels containsObject:sectionModel];
}

- (BOOL)c_cellInTableView:(CTableViewCellModel *)cellModel
{
    return [self.c_cellModels containsObject:cellModel];
}

- (NSIndexPath *)c_indexPathForCell:(CTableViewCellModel *)cellModel
{
    if (!cellModel.sectionModel) {
        return nil;
    }
    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:cellModel.sectionModel];
    if (sectionIndex == NSNotFound) {
        return nil;
    }
    NSInteger rowIndex = [cellModel.sectionModel.cellModels indexOfObject:cellModel];
    if (rowIndex == NSNotFound) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    return indexPath;
}

- (void)c_addSection:(CTableViewSectionModel *)sectionModel
{
    [self c_insertSection:sectionModel atIndex:self.c_sectionModels.count];
}

- (void)c_insertSection:(CTableViewSectionModel *)sectionModel afterSection:(CTableViewSectionModel *)anotherSectionModel
{
    [self ensureSectionExists:anotherSectionModel];

    NSInteger index = [self.c_sectionModels indexOfObject:anotherSectionModel];
    [self c_insertSection:sectionModel atIndex:index + 1];
}

- (void)c_insertSection:(CTableViewSectionModel *)sectionModel beforeSection:(CTableViewSectionModel *)anotherSectionModel
{
    [self ensureSectionExists:anotherSectionModel];

    NSInteger index = [self.c_sectionModels indexOfObject:anotherSectionModel];
    [self c_insertSection:sectionModel atIndex:index];
}

- (void)c_reloadSection:(CTableViewSectionModel *)sectionModel
{
    [self ensureSectionExists:sectionModel];

    if (!self.c_isReload) {
        NSInteger index = [self.c_sectionModels indexOfObject:sectionModel];
        [self reloadSections:[NSIndexSet indexSetWithIndex:index]
            withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_deleteSection:(CTableViewSectionModel *)sectionModel
{
    [self ensureSectionExists:sectionModel];

    NSInteger index = [self.c_sectionModels indexOfObject:sectionModel];
    [self.c_sectionModels removeObjectAtIndex:index];

    for (CTableViewCellModel *cellModel in sectionModel.cellModels) {
        [self.c_cellModels removeObject:cellModel];
    }

    if (!self.c_isReload) {
        [self deleteSections:[NSIndexSet indexSetWithIndex:index]
            withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_addCell:(CTableViewCellModel *)cellModel
{
    [self c_addCell:cellModel inSection:self.c_defaultSection];
}

- (void)c_addCells:(NSArray<CTableViewCellModel *> *)cellModels
{
    [self c_addCells:cellModels inSection:self.c_defaultSection];
}

- (void)c_insertCell:(CTableViewCellModel *)cellModel afterCell:(CTableViewCellModel *)anotherCellModel
{
    [self c_insertCell:cellModel afterCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels afterCell:(CTableViewCellModel *)anotherCellModel
{
    [self c_insertCells:cellModels afterCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_insertCell:(CTableViewCellModel *)cellModel beforeCell:(CTableViewCellModel *)anotherCellModel
{
    [self c_insertCell:cellModel beforeCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels beforeCell:(CTableViewCellModel *)anotherCellModel
{
    [self c_insertCells:cellModels beforeCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_addCell:(CTableViewCellModel *)cellModel inSection:(CTableViewSectionModel *)sectionModel
{
    [self c_addCells:@[cellModel] inSection:sectionModel];
}

- (void)c_addCells:(NSArray<CTableViewCellModel *> *)cellModels inSection:(CTableViewSectionModel *)sectionModel
{
    [self c_insertCells:cellModels atIndex:sectionModel.cellModels.count inSection:sectionModel];
}

- (void)c_insertCell:(CTableViewCellModel *)cellModel afterCell:(CTableViewCellModel *)anotherCellModel inSection:(CTableViewSectionModel *)sectionModel
{
    [self c_insertCells:@[cellModel] afterCell:anotherCellModel inSection:sectionModel];
}

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels afterCell:(CTableViewCellModel *)anotherCellModel inSection:(CTableViewSectionModel *)sectionModel
{
    [self ensureRowExists:anotherCellModel];

    NSInteger index = [sectionModel.cellModels indexOfObject:anotherCellModel];
    [self c_insertCells:cellModels atIndex:index + 1 inSection:sectionModel];
}

- (void)c_insertCell:(CTableViewCellModel *)cellModel beforeCell:(CTableViewCellModel *)anotherCellModel inSection:(CTableViewSectionModel *)sectionModel
{
    [self c_insertCells:@[cellModel] beforeCell:anotherCellModel inSection:sectionModel];
}

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels beforeCell:(CTableViewCellModel *)anotherCellModel inSection:(CTableViewSectionModel *)sectionModel
{
    [self ensureRowExists:anotherCellModel];

    NSInteger index = [sectionModel.cellModels indexOfObject:anotherCellModel];
    [self c_insertCells:cellModels atIndex:index inSection:sectionModel];
}

- (void)c_reloadCell:(CTableViewCellModel *)cellModel
{
    [self c_reloadCells:@[cellModel]];
}

- (void)c_reloadCells:(NSArray<CTableViewCellModel *> *)cellModels
{
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (CTableViewCellModel *cellModel in cellModels) {
        [self ensureRowExists:cellModel];

        NSInteger sectionIndex = [self.c_sectionModels indexOfObject:cellModel.sectionModel];
        NSInteger rowIndex = [cellModel.sectionModel.cellModels indexOfObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        [indexPaths addObject:indexPath];
    }

    if (!self.c_isReload) {
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_deleteCell:(CTableViewCellModel *)cellModel
{
    [self c_deleteCells:@[cellModel]];
}

- (void)c_deleteCells:(NSArray<CTableViewCellModel *> *)cellModels
{
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (CTableViewCellModel *cellModel in cellModels) {
        [self ensureRowExists:cellModel];

        NSInteger sectionIndex = [self.c_sectionModels indexOfObject:cellModel.sectionModel];
        NSInteger rowIndex = [cellModel.sectionModel.cellModels indexOfObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        [indexPaths addObject:indexPath];

        [self.c_cellModels removeObject:cellModel];
    }

    for (CTableViewCellModel *cellModel in cellModels) {
        [cellModel.sectionModel.cellModels removeObject:cellModel];
    }
    if (!self.c_isReload) {
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_selectCell:(CTableViewCellModel *)cellModel
{
    [self ensureRowExists:cellModel];

    if (cellModel == self.c_selectedCellModel) {
        return;
    }

    self.c_selectedCellModel = cellModel;
    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:cellModel.sectionModel];
    NSInteger rowIndex = [cellModel.sectionModel.cellModels indexOfObject:cellModel];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    [self selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)c_deselectCell:(CTableViewCellModel *)cellModel
{
    [self ensureRowExists:cellModel];

    if (self.c_selectedCellModel == cellModel) {
        self.c_selectedCellModel = nil;
        NSInteger sectionIndex = [self.c_sectionModels indexOfObject:cellModel.sectionModel];
        NSInteger rowIndex = [cellModel.sectionModel.cellModels indexOfObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        [self deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - private properties

- (NSMutableArray *)c_sectionModels
{
    NSMutableArray *sections = objc_getAssociatedObject(self, @selector(c_sectionModels));
    if (!sections) {
        sections = [NSMutableArray array];
        objc_setAssociatedObject(self, @selector(c_sectionModels), sections, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return sections;
}

- (NSMutableSet *)c_cellModels
{
    NSMutableSet *rows = objc_getAssociatedObject(self, @selector(c_cellModels));
    if (!rows) {
        rows = [NSMutableSet set];
        objc_setAssociatedObject(self, @selector(c_cellModels), rows, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return rows;
}

- (void)setFjr_isReload:(BOOL)c_isReload
{
    objc_setAssociatedObject(self, @selector(c_isReload), @(c_isReload), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)c_isReload
{
    return [objc_getAssociatedObject(self, @selector(c_isReload)) boolValue];
}

- (CTableViewSectionModel *)c_defaultSection
{
    if (self.c_sectionModels.count <= 0) {
        CTableViewSectionModel *sectionModel = [CTableViewSectionModel new];
        [self c_addSection:sectionModel];
    }
    return self.c_sectionModels.firstObject;
}

- (void)setFjr_selectedCellModel:(CTableViewCellModel *)c_selectedCellModel
{
    objc_setAssociatedObject(self, @selector(c_selectedCellModel), c_selectedCellModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CTableViewCellModel *)c_selectedCellModel
{
    return objc_getAssociatedObject(self, @selector(c_selectedCellModel));
}

- (void)setFjr_didSelectCellBlock:(void (^)(CTableViewCellModel *row, BOOL selectionIsChanged))c_didSelectCellBlock
{
    objc_setAssociatedObject(self, @selector(c_didSelectCellBlock), c_didSelectCellBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(CTableViewCellModel *, BOOL))c_didSelectCellBlock
{
    return objc_getAssociatedObject(self, @selector(c_didSelectCellBlock));
}

#pragma mark - private

- (void)c_insertSection:(CTableViewSectionModel *)sectionModel atIndex:(NSInteger)index;
{
    [self ensureSectionNotExists:sectionModel];

    sectionModel.tableView = self;
    [sectionModel.cellModels removeAllObjects];
    [self.c_sectionModels insertObject:sectionModel atIndex:index];

    if (!self.c_isReload) {
        // tableview可能会自带一个section，这通常发生在viewDidLoad之后。而viewDidLoad之前不会出现那个自带的section。
        if (!(self.c_sectionModels.count == 1 && self.numberOfSections == 1)) {
            [self insertSections:[NSIndexSet indexSetWithIndex:index]
                withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)c_insertCells:(NSArray<CTableViewCellModel *> *)cellModels atIndex:(NSInteger)rowIndex inSection:(CTableViewSectionModel *)sectionModel
{
    [self ensureSectionExists:sectionModel];

    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:sectionModel];
    NSInteger currentRowIndex = rowIndex;
    for (CTableViewCellModel *row in cellModels) {
        if ([self.c_cellModels containsObject:row]) {
            @throw [NSException exceptionWithName:CTableViewManagerException reason:@"Table view already contains this row." userInfo:nil];
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRowIndex inSection:sectionIndex];
        [indexPaths addObject:indexPath];
        currentRowIndex++;
    }

    currentRowIndex = rowIndex;
    for (CTableViewCellModel *row in cellModels) {
        row.sectionModel = sectionModel;
        [sectionModel.cellModels insertObject:row atIndex:currentRowIndex];
        currentRowIndex++;

        [self.c_cellModels addObject:row];
    }
    if (!self.c_isReload) {
        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)raiseExceptionWithMessage:(NSString *)message
{
    if (DEBUG) {
        @throw [NSException exceptionWithName:CTableViewManagerException
                                       reason:message
                                     userInfo:nil];
    } else {
        NSLog(@"%@", message);
    }
}

- (void)ensureSectionExists:(CTableViewSectionModel *)sectionModel
{
    if (![self.c_sectionModels containsObject:sectionModel]) {
        [self raiseExceptionWithMessage:@"Target section is not in this tableview."];
    }
}

- (void)ensureSectionNotExists:(CTableViewSectionModel *)sectionModel
{
    if ([self.c_sectionModels containsObject:sectionModel]) {
        [self raiseExceptionWithMessage:@"Table view already contains this section."];
    }
}

- (void)ensureRowExists:(CTableViewCellModel *)cellModel
{
    if (![self.c_cellModels containsObject:cellModel]) {
        [self raiseExceptionWithMessage:@"Target row is not in this tableview."];
    }
}

- (void)ensureRowNotExists:(CTableViewCellModel *)cellModel
{
    if ([self.c_cellModels containsObject:cellModel]) {
        [self raiseExceptionWithMessage:@"Table view already contains this row."];
    }
}

@end

@implementation UITableView (CTableViewHelpers)

- (NSInteger)c_numberOfSections
{
    return self.c_sectionModels.count;
}

- (NSInteger)c_numberOfRowsInSection:(NSInteger)sectionIndex
{
    CTableViewSectionModel *section = self.c_sectionModels[sectionIndex];
    return section.cellModels.count;
}

- (UITableViewCell *)c_cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *section = self.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = section.cellModels[indexPath.row];
    NSString *cellId = NSStringFromClass([cellModel cellClass]);
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[cellModel cellClass] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;

}

- (UITableViewHeaderFooterView *)c_viewForHeaderInSection:(NSInteger)sectionIndex
{
    CTableViewSectionModel *section = self.c_sectionModels[sectionIndex];
    UITableViewHeaderFooterView *view;
    if (section.headerViewModel && [section.headerViewModel headerFooterViewClass]) {
        NSString *headerId = NSStringFromClass([section.headerViewModel headerFooterViewClass]);
        [self registerClass:[section.headerViewModel headerFooterViewClass] forHeaderFooterViewReuseIdentifier:headerId];
        view = [self dequeueReusableHeaderFooterViewWithIdentifier:headerId];
        if (!view) {
            view = [[[section.headerViewModel headerFooterViewClass] alloc] initWithReuseIdentifier:headerId];
        }
        if ([view respondsToSelector:@selector(setViewModel:)]) {
            [view performSelector:@selector(setViewModel:) withObject:section.headerViewModel];
        }
    } else {
        // 防止出现白条
        view = (UITableViewHeaderFooterView *)[UIView new];
    }
    return view;
}

- (UITableViewHeaderFooterView *)c_viewForFooterInSection:(NSInteger)sectionIndex
{
    CTableViewSectionModel *section = self.c_sectionModels[sectionIndex];
    UITableViewHeaderFooterView *view;
    if (section.footerViewModel && [section.footerViewModel headerFooterViewClass]) {
        NSString *footerId = NSStringFromClass([section.footerViewModel headerFooterViewClass]);
        [self registerClass:[section.footerViewModel headerFooterViewClass] forHeaderFooterViewReuseIdentifier:footerId];
        view = [self dequeueReusableHeaderFooterViewWithIdentifier:footerId];
        if (!view) {
            view = [[[section.footerViewModel headerFooterViewClass] alloc] initWithReuseIdentifier:footerId];
        }

        if ([view respondsToSelector:@selector(setViewModel:)]) {
            [view performSelector:@selector(setViewModel:) withObject:section.footerViewModel];
        }
    } else {
        // 防止出现白条
        view = (UITableViewHeaderFooterView *)[UIView new];
    }
    return view;
}

- (CGFloat)c_heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *section = self.c_sectionModels[indexPath.section];
    CTableViewCellModel *row = section.cellModels[indexPath.row];
    if ([row respondsToSelector:@selector(cellHeight)]) {
        return [row cellHeight];
    } else {
        return self.rowHeight;
    }
}

- (CGFloat)c_heightForHeaderInSection:(NSInteger)sectionIndex
{
    CTableViewSectionModel *section = self.c_sectionModels[sectionIndex];
    if (section.headerViewModel && [section.headerViewModel respondsToSelector:@selector(headerFooterViewHeight)]) {
        return [section.headerViewModel headerFooterViewHeight];
    } else {
        if (section.headerHeight > 0) {
            return section.headerHeight;
        }
        return 0.01;
    }
}

- (CGFloat)c_heightForFooterInSection:(NSInteger)sectionIndex
{
    CTableViewSectionModel *section = self.c_sectionModels[sectionIndex];
    if (section.footerViewModel && [section.footerViewModel respondsToSelector:@selector(headerFooterViewHeight)]) {
        return [section.footerViewModel headerFooterViewHeight];
    } else {
        if (section.footerHeight > 0) {
            return section.headerHeight;
        }
        return 0.01;
    }
}

- (void)c_willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *section = self.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = section.cellModels[indexPath.row];
    cell.selectionStyle = (cellModel.cellActionEnabled && cellModel.highlightWhenTapCell) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setCellModel:)]) {
        [cell performSelector:@selector(setCellModel:) withObject:cellModel];
    }
}

- (void)c_didEndDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(didEndDisplay)]) {
        [cell performSelector:@selector(didEndDisplay)];
    }
}

- (void)c_didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTableViewSectionModel *section = self.c_sectionModels[indexPath.section];
    CTableViewCellModel *cellModel = section.cellModels[indexPath.row];
    BOOL selectionIsChanged = cellModel != self.c_selectedCellModel;
    self.c_selectedCellModel = cellModel;

    if (cellModel.cellActionEnabled) {
        if (cellModel.didSelectCellBlock) {
            cellModel.didSelectCellBlock(cellModel, selectionIsChanged);
        }
        if (self.c_didSelectCellBlock) {
            self.c_didSelectCellBlock(cellModel, selectionIsChanged);
        }
    }

    if (cellModel.autoDeselect) {
        [self deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)c_didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end

