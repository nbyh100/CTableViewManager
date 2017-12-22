//
//  CTableViewSectionModel.m
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "CTableViewSectionModel.h"

@interface CTableViewSectionModel ()
 
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation CTableViewSectionModel

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
