# CTableViewManager

UITableView管理工具，使用面向对象的方式替代直接使用数据源和代理。

## Example

```objective-c
self.manager = [CTableViewManager new];
self.tableView.dataSource = self.manager;
self.tableView.delegate = self.manager;

[self.tableView c_reloadDataWithBlock:^{
    MyCellModel *cellModel = [MyCellModel new];
    cellModel.title = @"My Title 1";
    [self.tableView c_addCell:cellModel];

    MyCellModel *cellModel2 = [MyCellModel new];
    cellModel2.title = @"My Title 2";
    [self.tableView c_addCell:cellModel2];
}];
```
