//
//  CViewController.m
//  CTableViewManager
//
//  Created by nbyh100@sina.com on 12/22/2017.
//  Copyright (c) 2017 nbyh100@sina.com. All rights reserved.
//

#import "CViewController.h"
#import <CTableViewManager/CTableViewManager.h>

@interface MyCellModel : NSObject<CTableViewCellModel>

@property (nonatomic, strong) NSString *title;

@end

@implementation MyCellModel

- (Class)cellClass {
    return [UITableViewCell class];
}

- (CGFloat)cellHeight {
    return 40;
}

- (void)willDisplay:(UITableViewCell *)cell {
    cell.textLabel.text = self.title;
}

- (void)didSelect {
    [CCellGetTableView(self) c_deselectCell:self];
}

@end

@interface CViewController ()

@property (nonatomic, strong) CTableViewManager *manager;

@end

@implementation CViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.manager = [CTableViewManager new];
    self.tableView.dataSource = self.manager;
    self.tableView.delegate = self.manager;

    [self.tableView c_reloadDataWithBlock:^{
        MyCellModel *cellModel = [MyCellModel new];
        cellModel.title = @"My Title 1";
        [self.tableView c_addCell:cellModel];

        MyCellModel *cellModel2 = [MyCellModel new];
        cellModel2.title = @"My Title 2";
        [self.tableView c_addCell:cellModel2];
    }];
}

@end
