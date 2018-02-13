//
//  CTableViewManagerHelper.m
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/12.
//

#import "CTableViewManagerHelper.h"

NSString const *_Nonnull CTableViewManagerException = @"CTableViewManagerException";

@implementation CTableViewManagerHelper

+ (void)raiseException:(NSString *)reason userInfo:(NSDictionary *)userInfo {
    @throw [NSException exceptionWithName:(NSExceptionName)CTableViewManagerException
                                   reason:reason
                                 userInfo:userInfo];
}

@end
