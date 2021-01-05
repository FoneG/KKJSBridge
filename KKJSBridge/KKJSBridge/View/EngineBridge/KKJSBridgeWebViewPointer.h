//
//  KKJSBridgeWebViewPointer.h
//  KKJSBridge
//
//  Created by FoneG on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKJSBridgeWebViewPointer : NSObject

+ (instancetype)shared;
- (NSHashTable <WKWebView *>*)enqueueWebViews;
- (void)enter:(WKWebView *)webview;
- (void)clear:(WKWebView *)webview;

@end

NS_ASSUME_NONNULL_END
