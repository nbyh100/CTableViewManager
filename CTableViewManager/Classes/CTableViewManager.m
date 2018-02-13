//
//  CTableViewManager.m
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import "CTableViewManager.h"
#import <objc/runtime.h>
#import "CKVOObserver.h"
#import "CTableViewManagerHelper.h"
#import "Private.h"

@interface CTableViewManager ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CTableViewSectionManager *> *sections;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CTableViewSectionManager *> *sectionsByID;
@property (nonatomic, assign) BOOL reload;
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;

@end

@implementation CTableViewManager

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _tableView = tableView;
        _tableView.dataSource = (id<UITableViewDataSource>)self;
        _tableView.delegate = (id<UITableViewDelegate>)self;
        _enableCellHeightCache = NO;
        _sections = [NSMutableArray array];
        _sectionsByID = [NSMutableDictionary dictionary];
        _reload = NO;
        _rowAnimation = UITableViewRowAnimationNone;

        [self _addSectionObserver];
    }
    return self;
}

- (void)performReloadBlock:(void (^)(void))block {
    self.reload = YES;
    block();
    self.reload = NO;
    [self.tableView reloadData];
}

- (void)performUpdateBlock:(void (^)(void))block animation:(UITableViewRowAnimation)animation {
    self.rowAnimation = animation;
    block();
    self.rowAnimation = UITableViewRowAnimationNone;
}

- (NSInteger)indexForSectionID:(NSString *)sectionID {
    CTableViewSectionManager *sectionManager = [self _section:sectionID];
    return [self.sections indexOfObject:sectionManager];
}

- (NSString *)sectionIDForIndex:(NSInteger)index {
    if (index >= self.sections.count || index < 0) {
        [CTableViewManagerHelper raiseException:[NSString stringWithFormat:@"Invalid section index %ld", (long)index] userInfo:nil];
    }
    return self.sections[index].sectionID;
}

- (NSString *)cellIDForIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionID = [self sectionIDForIndex:indexPath.section];
    CTableViewSectionManager *sectionManager = self.sectionsByID[sectionID];
    return [sectionManager cellIDForIndex:indexPath.row];
}

- (BOOL)sectionExistsWithID:(NSString *)sectionID {
    return !!self.sectionsByID[sectionID];
}

- (CTableViewSectionManager *)sectionWithID:(NSString *)sectionID {
    return [self _section:sectionID];
}

- (CTableViewSectionManager *)addSectionWithID:(NSString *)sectionID {
    return [self _insertSection:sectionID atIndex:self.sections.count];
}

- (CTableViewSectionManager *)insertSectionWithID:(NSString *)sectionID beforeSectionWithID:(NSString *)anotherSectionID {
    CTableViewSectionManager *anothersectionManager = [self _section:anotherSectionID];
    NSInteger pos = [self.sections indexOfObject:anothersectionManager];

    return [self _insertSection:sectionID atIndex:pos];
}

- (CTableViewSectionManager *)insertSectionWithID:(NSString *)sectionID afterSectionWithID:(NSString *)anotherSectionID {
    CTableViewSectionManager *anothersectionManager = [self _section:anotherSectionID];
    NSInteger pos = [self.sections indexOfObject:anothersectionManager];

    return [self _insertSection:sectionID atIndex:pos + 1];
}

- (void)deleteSectionWithID:(NSString *)sectionID {
    [self _deleteSection:sectionID];
}

- (NSMutableArray *)_sectionsArray {
    return [self mutableArrayValueForKey:@"sections"];
}

- (CTableViewSectionManager *)_section:(NSString *)sectionID {
    CTableViewSectionManager *sectionManager = self.sectionsByID[sectionID];
    if (!sectionManager) {
        [CTableViewManagerHelper raiseException:
         [NSString stringWithFormat:@"Invalid sectionID %@.", sectionID] userInfo:nil];
    }
    return sectionManager;
}

- (CTableViewSectionManager *)_insertSection:(nonnull NSString *)sectionID atIndex:(NSInteger)index {
    if (self.sectionsByID[sectionID]) {
        [CTableViewManagerHelper raiseException:
         [NSString stringWithFormat:@"Duplicated sectionID %@.", sectionID] userInfo:nil];
    }

    CTableViewSectionManager *sectionManager = [CTableViewSectionManager sectionManager:sectionID tableViewManager:self];
    [[self _sectionsArray] insertObject:sectionManager atIndex:index];
    self.sectionsByID[sectionID] = sectionManager;

    [self _addCellObserver:sectionManager];
    return sectionManager;
}

- (void)_deleteSection:(NSString *)sectionID {
    CTableViewSectionManager *sectionManager = [self _section:sectionID];
    [[self _sectionsArray] removeObject:sectionManager];
    [self.sectionsByID removeObjectForKey:sectionID];

    [self _removeCellObserver:sectionManager];
}

- (void)_addSectionObserver {
    __weak typeof(self) wSelf = self;
    [CKVOObserver observe:self keyPath:@"sections" handler:^(NSObject * _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change, void * _Nullable context) {
        __strong typeof(self) sSelf = wSelf;

        if (!sSelf.reload) {
            NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] integerValue];
            NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];

            if (kind == NSKeyValueChangeInsertion) {
                [sSelf.tableView insertSections:indexes withRowAnimation:sSelf.rowAnimation];
            } else if (kind == NSKeyValueChangeReplacement) {
                [sSelf.tableView reloadSections:indexes withRowAnimation:sSelf.rowAnimation];
            } else if (kind == NSKeyValueChangeRemoval) {
                [sSelf.tableView deleteSections:indexes withRowAnimation:sSelf.rowAnimation];
            }
        }
    } options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)_addCellObserver:(CTableViewSectionManager *)sectionManager {
    __weak typeof(self) wSelf = self;

    [CKVOObserver observe:sectionManager keyPath:@"cells" handler:^(NSObject * _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change, void * _Nullable context) {
        __strong typeof(self) sSelf = wSelf;

        if (!sSelf.reload) {
            NSInteger sectionIndex = [sSelf.sections indexOfObject:sectionManager];
            NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
            NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];

            NSMutableArray *indexPaths = [NSMutableArray array];
            [indexes enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
            }];

            if (kind == NSKeyValueChangeInsertion) {
                [sSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:sSelf.rowAnimation];
            } else if (kind == NSKeyValueChangeReplacement) {
                NSMutableArray *reloadIndexPaths = [NSMutableArray array];
                for (NSIndexPath *indexPath in indexPaths) {
                    CTableViewSectionManager *sectionManager = self.sections[indexPath.section];
                    CTableViewCellData *cellData = sectionManager.cells[indexPath.row];

                    if (cellData.isRefresh) {
                        NSObject<ITableViewCellPayload> *payload = cellData.payload;
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        if (cell && [payload respondsToSelector:@selector(refresh:)]) {
                            [payload refresh:cell];
                        }
                    } else {
                        [reloadIndexPaths addObject:indexPath];
                    }
                }
                [sSelf.tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:sSelf.rowAnimation];
            } else if (kind == NSKeyValueChangeRemoval) {
                [sSelf.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:sSelf.rowAnimation];
            }
        }
    } options:NSKeyValueObservingOptionNew context:NULL];

    __weak CTableViewSectionManager *wsectionManager = sectionManager;

    sectionManager.didSelectCell = ^(NSInteger index, BOOL animated, UITableViewScrollPosition scrollPosition) {
        __strong typeof(self) sSelf = wSelf;
        __strong CTableViewSectionManager *ssectionManager = wsectionManager;

        if (!sSelf.tableView.allowsMultipleSelection) {
            NSIndexPath *selectedIndexPath = sSelf.tableView.indexPathForSelectedRow;
            if (selectedIndexPath) {
                [(id<UITableViewDelegate>)sSelf tableView:sSelf.tableView didDeselectRowAtIndexPath:selectedIndexPath];
            }
        }

        NSInteger sectionIndex = [sSelf.sections indexOfObject:ssectionManager];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
        [sSelf.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
        [(id<UITableViewDelegate>)sSelf tableView:sSelf.tableView didSelectRowAtIndexPath:indexPath];
    };

    sectionManager.didDeselectCell = ^(NSInteger index, BOOL animated) {
        __strong typeof(self) sSelf = wSelf;
        __strong CTableViewSectionManager *ssectionManager = wsectionManager;

        NSInteger sectionIndex = [sSelf.sections indexOfObject:ssectionManager];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
        [sSelf.tableView deselectRowAtIndexPath:indexPath animated:animated];
        [(id<UITableViewDelegate>)sSelf tableView:sSelf.tableView didDeselectRowAtIndexPath:indexPath];
    };
}

- (void)_removeCellObserver:(CTableViewSectionManager *)sectionManager {
    [CKVOObserver remove:sectionManager keyPath:@"cells"];
    sectionManager.didSelectCell = nil;
    sectionManager.didDeselectCell = nil;
}

@end

@interface CTableViewManager (UITableViewDataSource) <UITableViewDataSource>
@end

@implementation CTableViewManager (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CTableViewSectionManager *sectionManager = self.sections[section];
    return sectionManager.cells.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTableViewSectionManager *sectionManager = self.sections[indexPath.section];
    CTableViewCellData *cellData = sectionManager.cells[indexPath.row];
    NSObject<ITableViewCellPayload> *payload = cellData.payload;

    Class cellClass = [payload cellClass];
    NSString *reuseID = NSStringFromClass(cellClass);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }

    return cell;
}

@end

static NSMutableDictionary *tmpCells;
static char payloadKey;

@interface CTableViewManager (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation CTableViewManager (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CTableViewSectionManager *sectionManager = self.sections[indexPath.section];
    CTableViewCellData *cellData = sectionManager.cells[indexPath.row];
    NSObject<ITableViewCellPayload> *payload = cellData.payload;
    objc_setAssociatedObject(cell, &payloadKey, payload, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ([payload respondsToSelector:@selector(willDisplay:)]) {
        [payload willDisplay:cell];
    }
    if ([payload respondsToSelector:@selector(refresh:)]) {
        [payload refresh:cell];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 当cell被移除时后，不能通过indexPath获取对应的payload，只能通过暂存的方式
    NSObject<ITableViewCellPayload> *payload = (NSObject<ITableViewCellPayload> *)objc_getAssociatedObject(cell, &payloadKey);
    objc_setAssociatedObject(cell, &payloadKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (payload && [payload respondsToSelector:@selector(didEndDisplaying:)]) {
        [payload didEndDisplaying:cell];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTableViewSectionManager *sectionManager = self.sections[indexPath.section];
    CTableViewCellData *cellData = sectionManager.cells[indexPath.row];
    NSObject<ITableViewCellPayload> *payload = cellData.payload;

    if (![payload respondsToSelector:@selector(cellHeight)]) {
        return tableView.rowHeight;
    }

    if (self.enableCellHeightCache) {
        NSNumber *height = [sectionManager cellHeightCacheWithID:cellData.cellID];
        if (height) {
            return [height floatValue];
        }
    }

    CGFloat cellHeight = [payload cellHeight];
    if (cellHeight == UITableViewAutomaticDimension) {
        if (!tmpCells) {
            tmpCells = [NSMutableDictionary dictionary];
        }
        Class cellClass = [payload cellClass];
        NSString *reuseID = NSStringFromClass(cellClass);
        UITableViewCell *tmpCell = tmpCells[reuseID];
        if (!tmpCell) {
            tmpCell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            tmpCells[reuseID] = tmpCell;
        }

        if ([payload respondsToSelector:@selector(refresh:)]) {
            [payload refresh:tmpCell];
        }
        CGSize size = [tmpCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        cellHeight = size.height + 1.0 / [UIScreen mainScreen].scale;
    }

    if (self.enableCellHeightCache) {
        [sectionManager setCellHeightCache:@(cellHeight) withID:cellData.cellID];
    }

    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CTableViewSectionManager *sectionManager = self.sections[indexPath.section];
    CTableViewCellData *cellData = sectionManager.cells[indexPath.row];
    NSObject<ITableViewCellPayload> *payload = cellData.payload;

    if ([payload respondsToSelector:@selector(didSelect)]) {
        [payload didSelect];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CTableViewSectionManager *sectionManager = self.sections[indexPath.section];
    CTableViewCellData *cellData = sectionManager.cells[indexPath.row];
    NSObject<ITableViewCellPayload> *payload = cellData.payload;

    if ([payload respondsToSelector:@selector(didDeselect)]) {
        [payload didDeselect];
    }}

@end
