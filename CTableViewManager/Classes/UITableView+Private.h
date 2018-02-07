//
//  UITableView+Private.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/7.
//

#import <UIKit/UIKit.h>
#import "CTableViewSectionModel.h"
#import "CTableViewCellModel.h"

@interface UITableView (Private)

@property (nonatomic, strong) NSMutableArray *c_sectionModels;
@property (nonatomic, strong) NSMutableSet *c_cellModels;
@property (nonatomic, assign) BOOL c_isReload;
@property (nonatomic, strong, readonly) CTableViewSectionModel *c_defaultSection;
@property (nonatomic, strong) CTableViewCellModel *c_selectedCellModel;

@end

@interface CTableViewSectionModel (Private)

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableArray *cellModels;

@end

@interface CTableViewCellModel (Private)

@property (nonatomic, weak) CTableViewSectionModel *sectionModel;

@end
