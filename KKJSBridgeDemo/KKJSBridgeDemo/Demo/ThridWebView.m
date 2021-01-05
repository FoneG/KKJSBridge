//
//  ThridWebView.m
//  KKJSBridgeDemo
//
//  Created by FoneG on 2021/1/4.
//  Copyright © 2021 karosli. All rights reserved.
//

#import "ThridWebView.h"
#import <KKJSBridge/KKJSBridgeSwizzle.h>

@interface ThridWebView () <WKNavigationDelegate>

@end

@implementation ThridWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame configuration:configuration]) {
    }
    return self;
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"ThridWebView didFinishNavigation");
}


@end
