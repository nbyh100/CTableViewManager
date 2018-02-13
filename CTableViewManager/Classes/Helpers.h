//
//  Helpers.h
//  Pods
//
//  Created by 张九州 on 2018/2/8.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

UITableView *CSectionGetTableView (id<CTableViewSectionModel> sectionModel);
UITableView *CCellGetTableView (id<CTableViewCellModel> cellModel);
id<CTableViewSectionModel> CCellGetSection (id<CTableViewCellModel> cellModel);

NSString *CSectionGetID (id<CTableViewSectionModel> sectionModel);
void CSectionSetID (id<CTableViewSectionModel> sectionModel, NSString *sectionID);
NSString *CCellGetID (id<CTableViewCellModel> cellModel);
void CCellSetID (id<CTableViewCellModel> cellModel, NSString *cellID);

