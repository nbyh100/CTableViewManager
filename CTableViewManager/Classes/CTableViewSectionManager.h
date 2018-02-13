//
//  CTableViewSectionManager.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import <Foundation/Foundation.h>

@class CTableViewManager;
@class CTableViewCellData;
@protocol ITableViewCellPayload;

typedef NSObject<ITableViewCellPayload> *_Nonnull (^CUpdateCellBlock)(NSObject<ITableViewCellPayload> *_Nonnull payload);

@interface CTableViewSectionManager : NSObject

@property (nonatomic, copy, readonly) NSString *_Nonnull sectionID;
@property (nonatomic, strong, readonly) CTableViewManager *_Nonnull tableViewManager;

+ (_Nonnull instancetype)sectionManager:(NSString *_Nonnull)sectionID
                       tableViewManager:(CTableViewManager *_Nonnull)tableViewManager;

- (NSIndexPath *_Nonnull)indexPathForCellID:(NSString *_Nonnull)cellID;
- (NSString *_Nonnull)cellIDForIndex:(NSInteger)index;
- (BOOL)cellExistsWithID:(NSString *_Nonnull)cellID;

- (CTableViewCellData *_Nonnull)cellDataWithID:(NSString *_Nonnull)cellID;
- (void)addCellWithID:(NSString *_Nonnull)cellID payload:(NSObject<ITableViewCellPayload> *_Nonnull)payload;
- (void)insertCellWithID:(NSString *_Nonnull)cellID
        beforeCellWithID:(NSString *_Nonnull)anotherCellID
                 payload:(NSObject<ITableViewCellPayload> *_Nonnull)payload;
- (void)insertCellWithID:(NSString *_Nonnull)cellID
         afterCellWithID:(NSString *_Nonnull)anotherCellID
                 payload:(NSObject<ITableViewCellPayload> *_Nonnull)payload;
- (void)updateCellWithID:(NSString *_Nonnull)cellID block:(CUpdateCellBlock _Nonnull)block;
- (void)refreshCellWithID:(NSString *_Nonnull)cellID block:(CUpdateCellBlock _Nonnull)block;
- (void)deleteCellWithID:(NSString *_Nonnull)cellID;

- (NSNumber *_Nullable)cellHeightCacheWithID:(NSString *_Nonnull)cellID;
- (void)setCellHeightCache:(NSNumber *_Nullable)height withID:(NSString *_Nonnull)cellID;

- (BOOL)cellIsSelectedWithID:(NSString *_Nonnull)cellID;
- (void)selectCellWithID:(NSString *_Nonnull)cellID
                animated:(BOOL)animated
          scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectCellWithID:(NSString *_Nonnull)cellID animated:(BOOL)animated;

@end
