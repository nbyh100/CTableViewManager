#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CTableViewManager.h"
#import "Helpers.h"
#import "Protocols.h"
#import "UITableView+CTableViewManager.h"
#import "UITableView+Private.h"

FOUNDATION_EXPORT double CTableViewManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char CTableViewManagerVersionString[];

