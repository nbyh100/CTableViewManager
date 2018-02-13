//
//  CTableViewManager.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "CTableViewSectionManager.h"
#import "CTableViewCellData.h"

@interface CTableViewManager : NSObject

@property (nonatomic, weak, readonly) UITableView *_Nullable tableView;
@property (nonatomic, assign) BOOL enableCellHeightCache;

- (instancetype _Nonnull)initWithTableView:(UITableView *_Nonnull)tableView;

- (void)performReloadBlock:(void (^_Nonnull)(void))block;
- (void)performUpdateBlock:(void (^_Nonnull)(void))block animation:(UITableViewRowAnimation)animation;

- (NSInteger)indexForSectionID:(NSString *_Nonnull)sectionID;
- (NSString *_Nonnull)sectionIDForIndex:(NSInteger)index;
- (NSString *_Nonnull)cellIDForIndexPath:(NSIndexPath *_Nonnull)indexPath;
- (BOOL)sectionExistsWithID:(NSString *_Nonnull)sectionID;

- (CTableViewSectionManager *_Nonnull)sectionWithID:(NSString *_Nonnull)sectionID;
- (CTableViewSectionManager *_Nonnull)addSectionWithID:(NSString *_Nonnull)sectionID;
- (CTableViewSectionManager *_Nonnull)insertSectionWithID:(NSString *_Nonnull)sectionID beforeSectionWithID:(NSString *_Nonnull)anotherSectionID;
- (CTableViewSectionManager *_Nonnull)insertSectionWithID:(NSString *_Nonnull)sectionID afterSectionWithID:(NSString *_Nonnull)anotherSectionID;
- (void)deleteSectionWithID:(NSString *_Nonnull)sectionID;

@end
