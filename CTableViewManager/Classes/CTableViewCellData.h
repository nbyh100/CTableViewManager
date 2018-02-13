//
//  CTableViewCellData.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import <Foundation/Foundation.h>

@class CTableViewSectionManager;
@protocol ITableViewCellPayload;

@interface CTableViewCellData : NSObject

@property (nonatomic, copy, readonly) NSString *_Nonnull cellID;
@property (nonatomic, copy, readonly) NSObject<ITableViewCellPayload> *_Nonnull payload;
@property (nonatomic, strong, readonly) CTableViewSectionManager *_Nonnull sectionManager;

+ (instancetype _Nonnull)cellData:(NSString *_Nonnull)cellID
                          payload:(NSObject<ITableViewCellPayload> *_Nonnull)payload
                   sectionManager:(CTableViewSectionManager *_Nonnull)sectionManager;

@end
