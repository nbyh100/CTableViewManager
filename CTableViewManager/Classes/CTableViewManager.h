//
//  CTableViewManager.h
//  CTableViewManager
//
//  Created by 张九州 on 16/2/26.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UITableView+CTableViewManager.h"
#import "CTableViewSectionModel.h"
#import "CTableViewCellModel.h"

/** 
 *  iOS中UITableView的代理机制实现比较繁琐，这里用更加直观的方式提供UITableView的数据，免去了实现代理和数据源的麻烦。
 *  请将此类设为UITableView的delegate和dataSource
 *  为UITableView添加数据，请参考UITableView+CTableViewManager.h
 */
@interface CTableViewManager : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<UIScrollViewDelegate> delegate;

@end

