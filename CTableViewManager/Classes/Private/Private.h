//
//  Private.h
//  Pods
//
//  Created by 张九州 on 2018/2/13.
//

@class CTableViewSectionManager;

@interface CTableViewSectionManager (Private)

@property (nonatomic, strong) NSMutableArray<CTableViewCellData *> *cells;
@property (nonatomic, copy) void (^didSelectCell)(NSInteger index, BOOL animated, UITableViewScrollPosition scrollPosition);
@property (nonatomic, copy) void (^didDeselectCell)(NSInteger index, BOOL animated);

@end

@interface CTableViewCellData (Private)

@property (nonatomic, assign) BOOL isRefresh;

@end
