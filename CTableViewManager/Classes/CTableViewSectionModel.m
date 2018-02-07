//
//  CTableViewSectionModel.m
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "CTableViewSectionModel.h"
#import <objc/runtime.h>

@interface CTableViewSectionModel ()
 
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableArray *cellModels;

@end

@implementation CTableViewSectionModel

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

@implementation CTableViewHeaderFooterModel

- (Class)headerFooterViewClass
{
    return nil;
}

- (CGFloat)headerFooterViewHeight
{
    return 0;
}

@end
