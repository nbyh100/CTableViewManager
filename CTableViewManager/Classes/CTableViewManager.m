//
//  CTableViewManager.m
//  CTableViewManager
//
//  Created by 张九州 on 16/2/26.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "CTableViewManager.h"

@interface UITableView (CTableViewHelpers)
 
- (NSInteger)c_numberOfSections;
- (NSInteger)c_numberOfRowsInSection:(NSInteger)sectionIndex;

- (UITableViewCell *)c_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewHeaderFooterView *)c_viewForHeaderInSection:(NSInteger)sectionIndex;
- (UITableViewHeaderFooterView *)c_viewForFooterInSection:(NSInteger)sectionIndex;

- (CGFloat)c_heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)c_heightForHeaderInSection:(NSInteger)sectionIndex;
- (CGFloat)c_heightForFooterInSection:(NSInteger)sectionIndex;

- (void)c_willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)c_didEndDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)c_didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)c_didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation CTableViewManager

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableView c_numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableView c_numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView c_cellForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [tableView c_viewForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [tableView c_viewForFooterInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView c_heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [tableView c_heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [tableView c_heightForFooterInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView c_willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView c_didEndDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView c_didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView c_didDeselectRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

@end
