//
//  WKWebView+DefaultEngine.m
//  KKJSBridge
//
//  Created by FoneG on 2020/12/30.
//

#import "WKWebView+EngineBridge.h"
#import "NSObject+SwizzleMethod.h"
#import "WKwebViewEngineBridge.h"
#import "KKJSBridgeEngine.h"
#import "KKWebViewCookieManager.h"
#import "WKWebView+KKWebViewReusable.h"
#import "WKWebView+KKJSBridgeEngine.h"
#import "KKWebViewPool.h"
#import "KKJSBridgeWebViewPointer.h"
#import "KKJSBridgeGlobalConfig.h"
#import <objc/runtime.h>

@interface WKWebView ()<WKNavigationDelegate,WKUIDelegate>
@end

@implementation WKWebView (EngineBridge)

+ (void)load{
    [WKWebView kk_swizzleOrAddInstanceMethod:@selector(initWithFrame:configuration:) withNewSel:@selector(mb_initWithFrame:configuration:) withNewSelClass:WKWebView.class];
    [WKWebView kk_swizzleOrAddInstanceMethod:@selector(loadRequest:) withNewSel:@selector(mb_loadRequest:) withNewSelClass:WKWebView.class];
}


- (instancetype)mb_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    //放入Pointer池, 用于全局管理WebVie
    [[KKJSBridgeWebViewPointer shared] enter:self];
    
    if (!configuration) {
        configuration = [WKWebViewConfiguration new];
    }
    [self mb_initWithFrame:frame configuration:configuration];
    if (!configuration.userContentController) {
        configuration.userContentController = [WKUserContentController new];
    }
    self.configuration.processPool = [WKWebView processPool];

    [self createJSBridgeEngine];
    
    WKwebViewEngineBridge *bridge = [WKwebViewEngineBridge bridgeForWebView:self];
    [self setBridge:bridge];
    
    self.navigationDelegate = self;
    self.UIDelegate = self;
    return self;
}

/**
 【COOKIE 1】同步首次请求的 cookie
 */
- (nullable WKNavigation *)mb_loadRequest:(NSURLRequest *)request {
    if (!self.kk_engine) {
        [self createJSBridgeEngine];
    }
    if (request.URL.scheme.length > 0) {
        [self syncAjaxCookie];
        NSMutableURLRequest *requestWithCookie = request.mutableCopy;
        [KKWebViewCookieManager syncRequestCookie:requestWithCookie];
        return [self mb_loadRequest:requestWithCookie];
    }
    
    return [self mb_loadRequest:request];
}

/**
 【COOKIE 2】为异步 ajax 请求同步 cookie
 */
- (void)syncAjaxCookie {
    if (!(self.kk_engine && self.kk_engine.config.isEnableAjaxHook)) {// 当开启 ajax hook 时，Cookie 处理都会被 NSHTTPCookieStorage 接管，这里就不用注入脚本了
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[KKWebViewCookieManager ajaxCookieScripts] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.configuration.userContentController addUserScript:cookieScript];
    }
}


- (void)createJSBridgeEngine{
    KKJSBridgeEngine *jsBridgeEngine = [KKJSBridgeEngine bridgeForWebView:self];
    self.kk_engine.config.enableAjaxHook = [KKJSBridgeGlobalConfig config].enableAjaxHook;
    jsBridgeEngine.bridgeReadyCallback = ^(KKJSBridgeEngine * _Nonnull engine) {
        NSString *event = @"customEvent";
        NSDictionary *data = @{
            @"action": @"testAction",
            @"data": @YES
        };
        [engine dispatchEvent:event data:data];
    };
}

#pragma mark - process
/**
 通过让所有 WKWebView 共享同一个WKProcessPool实例，可以实现多个 WKWebView 之间共享 Cookie（session Cookie and persistent Cookie）数据。Session Cookie（代指没有设置 expires 的 cookie），Persistent Cookie （设置了 expires 的 cookie）。
 
 另外 WKWebView WKProcessPool 实例在 app 杀进程重启后会被重置，导致 WKProcessPool 中的 session Cookie 数据丢失。
 同样的，如果是存储在 NSHTTPCookieStorage 里面的 SeesionOnly cookie 也会在 app 杀掉进程后清空。
 
 @return processPool
 */
+ (WKProcessPool *)processPool {
    static WKProcessPool *pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[WKProcessPool alloc] init];
    });
    
    return pool;
}


- (WKwebViewEngineBridge *)bridge{
    return objc_getAssociatedObject(self, @selector(setBridge:));
}

- (void)setBridge:(WKwebViewEngineBridge *)jsBridgeEngine {
    objc_setAssociatedObject(self, @selector(setBridge:), jsBridgeEngine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
