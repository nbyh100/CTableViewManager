# CTableViewManager

UITableView管理工具，代替dataSource和delegate。

## 特性
* 面向对象
* 数据驱动
* 行高缓存
* 自动计算autolayout
* 静默刷新（不调用reloadRowsAtIndexPaths）

## 示例

```objective-c
self.manager = [[CTableViewManager alloc] initWithTableView:self.tableView];
[self.manager performReloadBlock:^{
    CTableViewSectionManager *sm = [self.manager addSectionWithID:@"default"];
    for (NSInteger i = 0; i < 10; i++) {
        CSimpleCellPayload *p = [CSimpleCellPayload new];
        p.title = [NSString stringWithFormat:@"Title %ld", i];
        [sm addCellWithID:[NSString stringWithFormat:@"cell%ld", i] payload:p];
    }
}];

// 不会触发reloadCell
CTableViewSectionManager *sm = [self.manager sectionWithID:@"default"];
[sm refreshCellWithID:@"cell2" block:^NSObject<ITableViewCellPayload> * _Nonnull(NSObject<ITableViewCellPayload> *_Nonnull data) {
    CSimpleCellPayload *p = [(NSObject *)data copy];
    p.title = @"updated";
    return p;
}];
```

## Cell数据协议
```objective-c
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
```
