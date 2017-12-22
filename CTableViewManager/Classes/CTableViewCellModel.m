//
//  CTableViewCellModel.m
//  CTableViewManager
//
//  Created by 张九州 on 16/4/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "CTableViewCellModel.h"

@interface CTableBlankCell : UITableViewCell

@end

@implementation CTableBlankCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end

@interface CTableViewCellModel ()

@property (nonatomic, weak) CTableViewSectionModel *sectionModel;

@property (nonatomic, assign) Class _cellClass;
@property (nonatomic, assign) CGFloat _cellHeight;

@end

@implementation CTableViewCellModel

+ (instancetype)cellModelWithClass:(Class)classname height:(CGFloat)height
{
    CTableViewCellModel *instance = [[self alloc] init];
    if (instance) {
        instance._cellClass = classname;
        instance._cellHeight = height;
        instance.cellActionEnabled = NO;
    }
    return instance;
}

+ (instancetype)blankCellModel
{
    return [CTableViewCellModel blankCellModelWithHeight:12];
}

+ (instancetype)blankCellModelWithHeight:(CGFloat)height
{
    return [CTableViewCellModel cellModelWithClass:[CTableBlankCell class] height:height];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.autoDeselect = YES;
        self.cellActionEnabled = YES;
    }
    return self;
}

- (Class)cellClass
{
    return self._cellClass;
}

- (CGFloat)cellHeight
{
    return self._cellHeight;
}

@end
