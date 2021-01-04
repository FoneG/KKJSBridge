//
//  ThirdWebViewController.m
//  KKJSBridgeDemo
//
//  Created by FoneG on 2020/12/30.
//  Copyright © 2020 karosli. All rights reserved.
//

#import "ThirdWebViewController.h"
#import <WebKit/WebKit.h>
#import "A.h"
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
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

@end
