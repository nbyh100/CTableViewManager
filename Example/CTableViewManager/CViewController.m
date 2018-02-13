//
//  CViewController.m
//  CTableViewManager
//
//  Created by nbyh100@sina.com on 02/11/2018.
//  Copyright (c) 2018 nbyh100@sina.com. All rights reserved.
//

#import "CViewController.h"
#import <CTableViewManager/CTableViewManager.h>

@interface CSimpleCellPayload : NSObject<ITableViewCellPayload>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL selected;

@end

@implementation CSimpleCellPayload

@synthesize sectionManager;
@synthesize cellData;

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    CSimpleCellPayload *payload = [[self class] new];
    payload.title = self.title;
    payload.selected = self.selected;
    return payload;
}

- (Class)cellClass {
    return [UITableViewCell class];
}

- (CGFloat)cellHeight {
    return 100;
}

- (void)willDisplay:(UITableViewCell *)cell {
}

- (void)refresh:(UITableViewCell *)cell {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.title;
    if (cell.selected) {
        cell.backgroundColor = [UIColor yellowColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (void)didEndDisplaying:(UITableViewCell *)cell {
}

- (void)didSelect {
    [self.sectionManager refreshCellWithID:self.cellData.cellID block:^NSObject<ITableViewCellPayload> * _Nonnull(NSObject<ITableViewCellPayload> * _Nonnull payload) {
        CSimpleCellPayload *myPayload = (CSimpleCellPayload *)payload;
        myPayload.selected = YES;
        return myPayload;
    }];
}

- (void)didDeselect {
    [self.sectionManager refreshCellWithID:self.cellData.cellID block:^NSObject<ITableViewCellPayload> * _Nonnull(NSObject<ITableViewCellPayload> * _Nonnull payload) {
        CSimpleCellPayload *myPayload = (CSimpleCellPayload *)payload;
        myPayload.selected = NO;
        return myPayload;
    }];
}

@end

@interface CViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) CTableViewManager *manager;

@end

@implementation CViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;

    self.manager = [[CTableViewManager alloc] initWithTableView:self.tableView];
    self.manager.enableCellHeightCache = YES;
    [self.manager performReloadBlock:^{
        CTableViewSectionManager *sm = [self.manager addSectionWithID:@"default"];
        for (NSInteger i = 0; i < 10; i++) {
            CSimpleCellPayload *p = [CSimpleCellPayload new];
            p.title = [NSString stringWithFormat:@"Title %ld", i];
            [sm addCellWithID:[NSString stringWithFormat:@"cell%ld", i] payload:p];
        }
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CTableViewSectionManager *sm = [self.manager sectionWithID:@"default"];
        [sm refreshCellWithID:@"cell2" block:^NSObject<ITableViewCellPayload> * _Nonnull(NSObject<ITableViewCellPayload> *_Nonnull data) {
            CSimpleCellPayload *p = [(NSObject *)data copy];
            p.title = @"updated";
            return p;
        }];
    });
}

- (void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}

@end

