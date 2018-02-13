//
//  CTableViewCellData.m
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import "CTableViewCellData.h"
#import "Protocols.h"

@interface CTableViewCellData ()

@property (nonatomic, copy) NSString *cellID;
@property (nonatomic, copy) NSObject<ITableViewCellPayload> *payload;
@property (nonatomic, strong) CTableViewSectionManager * sectionManager;
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation CTableViewCellData

+ (instancetype)cellData:(NSString *)cellID
                 payload:(NSObject<ITableViewCellPayload> *)payload
          sectionManager:(CTableViewSectionManager *)sectionManager {
    return [[self alloc] initWithCellID:cellID payload:payload sectionManager:sectionManager];
}

- (instancetype)initWithCellID:(NSString *)cellID payload:(NSObject<ITableViewCellPayload> *)payload sectionManager:(CTableViewSectionManager *)sectionManager {
    self = [super init];
    if (self) {
        _cellID = [cellID copy];
        _payload = [payload copy];
        if ([_payload respondsToSelector:@selector(setSectionManager:)]) {
            _payload.sectionManager = sectionManager;
        }
        if ([_payload respondsToSelector:@selector(setCellData:)]) {
            _payload.cellData = self;
        }
        _sectionManager = sectionManager;
    }
    return self;
}

@end
