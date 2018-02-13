//
//  CViewController.m
//  CTableViewManager
//
//  Created by nbyh100@sina.com on 12/22/2017.
//  Copyright (c) 2017 nbyh100@sina.com. All rights reserved.
//

#import "CViewController.h"
#import <CTableViewManager/CTableViewManager.h>
#import <Masonry/Masonry.h>

@interface CAutoLayoutCell : UITableViewCell

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *detailLabel;

@end

@implementation CAutoLayoutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
        titleLabel.numberOfLines = 2;
        titleLabel.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 32;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        UILabel *detailLabel = [UILabel new];
        detailLabel.font = [UIFont systemFontOfSize:14];
        detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
        detailLabel.numberOfLines = 0;
        detailLabel.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 32;
        [self.contentView addSubview:detailLabel];
        self.detailLabel = detailLabel;

        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
        }];
        [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(5);
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return self;
}

@end

@interface CAutoLayoutCellModel : NSObject<CTableViewCellModel>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@end

@implementation CAutoLayoutCellModel

- (Class)cellClass {
    return [CAutoLayoutCell class];
}

- (CGFloat)cellHeight {
    return UITableViewAutomaticDimension;
}

- (void)willDisplay:(CAutoLayoutCell *)cell {
    cell.titleLabel.text = self.title;
    cell.detailLabel.text = self.detail;
}

- (void)didSelect {
    [CCellGetTableView(self) c_deselectCell:self];
}

@end

@interface CButtonCell : UITableViewCell

@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation CButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
        }];
        self.titleLabel = titleLabel;
    }
    return self;
}

@end

@interface CButtonCellModel : NSObject<CTableViewCellModel>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) void (^didSelectAction)(void);

@end

@implementation CButtonCellModel

- (Class)cellClass {
    return [CButtonCell class];
}

- (CGFloat)cellHeight {
    return 44;
}

- (void)willDisplay:(CButtonCell *)cell {
    cell.titleLabel.text = self.title;
}

- (void)didSelect {
    if (self.didSelectAction) {
        self.didSelectAction();
    }
}

@end

@interface CViewController ()

@property (nonatomic, strong) CTableViewManager *manager;

@end

@implementation CViewController

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.manager = [CTableViewManager new];
    self.tableView.dataSource = self.manager;
    self.tableView.delegate = self.manager;

    __block NSInteger i = 3;
    __block id lastCellModel;

    [self.tableView c_reloadDataWithBlock:^{
        CAutoLayoutCellModel *cellModel1 = [CAutoLayoutCellModel new];
        cellModel1.title = @"My Title 1";
        cellModel1.detail = @"A short text.";
        [self.tableView c_addCell:cellModel1];

        CAutoLayoutCellModel *cellModel2 = [CAutoLayoutCellModel new];
        cellModel2.title = @"My Title 2";
        cellModel2.detail = @"A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. A very long text. ";
        [self.tableView c_addCell:cellModel2];

        lastCellModel = cellModel2;

        CButtonCellModel *buttonCellModel = [CButtonCellModel new];
        buttonCellModel.title = @"增加一行";
        buttonCellModel.didSelectAction = ^{
            CAutoLayoutCellModel *cellModel = [CAutoLayoutCellModel new];
            cellModel.title = [NSString stringWithFormat:@"My Title %ld", i];
            cellModel.detail = [NSString stringWithFormat:@"Detail text %ld", i];
            [self.tableView c_insertCell:cellModel afterCell:lastCellModel];
            lastCellModel = cellModel;
            i++;
        };
        [self.tableView c_addCell:buttonCellModel];
    }];
}

@end
