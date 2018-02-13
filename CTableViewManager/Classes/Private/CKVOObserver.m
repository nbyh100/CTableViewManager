//
//  CKVOObserver.m
//  CTableViewManager
//
//  Created by 张九州 on 2018/2/11.
//

#import "CKVOObserver.h"
#import <objc/runtime.h>

#ifndef CKVOObserver_m
#define CKVOObserver_m

@interface CKVOObserver ()

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) CKVOHandler handler;
@property (nonatomic, assign) BOOL removed;

@end

@implementation CKVOObserver

+ (nonnull CKVOObserver *)observe:(NSObject *)target
                          keyPath:(NSString *)keyPath
                          handler:(CKVOHandler)handler
                          options:(NSKeyValueObservingOptions)options
                          context:(void *)context {
    NSMutableDictionary *observers = [self _observers:target];
    NSMutableSet *observerSet = observers[keyPath];
    if (!observerSet) {
        observerSet = [NSMutableSet set];
        observers[keyPath] = observerSet;
    }

    CKVOObserver *observer = [[CKVOObserver alloc] initWithTarget:target keyPath:keyPath handler:handler];
    [target addObserver:observer forKeyPath:keyPath options:options context:context];
    [observerSet addObject:observer];
    observer.removed = NO;

    return observer;
}

+ (void)removeObserver:(CKVOObserver *)observer {
    if (!observer.removed) {
        NSMutableDictionary *observers = [self _observers:observer.target];
        NSMutableSet *observerSet = observers[observer.keyPath];
        [observer.target removeObserver:observer forKeyPath:observer.keyPath];
        [observerSet removeObject:observer];
        observer.removed = YES;
    }
}

+ (void)remove:(NSObject *)target keyPath:(NSString *)keyPath {
    NSMutableDictionary *observers = [self _observers:target];
    NSMutableSet *observerSet = observers[keyPath];
    for (CKVOObserver *observer in observerSet) {
        [self removeObserver:observer];
    }
}

+ (NSMutableDictionary *)_observers:(NSObject *)object {
    static char observersKey;
    NSMutableDictionary *observers = objc_getAssociatedObject(object, &observersKey);
    if (!observers) {
        observers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(object, &observersKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observers;
}

- (void)dealloc {
    if (!self.removed) {
        [self.target removeObserver:self forKeyPath:self.keyPath];
    }
}

- (instancetype)initWithTarget:(NSObject *)target
                       keyPath:(NSString *)keyPath
                       handler:(id)handler {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        self.handler = handler;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (self.handler) {
        self.handler(object, change, context);
    }
}

@end

#endif
