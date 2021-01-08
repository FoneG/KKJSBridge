//
//  UIView+KKJSBridgeTool.m
//  KKJSBridge
//
//  Created by FoneG on 2021/1/7.
//

#import "UIView+KKJSBridgeTool.h"

@implementation UIView (KKJSBridgeTool)

-(UIViewController *)kk_viewController{
    UIViewController *viewController = nil;
    UIResponder *next = self.nextResponder;
    while (next) {
        if ([next isKindOfClass:[UIViewController class]]) {
            viewController = (UIViewController *)next;
            break;
        }
        next = next.nextResponder;
    }
    return viewController;
}

@end
