//
//  ThirdWebViewController.m
//  KKJSBridgeDemo
//
//  Created by FoneG on 2020/12/30.
//  Copyright © 2020 karosli. All rights reserved.
//

#import "ThirdWebViewController.h"
#import <WebKit/WebKit.h>
#import "ThridWebView.h"
#import <KKJSBridge/KKJSBridge.h>

@interface ThirdWebViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ThirdWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *url = @"https://www.baidu.com";
    
    self.view.backgroundColor = [UIColor whiteColor];
    ThridWebView *webView = [[ThridWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

@end
