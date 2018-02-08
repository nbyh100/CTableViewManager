//
//  Helpers.m
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/8.
//

#import "Helpers.h"
#import <objc/runtime.h>

UITableView *CSectionGetTableView (id<CTableViewSectionModel> sectionModel) {
    return objc_getAssociatedObject(sectionModel, CSectionGetTableView);
}

void CSectionSetTableView (id<CTableViewSectionModel> sectionModel, UITableView *tableView) {
    objc_setAssociatedObject(sectionModel, CSectionGetTableView, tableView, OBJC_ASSOCIATION_ASSIGN);
}

id<CTableViewSectionModel> CCellGetSection (id<CTableViewCellModel> cellModel) {
    return objc_getAssociatedObject(cellModel, CCellGetSection);
}

void CCellSetSection (id<CTableViewCellModel> cellModel, id<CTableViewSectionModel> sectionModel) {
    objc_setAssociatedObject(cellModel, CCellGetSection, sectionModel, OBJC_ASSOCIATION_ASSIGN);
}

UITableView *CCellGetTableView (id<CTableViewCellModel> cellModel) {
    if (CCellGetSection(cellModel)) {
        return CSectionGetTableView(CCellGetSection(cellModel));
    }
    return nil;
}

NSMutableArray<id<CTableViewCellModel>> *CSectionGetCells (id<CTableViewSectionModel> sectionModel) {
    NSMutableArray *cells;
    cells = objc_getAssociatedObject(sectionModel, CSectionGetCells);
    if (!cells) {
        cells = [NSMutableArray array];
        objc_setAssociatedObject(sectionModel, CSectionGetCells, cells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cells;
}
