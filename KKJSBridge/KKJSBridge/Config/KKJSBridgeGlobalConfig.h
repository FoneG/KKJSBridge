//
//  KKJSBridgeGlobalConfig.h
//  KKJSBridge
//
//  Created by FoneG on 2021/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 全局配置 JSBridge 的ajax hook行为
 */
@interface KKJSBridgeGlobalConfig : NSObject

+ (instancetype)config;

/**
 是否开启 ajax hook，默认是不开启的
 
 讨论：
 1、当需要关闭 ajax hook 时，建议联动取消 WKWebView 对 http/https 的注册，这样可以避免有些场景下 ajax hook 引起了严重不兼容的问题。
 2、同时建议可以考虑建立黑名单机制，让服务器端下发黑名单对部分页面关闭该开关，宁可关闭对离线包的支持，也不能让这个页面不可用。
 */
@property (nonatomic, assign, getter=isEnableAjaxHook) BOOL enableAjaxHook;

@end

NS_ASSUME_NONNULL_END
