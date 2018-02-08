//
//  UITableView+CTableViewManager.m
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "UITableView+CTableViewManager.h"
#import <objc/runtime.h>
#import "UITableView+Private.h"
#import "Helpers.h"

@interface CTableViewDefaultSection : NSObject<CTableViewSectionModel>
@end

@implementation CTableViewDefaultSection
@end

@implementation UITableView (CTableViewManager)

#pragma mark - public

- (void)c_reloadDataWithBlock:(void (^)(void))block {
    [self.c_sectionModels removeAllObjects];
    [self.c_cellModels removeAllObjects];

    self.c_isReload = YES;
    block();
    self.c_isReload = NO;

    [self reloadData];
}

- (void)c_removeAllSections {
    [self.c_sectionModels removeAllObjects];
    [self.c_cellModels removeAllObjects];
    [self reloadData];
}

- (BOOL)c_sectionInTableView:(id<CTableViewSectionModel>)sectionModel {
    return [self.c_sectionModels containsObject:sectionModel];
}

- (BOOL)c_cellInTableView:(id<CTableViewCellModel>)cellModel {
    return [self.c_cellModels containsObject:cellModel];
}

- (NSIndexPath *)c_indexPathForCellModel:(id<CTableViewCellModel>)cellModel {
    if (!CCellGetSection(cellModel)) {
        return nil;
    }
    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:CCellGetSection(cellModel)];
    if (sectionIndex == NSNotFound) {
        return nil;
    }
    NSInteger rowIndex = [CSectionGetCells(CCellGetSection(cellModel)) indexOfObject:cellModel];
    if (rowIndex == NSNotFound) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    return indexPath;
}

- (UITableViewCell *)c_cellForCellModel:(id<CTableViewCellModel>)cellModel {
    NSIndexPath *indexPath = [self c_indexPathForCellModel:cellModel];
    if (indexPath) {
        return [self cellForRowAtIndexPath:indexPath];
    } else {
        return nil;
    }
}

- (void)c_addSection:(id<CTableViewSectionModel>)sectionModel {
    [self c_insertSection:sectionModel atIndex:self.c_sectionModels.count];
}

- (void)c_insertSection:(id<CTableViewSectionModel>)sectionModel afterSection:(id<CTableViewSectionModel>)anotherSectionModel {
    [self ensureSectionExists:anotherSectionModel];

    NSInteger index = [self.c_sectionModels indexOfObject:anotherSectionModel];
    [self c_insertSection:sectionModel atIndex:index + 1];
}

- (void)c_insertSection:(id<CTableViewSectionModel>)sectionModel beforeSection:(id<CTableViewSectionModel>)anotherSectionModel {
    [self ensureSectionExists:anotherSectionModel];

    NSInteger index = [self.c_sectionModels indexOfObject:anotherSectionModel];
    [self c_insertSection:sectionModel atIndex:index];
}

- (void)c_reloadSection:(id<CTableViewSectionModel>)sectionModel {
    [self ensureSectionExists:sectionModel];

    if (!self.c_isReload) {
        NSInteger index = [self.c_sectionModels indexOfObject:sectionModel];
        [self reloadSections:[NSIndexSet indexSetWithIndex:index]
            withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_deleteSection:(id<CTableViewSectionModel>)sectionModel {
    [self ensureSectionExists:sectionModel];

    NSInteger index = [self.c_sectionModels indexOfObject:sectionModel];
    [self.c_sectionModels removeObjectAtIndex:index];
    CSectionSetTableView(sectionModel, nil);

    for (id<CTableViewCellModel> cellModel in CSectionGetCells(sectionModel)) {
        [self.c_cellModels removeObject:cellModel];
        CCellSetSection(cellModel, nil);
    }

    if (!self.c_isReload) {
        [self deleteSections:[NSIndexSet indexSetWithIndex:index]
            withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_addCell:(id<CTableViewCellModel>)cellModel {
    [self c_addCell:cellModel inSection:self.c_defaultSection];
}

- (void)c_addCells:(NSArray<id<CTableViewCellModel>> *)cellModels {
    [self c_addCells:cellModels inSection:self.c_defaultSection];
}

- (void)c_insertCell:(id<CTableViewCellModel>)cellModel afterCell:(id<CTableViewCellModel>)anotherCellModel {
    [self c_insertCell:cellModel afterCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_insertCells:(NSArray<id<CTableViewCellModel>> *)cellModels afterCell:(id<CTableViewCellModel>)anotherCellModel {
    [self c_insertCells:cellModels afterCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_insertCell:(id<CTableViewCellModel>)cellModel beforeCell:(id<CTableViewCellModel>)anotherCellModel {
    [self c_insertCell:cellModel beforeCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_insertCells:(NSArray<id<CTableViewCellModel>> *)cellModels beforeCell:(id<CTableViewCellModel>)anotherCellModel {
    [self c_insertCells:cellModels beforeCell:anotherCellModel inSection:self.c_defaultSection];
}

- (void)c_addCell:(id<CTableViewCellModel>)cellModel inSection:(id<CTableViewSectionModel>)sectionModel {
    [self c_addCells:@[cellModel] inSection:sectionModel];
}

- (void)c_addCells:(NSArray<id<CTableViewCellModel>> *)cellModels inSection:(id<CTableViewSectionModel>)sectionModel {
    [self c_insertCells:cellModels atIndex:CSectionGetCells(sectionModel).count inSection:sectionModel];
}

- (void)c_insertCell:(id<CTableViewCellModel>)cellModel afterCell:(id<CTableViewCellModel>)anotherCellModel inSection:(id<CTableViewSectionModel>)sectionModel {
    [self c_insertCells:@[cellModel] afterCell:anotherCellModel inSection:sectionModel];
}

- (void)c_insertCells:(NSArray<id<CTableViewCellModel>> *)cellModels afterCell:(id<CTableViewCellModel>)anotherCellModel inSection:(id<CTableViewSectionModel>)sectionModel {
    [self ensureRowExists:anotherCellModel];

    NSInteger index = [CSectionGetCells(sectionModel) indexOfObject:anotherCellModel];
    [self c_insertCells:cellModels atIndex:index + 1 inSection:sectionModel];
}

- (void)c_insertCell:(id<CTableViewCellModel>)cellModel beforeCell:(id<CTableViewCellModel>)anotherCellModel inSection:(id<CTableViewSectionModel>)sectionModel {
    [self c_insertCells:@[cellModel] beforeCell:anotherCellModel inSection:sectionModel];
}

- (void)c_insertCells:(NSArray<id<CTableViewCellModel>> *)cellModels beforeCell:(id<CTableViewCellModel>)anotherCellModel inSection:(id<CTableViewSectionModel>)sectionModel {
    [self ensureRowExists:anotherCellModel];

    NSInteger index = [CSectionGetCells(sectionModel) indexOfObject:anotherCellModel];
    [self c_insertCells:cellModels atIndex:index inSection:sectionModel];
}

- (void)c_reloadCell:(id<CTableViewCellModel> )cellModel {
    [self c_reloadCells:@[cellModel]];
}

- (void)c_reloadCells:(NSArray<id<CTableViewCellModel>> *)cellModels {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (id<CTableViewCellModel> cellModel in cellModels) {
        [self ensureRowExists:cellModel];

        NSInteger sectionIndex = [self.c_sectionModels indexOfObject:CCellGetSection(cellModel)];
        NSInteger rowIndex = [CSectionGetCells(CCellGetSection(cellModel)) indexOfObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        [indexPaths addObject:indexPath];
    }

    if (!self.c_isReload) {
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_deleteCell:(id<CTableViewCellModel>)cellModel {
    [self c_deleteCells:@[cellModel]];
}

- (void)c_deleteCells:(NSArray<id<CTableViewCellModel>> *)cellModels {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (id<CTableViewCellModel> cellModel in cellModels) {
        [self ensureRowExists:cellModel];

        NSInteger sectionIndex = [self.c_sectionModels indexOfObject:CCellGetSection(cellModel)];
        NSInteger rowIndex = [CSectionGetCells(CCellGetSection(cellModel)) indexOfObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        [indexPaths addObject:indexPath];

        [self.c_cellModels removeObject:cellModel];
    }

    for (id<CTableViewCellModel> cellModel in cellModels) {
        [CSectionGetCells(CCellGetSection(cellModel)) removeObject:cellModel];
        CCellSetSection(cellModel, nil);
    }
    if (!self.c_isReload) {
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)c_selectCell:(id<CTableViewCellModel>)cellModel {
    [self ensureRowExists:cellModel];

    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:CCellGetSection(cellModel)];
    NSInteger rowIndex = [CSectionGetCells(CCellGetSection(cellModel)) indexOfObject:cellModel];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    [self selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)c_deselectCell:(id<CTableViewCellModel>)cellModel {
    [self ensureRowExists:cellModel];

    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:CCellGetSection(cellModel)];
    NSInteger rowIndex = [CSectionGetCells(CCellGetSection(cellModel)) indexOfObject:cellModel];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    [self deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private properties

- (NSMutableArray *)c_sectionModels {
    NSMutableArray *sections = objc_getAssociatedObject(self, @selector(c_sectionModels));
    if (!sections) {
        sections = [NSMutableArray array];
        objc_setAssociatedObject(self, @selector(c_sectionModels), sections, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return sections;
}

- (NSMutableSet *)c_cellModels {
    NSMutableSet *cellModels = objc_getAssociatedObject(self, @selector(c_cellModels));
    if (!cellModels) {
        cellModels = [NSMutableSet set];
        objc_setAssociatedObject(self, @selector(c_cellModels), cellModels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cellModels;
}

- (void)setC_isReload:(BOOL)c_isReload {
    objc_setAssociatedObject(self, @selector(c_isReload), @(c_isReload), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)c_isReload {
    return [objc_getAssociatedObject(self, @selector(c_isReload)) boolValue];
}

- (id<CTableViewSectionModel>)c_defaultSection {
    if (self.c_sectionModels.count <= 0) {
        id<CTableViewSectionModel>sectionModel = [CTableViewDefaultSection new];
        [self c_addSection:sectionModel];
    }
    return self.c_sectionModels.firstObject;
}

#pragma mark - private

- (void)c_insertSection:(id<CTableViewSectionModel>)sectionModel atIndex:(NSInteger)index; {
    [self ensureSectionNotExists:sectionModel];

    CSectionSetTableView(sectionModel, self);
    [CSectionGetCells(sectionModel) removeAllObjects];
    [self.c_sectionModels insertObject:sectionModel atIndex:index];

    if (!self.c_isReload) {
        // tableview可能会自带一个section，这通常发生在viewDidLoad之后。而viewDidLoad之前不会出现那个自带的section。
        if (!(self.c_sectionModels.count == 1 && self.numberOfSections == 1)) {
            [self insertSections:[NSIndexSet indexSetWithIndex:index]
                withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)c_insertCells:(NSArray<id<CTableViewCellModel>> *)cellModels atIndex:(NSInteger)rowIndex inSection:(id<CTableViewSectionModel>)sectionModel {
    [self ensureSectionExists:sectionModel];

    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    NSInteger sectionIndex = [self.c_sectionModels indexOfObject:sectionModel];
    NSInteger currentRowIndex = rowIndex;
    for (id<CTableViewCellModel> row in cellModels) {
        if ([self.c_cellModels containsObject:row]) {
            @throw [NSException exceptionWithName:CTableViewManagerException reason:@"Table view already contains this row." userInfo:nil];
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRowIndex inSection:sectionIndex];
        [indexPaths addObject:indexPath];
        currentRowIndex++;
    }

    currentRowIndex = rowIndex;
    for (id<CTableViewCellModel> cellModel in cellModels) {
        CCellSetSection(cellModel, sectionModel);
        [CSectionGetCells(sectionModel) insertObject:cellModel atIndex:currentRowIndex];
        currentRowIndex++;

        [self.c_cellModels addObject:cellModel];
    }
    if (!self.c_isReload) {
        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)raiseExceptionWithMessage:(NSString *)message {
#if DEBUG
    @throw [NSException exceptionWithName:CTableViewManagerException
                                   reason:message
                                 userInfo:nil];
#else
    NSLog(@"%@", message);
#endif
}

- (void)ensureSectionExists:(id<CTableViewSectionModel>)sectionModel {
    if (![self.c_sectionModels containsObject:sectionModel]) {
        [self raiseExceptionWithMessage:@"Target section is not in this tableview."];
    }
}

- (void)ensureSectionNotExists:(id<CTableViewSectionModel>)sectionModel {
    if ([self.c_sectionModels containsObject:sectionModel]) {
        [self raiseExceptionWithMessage:@"Table view already contains this section."];
    }
}

- (void)ensureRowExists:(id<CTableViewCellModel>)cellModel {
    if (![self.c_cellModels containsObject:cellModel]) {
        [self raiseExceptionWithMessage:@"Target row is not in this tableview."];
    }
}

- (void)ensureRowNotExists:(id<CTableViewCellModel>)cellModel {
    if ([self.c_cellModels containsObject:cellModel]) {
        [self raiseExceptionWithMessage:@"Table view already contains this row."];
    }
}

@end
