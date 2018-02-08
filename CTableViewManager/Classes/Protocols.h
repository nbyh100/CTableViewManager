//
//  Protocols.h
//  Pods
//
//  Created by 张九州 on 2018/2/8.
//


@protocol CTableViewSectionViewModel

@required
- (Class)viewClass;

@optional
- (CGFloat)viewHeight;
- (void)willDisplay:(UITableViewHeaderFooterView *)view;
- (void)didEndDisplay:(UITableViewHeaderFooterView *)view;

@end

@protocol CTableViewSectionModel

@optional
- (id<CTableViewSectionViewModel>)headerViewModel;
- (id<CTableViewSectionViewModel>)footerViewModel;

@end

@protocol CTableViewCellModel

- (Class)cellClass;

@optional

- (CGFloat)cellHeight;
- (void)willDisplay:(UITableViewCell *)cell;
- (void)didEndDisplay:(UITableViewCell *)cell;
- (void)didSelect;
- (void)didDeselect;

@end
