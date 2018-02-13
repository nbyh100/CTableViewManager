//
//  Protocols.h
//  Pods
//
//  Created by 张九州 on 2018/2/11.
//

@class CTableViewSectionManager;
@class CTableViewCellData;

@protocol ITableViewCellPayload <NSCopying>

- (Class)cellClass;

@optional

@property (nonatomic, weak) CTableViewSectionManager *sectionManager;
@property (nonatomic, weak) CTableViewCellData *cellData;

- (CGFloat)cellHeight;
- (void)willDisplay:(UITableViewCell *)cell;
- (void)refresh:(UITableViewCell *)cell;
- (void)didEndDisplaying:(UITableViewCell *)cell;
- (void)didSelect;
- (void)didDeselect;

@end
