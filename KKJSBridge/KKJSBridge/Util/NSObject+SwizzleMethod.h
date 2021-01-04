//
//  NSObject+SwizzleMethod.h
//  KKJSBridge
//
//  Created by FoneG on 2020/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
 
@interface NSObject (SwizzleMethod)

/// 是否原先存在originalSel
/// @param originalSel /
+ (BOOL)kk_existSourceInstanceMethod:(SEL)originalSel;

/// 添加一个空的方法
/// @param originalSel  /
+ (void)kk_AddInstanceEmptyMethod:(SEL)originalSel;

+ (BOOL)kk_swizzleOrAddInstanceMethod:(SEL)originalSel
                        withNewSel:(SEL)newSel
                   withNewSelClass:(Class)newSelClass;
@end

NS_ASSUME_NONNULL_END
