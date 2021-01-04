//
//  KKJSBridgeWebViewPointer.m
//  KKJSBridge
//
//  Created by FoneG on 2021/1/4.
//

#import "KKJSBridgeWebViewPointer.h"

@implementation KKJSBridgeWebViewPointer

+ (instancetype)shared{
    static KKJSBridgeWebViewPointer *pointer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointer = [[KKJSBridgeWebViewPointer alloc] init];
        pointer.enqueueWebViews = [NSHashTable weakObjectsHashTable];
    });
    return pointer;;
}

- (void)enter:(WKWebView *)webview{
    if ([self.enqueueWebViews containsObject:webview]) {
        return;
    }
    [self.enqueueWebViews addObject:webview];
}

- (void)clear:(WKWebView *)webview{
    if ([self.enqueueWebViews containsObject:webview]) {
        [self.enqueueWebViews removeObject:webview];
    }
}


@end
