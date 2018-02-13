# CTableViewManager

UITableView管理工具，使用面向对象、数据驱动UI的方式。

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
