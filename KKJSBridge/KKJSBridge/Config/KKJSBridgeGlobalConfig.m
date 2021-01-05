//
//  KKJSBridgeGlobalConfig.m
//  KKJSBridge
//
//  Created by FoneG on 2021/1/4.
//

#import "KKJSBridgeGlobalConfig.h"
#import "KKJSBridgeConfig.h"
#import "NSURLProtocol+KKJSBridgeWKWebView.h"
#import "WKWebView+KKJSBridgeEngine.h"
#import "KKJSBridgeEngine.h"
#import "KKJSBridgeWebViewPointer.h"
#import <WebKit/WebKit.h>

@implementation KKJSBridgeGlobalConfig

+ (instancetype)config{
    static KKJSBridgeGlobalConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[KKJSBridgeGlobalConfig alloc] init];
    });
    return config;
}

- (void)setEnableAjaxHook:(BOOL)enableAjaxHook{
    _enableAjaxHook = enableAjaxHook;
    
#ifdef KKAjaxProtocolHook
    if (enableAjaxHook) {
        [NSURLProtocol KKJSBridgeRegisterScheme:@"https"];
        [NSURLProtocol KKJSBridgeRegisterScheme:@"http"];
    } else {
        [NSURLProtocol KKJSBridgeUnregisterScheme:@"https"];
        [NSURLProtocol KKJSBridgeUnregisterScheme:@"http"];
    }
#endif
    
    for (WKWebView *webView in [KKJSBridgeWebViewPointer shared].enqueueWebViews.objectEnumerator) {
        if (webView && [webView isKindOfClass:[WKWebView class]]) {
            webView.kk_engine.config.enableAjaxHook = YES;
        }
    }
}


@end


