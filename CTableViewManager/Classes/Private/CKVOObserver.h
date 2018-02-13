//
//  CKVOObserver.h
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import <Foundation/Foundation.h>

#ifndef CKVOObserver_h
#define CKVOObserver_h

typedef void (^CKVOHandler)(NSObject *_Nonnull object,
                            NSDictionary<NSString *, id> *_Nonnull change,
                            void *_Nullable context);

@interface CKVOObserver : NSObject

+ (CKVOObserver *_Nonnull)observe:(NSObject *_Nonnull)target
                          keyPath:(NSString *_Nonnull)keyPath
                          handler:(CKVOHandler _Nullable)handler
                          options:(NSKeyValueObservingOptions)options
                          context:(void *_Nullable)context;
+ (void)removeObserver:(CKVOObserver *_Nonnull)observer;
+ (void)remove:(NSObject *_Nonnull)target keyPath:(NSString *_Nonnull)keyPath;

@end

#endif
