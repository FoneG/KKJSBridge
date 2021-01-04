//
//  WKwebViewEngineBridge.h
//  KKJSBridge
//
//  Created by FoneG on 2020/12/30.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKwebViewEngineBridge : NSObject
/**
 为 webViewEngin 创建一个桥接
 
 @param webView webView
 @return 返回一个桥接实例
 */
+ (instancetype)bridgeForWebView:(WKWebView *)webView;
@end

NS_ASSUME_NONNULL_END
