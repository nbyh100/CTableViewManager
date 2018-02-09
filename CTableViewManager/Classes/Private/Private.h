//
//  UITableView+Private.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/7.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

void CSectionSetTableView (id<CTableViewSectionModel> sectionModel, UITableView *tableView);
void CCellSetSection (id<CTableViewCellModel> cellModel, id<CTableViewSectionModel> sectionModel);
NSMutableArray<id<CTableViewCellModel>> *CSectionGetCells (id<CTableViewSectionModel> sectionModel);

@interface UITableView (Private)

@property (nonatomic, strong) NSMutableArray *c_sectionModels;
@property (nonatomic, strong) NSMutableSet *c_cellModels;
@property (nonatomic, assign) BOOL c_isReload;
@property (nonatomic, strong, readonly) id<CTableViewSectionModel> c_defaultSection;

@end
