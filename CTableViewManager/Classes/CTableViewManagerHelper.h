//
//  CTableViewManagerHelper.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/12.
//

#import <Foundation/Foundation.h>

extern NSString const *_Nonnull CTableViewManagerException;

@interface CTableViewManagerHelper : NSObject

+ (void)raiseException:(NSString *_Nonnull)reason userInfo:(NSDictionary *_Nullable)userInfo;

@end
