//
//  WKwebViewEngineBridge.m
//  KKJSBridge
//
//  Created by FoneG on 2020/12/30.
//

#import "WKWebViewHookBridge.h"
#import "KKWebViewCookieManager.h"
#import "WKWebView+KKJSBridgeEngine.h"
#import "WKWebView+KKWebViewReusable.h"
#import "KKWebViewPool.h"
#import "KKJSBridgeWebViewPointer.h"
#import "KKJSBridgeSwizzle.h"
#import <objc/runtime.h>

@interface WKWebViewHookBridge ()<WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, unsafe_unretained, readwrite) WKWebView *webView;
@end

@implementation WKWebViewHookBridge

- (void)dealloc{
    if ([self.webView isKindOfClass:[WKWebView class]]) {
        [self.webView removeObserver:self forKeyPath:@"UIDelegate"];
        [self.webView removeObserver:self forKeyPath:@"navigationDelegate"];
        [[KKJSBridgeWebViewPointer shared] clear:self.webView];
    }
}

+ (instancetype)bridgeForWebView:(WKWebView *)webView{
    WKWebViewHookBridge *bridge = [[WKWebViewHookBridge alloc] init];
    bridge.webView = webView;
    [webView addObserver:bridge forKeyPath:@"UIDelegate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [webView addObserver:bridge forKeyPath:@"navigationDelegate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    return bridge;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    if (newValue == nil) {
        return;
    }
    if ([[newValue class] isMemberOfClass:[oldValue class]]) {
        return;
    }
        
    @synchronized (self) {
        Class objClass = [newValue class];

        if ([keyPath isEqualToString:@"navigationDelegate"]) {

            SEL navigationDelegate_hookSEL = NSSelectorFromString([NSString stringWithFormat:@"%@_navigationDelegate_hook", NSStringFromClass(objClass)]);
            if (KKJSBridgeExistRVoidIMPInstanceMethod(objClass, navigationDelegate_hookSEL)) {
                return;
            }
            KKJSBridgeAddRVoidIMPMethod(objClass, navigationDelegate_hookSEL);
            
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:decidePolicyForNavigationAction:decisionHandler:), WKWebViewHookBridge.class, @selector(kk_webView:decidePolicyForNavigationAction:decisionHandler:));
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:decidePolicyForNavigationResponse:decisionHandler:), WKWebViewHookBridge.class, @selector(kk_webView:decidePolicyForNavigationResponse:decisionHandler:));
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:didFinishNavigation:), WKWebViewHookBridge.class, @selector(kk_webView:didFinishNavigation:));
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:didReceiveAuthenticationChallenge:completionHandler:), WKWebViewHookBridge.class, @selector(kk_webView:didReceiveAuthenticationChallenge:completionHandler:));
        }
        else if([keyPath isEqualToString:@"UIDelegate"]){

            SEL UIDelegate_hookSEL = NSSelectorFromString([NSString stringWithFormat:@"%@_UIDelegate_hook", NSStringFromClass(objClass)]);
            if (KKJSBridgeExistRVoidIMPInstanceMethod(objClass, UIDelegate_hookSEL)) {
                return;
            }
            KKJSBridgeAddRVoidIMPMethod(objClass, UIDelegate_hookSEL);

            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:), WKWebViewHookBridge.class, @selector(kk_webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:));
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:), WKWebViewHookBridge.class, @selector(kk_webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:));
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:), WKWebViewHookBridge.class, @selector(kk_webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:));
            KKJSBridgeSwizzleOrAddRVoidIMPInstanceMethod(objClass, @selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:), WKWebViewHookBridge.class, @selector(kk_webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:));
        }
    }
}

#pragma mark - WKNavigationDelegate

// 1、在发送请求之前，决定是否跳转
- (void)kk_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s", __func__);
    /**
     【COOKIE 3】对服务器端重定向(302)/浏览器重定向(a标签[包括 target="_blank"]) 进行同步 cookie 处理。
     由于所有的跳转都会是 NSMutableURLRequest 类型，同时也无法单独区分出 302 服务器端重定向跳转，所以这里统一对服务器端重定向(302)/浏览器重定向(a标签[包括 target="_blank"])进行同步 cookie 处理。
     */
    if ([navigationAction.request isKindOfClass:NSMutableURLRequest.class]) {
        [KKWebViewCookieManager syncRequestCookie:(NSMutableURLRequest *)navigationAction.request];
    }
    if (!KKJSBridgeExistRVoidIMPInstanceMethod(self.class, @selector(webView:decidePolicyForNavigationAction:decisionHandler:))) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    [self kk_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
}

// 2、在收到响应后，决定是否跳转
- (void)kk_webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s", __func__);
    // iOS 12 之后，响应头里 Set-Cookie 不再返回。 所以这里针对系统版本做区分处理。
    if (@available(iOS 11.0, *)) {
        // 【COOKIE 4】同步 WKWebView cookie 到 NSHTTPCookieStorage。
        [KKWebViewCookieManager copyWKHTTPCookieStoreToNSHTTPCookieStorageForWebViewOniOS11:webView withCompletion:nil];
    } else {
        // 【COOKIE 4】同步服务器端响应头里的 Set-Cookie，既把 WKWebView cookie 同步到 NSHTTPCookieStorage。
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    if (!KKJSBridgeExistRVoidIMPInstanceMethod(self.class, @selector(webView:decidePolicyForNavigationResponse:decisionHandler:))) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    [self kk_webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
}

// 3、页面跳转完成时调用
- (void)kk_webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    // 预加载下一个 WebView
    // 只有当 WebViewPool 里包含 WebView class 类型，说明当前 WebView 是通过 WebViewPool 创建出来的，此时才需要预加载下一个 WebView 实例
    if ([[KKWebViewPool sharedInstance] containsReusableWebViewWithClass:webView.class]) {
        [[KKWebViewPool sharedInstance] enqueueWebViewWithClass:webView.class];
    }
    [self kk_webView:webView didFinishNavigation:navigation];
}

//// 4、需要校验服务器可信度时调用
- (void)kk_webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if (!KKJSBridgeExistRVoidIMPInstanceMethod(self.class, @selector(webView:didReceiveAuthenticationChallenge:completionHandler:))) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
    [self kk_webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
}

#pragma mark - WKUIDelegate
// 创建一个新的 webView
- (nullable WKWebView *)kk_webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"%s", __func__);
    if (!navigationAction.targetFrame.isMainFrame) {// 针对 <a target="_blank" href="" > 做处理。同时也会同步 cookie， 保持 loadRequest 加载请求携带 cookie 的一致性。
        [webView loadRequest:[KKWebViewCookieManager fixRequest:navigationAction.request]];
    }
    return [self kk_webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
}

// webView 中的提示弹窗
- (void)kk_webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s", __func__);
    if (![WKWebViewHookBridge canShowPanelWithWebView:webView]) {
        completionHandler();
        return;
    }
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"" message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           completionHandler();
                                                       }])];
    
    UIViewController *topPresentedViewController = [WKWebViewHookBridge _topPresentedViewController];
    if (topPresentedViewController.presentingViewController) {
        completionHandler();
    } else {
        [topPresentedViewController presentViewController:alertController animated:YES completion:nil];
    }
    if (!KKJSBridgeExistRVoidIMPInstanceMethod(self.class, @selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:))) {
        completionHandler();
    }
    [self kk_webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
}

// webView 中的确认弹窗
- (void)kk_webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%s", __func__);
    if (![WKWebViewHookBridge canShowPanelWithWebView:webView]) {
        completionHandler(NO);
        return;
    }
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"" message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           completionHandler(NO);
                                                       }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           completionHandler(YES);
                                                       }])];
    
    UIViewController *topPresentedViewController = [WKWebViewHookBridge _topPresentedViewController];
    if (topPresentedViewController.presentingViewController) {
        completionHandler(NO);
    } else {
        [topPresentedViewController presentViewController:alertController animated:YES completion:nil];
    }
    
    if (!KKJSBridgeExistRVoidIMPInstanceMethod(self.class, @selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:))) {
        completionHandler(NO);
    }
    [self kk_webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
}

// webView 中的输入框
- (void)kk_webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    NSLog(@"%s", __func__);

    if (![WKWebViewHookBridge canShowPanelWithWebView:webView]) {
        completionHandler(nil);
        return;
    }
    
    // 处理来自 KKJSBridge 的同步调用
    if ([webView handleSyncCallWithPrompt:prompt defaultText:defaultText completionHandler:completionHandler]) {
        return;
    }
    
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt
                                                                             message:sender
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController
     addAction:([UIAlertAction actionWithTitle:@"确定"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           if (alertController.textFields && alertController.textFields.count > 0) {
                                               UITextField *textFiled = [alertController.textFields firstObject];
                                               if (textFiled.text && textFiled.text.length > 0) {
                                                   completionHandler(textFiled.text);
                                               } else {
                                                   completionHandler(nil);
                                               }
                                           } else {
                                               completionHandler(nil);
                                           }
                                       }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           completionHandler(nil);
                                                       }])];
    
    UIViewController *topPresentedViewController = [WKWebViewHookBridge _topPresentedViewController];
    if (topPresentedViewController.presentingViewController) {
        completionHandler(nil);
    } else {
        [topPresentedViewController presentViewController:alertController animated:YES completion:nil];
    }
    
    if (!KKJSBridgeExistRVoidIMPInstanceMethod(self.class, @selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:))) {
        completionHandler(nil);
    }
    [self kk_webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
}

#pragma mark - private method

+ (BOOL)canShowPanelWithWebView:(WKWebView *)webView {
    if ([webView.holderObject isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)webView.holderObject;
        if (vc.isBeingPresented || vc.isBeingDismissed || vc.isMovingToParentViewController || vc.isMovingFromParentViewController) {
            return NO;
        }
    }
    return YES;
}

+ (UIViewController *)_topPresentedViewController {
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (viewController.presentedViewController)
        viewController = viewController.presentedViewController;
    return viewController;
}

@end
