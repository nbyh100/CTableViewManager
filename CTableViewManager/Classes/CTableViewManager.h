//
//  CTableViewManager.h
//  CTableViewManager
//
//  Created by 张九州 on 16/2/26.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "Helpers.h"
#import "UITableView+CTableViewManager.h"

@interface CTableViewManager : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<UIScrollViewDelegate> delegate;

@end
