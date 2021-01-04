//
//  NSObject+SwizzleMethod.m
//  KKJSBridge
//
//  Created by FoneG on 2020/12/30.
//

#import "NSObject+SwizzleMethod.h"
#import <objc/runtime.h>

@implementation NSObject (SwizzleMethod)
+ (BOOL)existSourceInstanceMethod:(SEL)originalSel{
    if (!class_getInstanceMethod(self, originalSel)) {
        return NO;
    }
    NSString *Name = [NSString stringWithFormat:@"rVoidIMP_%@", NSStringFromSelector(originalSel)];
    if (class_getInstanceMethod(self, NSSelectorFromString(Name))) {
        return NO;
    }
    return YES;
}

+ (void)AddInstanceEmptyMethod:(SEL)originalSel{
    IMP rVoidIMP = imp_implementationWithBlock(^ (void) {
        return nil;
    });
    class_addMethod(self,
                    originalSel,
                    rVoidIMP,
                    NULL);
}

+ (BOOL)swizzleOrAddInstanceMethod:(SEL)originalSel
                        withNewSel:(SEL)newSel
                   withNewSelClass:(Class)newSelClass {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(newSelClass, newSel);
    if (!newMethod)
        return NO;
    if (originalMethod && newMethod) {//有新老sel的imp则交换
        IMP originImp = class_getMethodImplementation(self, originalSel);
        IMP newImp = class_getMethodImplementation(newSelClass, newSel);
        if (originImp == newImp) {
            return NO;
        }
        class_addMethod(self,
                        originalSel,
                        class_getMethodImplementation(self, originalSel),
                        method_getTypeEncoding(originalMethod));
        class_addMethod(self,
                        newSel,
                        class_getMethodImplementation(newSelClass, newSel),
                        method_getTypeEncoding(newMethod));
        method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                       class_getInstanceMethod(self, newSel));
        return YES;
    }
    else {//没有老的sel的实现，则新增
        if (!originalMethod) {
            IMP rVoidIMP = imp_implementationWithBlock(^ (void) {
                return nil;
            });
            class_addMethod(self,
                            originalSel,
                            rVoidIMP,
                            NULL);
            NSString *Name = [NSString stringWithFormat:@"rVoidIMP_%@", NSStringFromSelector(originalSel)];
            class_addMethod(self,
                            NSSelectorFromString(Name),
                            rVoidIMP,
                            NULL);
        }
        class_addMethod(self,
                        newSel,
                        class_getMethodImplementation(newSelClass, newSel),
                        method_getTypeEncoding(newMethod));
        method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                       class_getInstanceMethod(self, newSel));
        return YES;
    }
}

@end
