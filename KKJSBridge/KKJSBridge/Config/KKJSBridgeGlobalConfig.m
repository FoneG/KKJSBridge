//
//  KKJSBridgeGlobalConfig.m
//  KKJSBridge
//
//  Created by FoneG on 2021/1/4.
//

#import "KKJSBridgeGlobalConfig.h"

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
    
    /// 移除监听
    
    
    /// 通知对应webView关闭ajaxHook开关
    
    
    ///
}


@end


