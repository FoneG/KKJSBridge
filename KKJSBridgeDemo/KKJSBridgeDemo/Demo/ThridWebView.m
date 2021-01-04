//
//  ThridWebView.m
//  KKJSBridgeDemo
//
//  Created by FoneG on 2021/1/4.
//  Copyright © 2021 karosli. All rights reserved.
//

#import "ThridWebView.h"

@implementation ThridWebView

- (void)dealloc{
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame configuration:configuration]) {
    }
    return self;
}

@end
