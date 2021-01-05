//
//  KKJSBridgeSwizzle.m
//  KKJSBridge
//
//  Created by karos li on 2020/6/22.
//  Copyright © 2020 karosli. All rights reserved.
//

#import "KKJSBridgeSwizzle.h"
#import <objc/runtime.h>

void KKJSBridgeSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalCls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(originalCls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
   
    if (didAddMethod) {
        class_replaceMethod(originalCls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

BOOL KKJSBridgeExistInstanceMethod(Class originalCls, SEL originalSel){
    if (!class_getInstanceMethod(originalCls, originalSel)) {
        return NO;
    }
    return YES;
}


BOOL KKJSBridgeExistRVoidIMPInstanceMethod(Class originalCls, SEL originalSel){
    if (!class_getInstanceMethod(originalCls, originalSel)) {
        return NO;
    }
    // for: originalSel do not exist in originalCls
    NSString *Name = [NSString stringWithFormat:@"rVoidIMP_%@", NSStringFromSelector(originalSel)];
    if (class_getInstanceMethod(originalCls, NSSelectorFromString(Name))) {
        return NO;
    }
    return YES;
}

BOOL KKJSBridgeAddRVoidIMPMethod(Class originalCls, SEL originalSel){
    IMP rVoidIMP = imp_implementationWithBlock(^ (void) {
        return nil;
    });
    class_addMethod(originalCls,
                    originalSel,
                    rVoidIMP,
                    NULL);
    return YES;
}


BOOL KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(Class originalCls, SEL originalSel, Class newSelClass, SEL newSel){
    Method originalMethod = class_getInstanceMethod(originalCls, originalSel);
    Method newMethod = class_getInstanceMethod(newSelClass, newSel);
    if (!newMethod)
        return NO;

    if (!originalMethod) {
        IMP rVoidIMP = imp_implementationWithBlock(^ (void) {
            return nil;
        });
        class_addMethod(originalCls,
                        originalSel,
                        rVoidIMP,
                        NULL);
        //没有originalSel的实现，用rVoidIMP_标记
        NSString *Name = [NSString stringWithFormat:@"rVoidIMP_%@", NSStringFromSelector(originalSel)];
        class_addMethod(originalCls,
                        NSSelectorFromString(Name),
                        rVoidIMP,
                        NULL);
    }
    
    //有新老sel的imp则交换，可能发生在父类
    IMP originImp = class_getMethodImplementation(originalCls, originalSel);
    IMP newImp = class_getMethodImplementation(newSelClass, newSel);
    if (originImp == newImp) {
        return NO;
    }
    
    class_addMethod(originalCls,
                    newSel,
                    class_getMethodImplementation(newSelClass, newSel),
                    method_getTypeEncoding(newMethod));
    method_exchangeImplementations(class_getInstanceMethod(originalCls, originalSel),
                                   class_getInstanceMethod(originalCls, newSel));
    return YES;
}
