//
//  CTableViewSectionManager.m
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import "CTableViewSectionManager.h"
#import "CTableViewCellData.h"
#import "CTableViewManager.h"
#import "CTableViewManagerHelper.h"
#import "Private.h"

@interface CTableViewSectionManager ()

@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, strong) CTableViewManager *tableViewManager;
@property (nonatomic, strong) NSMutableArray<CTableViewCellData *> * cells;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CTableViewCellData *> *cellsByID;
@property (nonatomic, copy) void (^didSelectCell)(NSInteger index, BOOL animated, UITableViewScrollPosition scrollPosition);
@property (nonatomic, copy) void (^didDeselectCell)(NSInteger index, BOOL animated);
@property (nonatomic, strong) NSCache *heightCache;

@end

@implementation CTableViewSectionManager

+ (instancetype)sectionManager:(NSString *)sectionID tableViewManager:(CTableViewManager *)tableViewManager {
    return [[[self class] alloc] initWithSectionID:sectionID tableViewManager:tableViewManager];
}

- (instancetype)initWithSectionID:(NSString *)sectionID tableViewManager:(CTableViewManager *)tableViewManager {
    self = [super init];
    if (self) {
        _sectionID = [sectionID copy];
        _tableViewManager = tableViewManager;
        _cells = [NSMutableArray array];
        _cellsByID = [NSMutableDictionary dictionary];
        _heightCache = [NSCache new];
    }
    return self;
}

- (NSIndexPath *)indexPathForCellID:(NSString *)cellID {
    CTableViewCellData *cellData = [self _cell:cellID];
    NSInteger row = [self.cells indexOfObject:cellData];
    NSInteger section = [self.tableViewManager indexForSectionID:self.sectionID];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSString *)cellIDForIndex:(NSInteger)index {
    if (index >= self.cells.count || index < 0) {
        [CTableViewManagerHelper raiseException:[NSString stringWithFormat:@"Invalid cell index %ld", (long)index] userInfo:nil];
    }
    return self.cells[index].cellID;
}

- (BOOL)cellExistsWithID:(NSString *)cellID {
    return !!self.cellsByID[cellID];
}

- (CTableViewCellData *)cellDataWithID:(NSString *)cellID {
    return [self _cell:cellID];
}

- (void)addCellWithID:(NSString *)cellID payload:(NSObject<ITableViewCellPayload> *)payload {
    [self _insertCell:cellID payload:payload atIndex:self.cells.count];
}

- (void)insertCellWithID:(NSString *)cellID beforeCellWithID:(NSString *)anotherCellID payload:(NSObject<ITableViewCellPayload> *)payload {
    CTableViewCellData *anotherCellData = [self _cell:anotherCellID];
    NSInteger pos = [self.cells indexOfObject:anotherCellData];

    [self _insertCell:cellID payload:payload atIndex:pos];
}

- (void)insertCellWithID:(NSString *)cellID afterCellWithID:(NSString *)anotherCellID payload:(NSObject<ITableViewCellPayload> *)payload {
    CTableViewCellData *anotherCellData = [self _cell:anotherCellID];
    NSInteger pos = [self.cells indexOfObject:anotherCellData];

    [self _insertCell:cellID payload:payload atIndex:pos + 1];
}

- (void)updateCellWithID:(NSString *)cellID block:(CUpdateCellBlock)block {
    // 在执行update时，系统会自动取消选中cell，模拟这个行为。
    [self deselectCellWithID:cellID animated:NO];

    CTableViewCellData *oldCellData = [self _cell:cellID];
    NSObject<ITableViewCellPayload> *payload = block(oldCellData.payload);
    [self _updateCell:cellID payload:payload refresh:NO];
}

- (void)refreshCellWithID:(NSString *)cellID block:(CUpdateCellBlock)block {
    CTableViewCellData *oldCellData = [self _cell:cellID];
    NSObject<ITableViewCellPayload> *payload = block(oldCellData.payload);
    [self _updateCell:cellID payload:payload refresh:YES];
}

- (void)deleteCellWithID:(NSString *)cellID {
    [self _deleteCell:cellID];
}

- (BOOL)cellIsSelectedWithID:(NSString *)cellID {
    NSIndexPath *indexPath = [self indexPathForCellID:cellID];
    if (indexPath) {
        if (self.tableViewManager.tableView.allowsMultipleSelection) {
            NSArray *selectedIndexPaths = self.tableViewManager.tableView.indexPathsForSelectedRows;
            for (NSIndexPath *selectedIndexPath in selectedIndexPaths) {
                if (indexPath.row == selectedIndexPath.row && indexPath.section == selectedIndexPath.section) {
                    return YES;
                }
            }
        } else {
            NSIndexPath *selectedIndexPath = self.tableViewManager.tableView.indexPathForSelectedRow;
            return indexPath.row == selectedIndexPath.row && indexPath.section == selectedIndexPath.section;
        }
    }

    return NO;
}

- (void)selectCellWithID:(NSString *)cellID animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    if ([self cellIsSelectedWithID:cellID]) {
        return;
    }

    CTableViewCellData *cellData = [self _cell:cellID];
    NSInteger pos = [self.cells indexOfObject:cellData];

    if (self.didSelectCell) {
        self.didSelectCell(pos, animated, scrollPosition);
    }
}

- (void)deselectCellWithID:(NSString *)cellID animated:(BOOL)animated {
    if (![self cellIsSelectedWithID:cellID]) {
        return;
    }

    CTableViewCellData *cellData = [self _cell:cellID];
    NSInteger pos = [self.cells indexOfObject:cellData];

    if (self.didDeselectCell) {
        self.didDeselectCell(pos, animated);
    }
}

- (NSNumber *)cellHeightCacheWithID:(NSString *)cellID {
    return [self.heightCache objectForKey:cellID];
}

- (void)setCellHeightCache:(NSNumber *)height withID:(NSString *)cellID {
    if (self.cellsByID[cellID]) {
        if (height) {
            [self.heightCache setObject:height forKey:cellID];
        } else {
            [self.heightCache removeObjectForKey:cellID];
        }
    }
}

- (NSMutableArray *)_cellsArray {
    return [self mutableArrayValueForKey:@"cells"];
}

- (CTableViewCellData *)_cell:(NSString *)cellID {
    CTableViewCellData *cellData = self.cellsByID[cellID];
    if (!cellData) {
        [CTableViewManagerHelper raiseException:
         [NSString stringWithFormat:@"Invalid cellID %@.", cellID] userInfo:nil];
    }
    return cellData;
}

- (void)_insertCell:(NSString *)cellID payload:(NSObject<ITableViewCellPayload> *)payload atIndex:(NSInteger)index {
    if (self.cellsByID[cellID]) {
        [CTableViewManagerHelper raiseException:
         [NSString stringWithFormat:@"Duplicated cellID %@.", cellID] userInfo:nil];
    }

    CTableViewCellData *cellData = [CTableViewCellData cellData:cellID payload:payload sectionManager:self];
    [[self _cellsArray] insertObject:cellData atIndex:index];
    self.cellsByID[cellID] = cellData;
}

- (void)_updateCell:(NSString *)cellID payload:(NSObject<ITableViewCellPayload> *)payload refresh:(BOOL)refresh {
    CTableViewCellData *oldCellData = [self _cell:cellID];
    CTableViewCellData *cellData = [CTableViewCellData cellData:cellID payload:payload sectionManager:self];
    cellData.isRefresh = refresh;

    [self setCellHeightCache:nil withID:cellID];

    NSInteger pos = [self.cells indexOfObject:oldCellData];
    [[self _cellsArray] replaceObjectAtIndex:pos withObject:cellData];
    self.cellsByID[cellID] = cellData;
}

- (void)_deleteCell:(NSString *)cellID {
    CTableViewCellData *cellData = [self _cell:cellID];

    [self setCellHeightCache:nil withID:cellID];

    NSInteger pos = [self.cells indexOfObject:cellData];
    [[self _cellsArray] removeObjectAtIndex:pos];
    [self.cellsByID removeObjectForKey:cellID];
}

@end
