//
//  KKJSBridgeSwizzle.h
//  KKJSBridge
//
//  Created by karos li on 2020/6/22.
//  Copyright © 2020 karosli. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void KKJSBridgeSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector);
FOUNDATION_EXPORT BOOL KKJSBridgeExistInstanceMethod(Class originalCls, SEL originalSel);

/* RVoidIMP */
FOUNDATION_EXPORT BOOL KKJSBridgeExistRVoidIMPInstanceMethod(Class originalCls, SEL originalSel);

FOUNDATION_EXPORT BOOL KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector);

FOUNDATION_EXPORT BOOL KKJSBridgeAddRVoidIMPMethod(Class originalCls, SEL originalSelector);
