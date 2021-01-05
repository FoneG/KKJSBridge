//
//  KKJSBridgeWebViewPointer.m
//  KKJSBridge
//
//  Created by FoneG on 2021/1/4.
//

#import "KKJSBridgeWebViewPointer.h"

@implementation KKJSBridgeWebViewPointer
{
    dispatch_semaphore_t _lock;
    NSHashTable *_enqueueWebViews;
}

+ (instancetype)shared{
    static KKJSBridgeWebViewPointer *pointer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointer = [[KKJSBridgeWebViewPointer alloc] init];
    });
    return pointer;;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _enqueueWebViews = [NSHashTable weakObjectsHashTable];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)enter:(WKWebView *)webview{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([_enqueueWebViews containsObject:webview]) {
        return;
    }
    [_enqueueWebViews addObject:webview];
    dispatch_semaphore_signal(_lock);
}

- (void)clear:(WKWebView *)webview{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([_enqueueWebViews containsObject:webview]) {
        [_enqueueWebViews removeObject:webview];
    }
    dispatch_semaphore_signal(_lock);
}

- (NSHashTable<WKWebView *> *)enqueueWebViews{
    NSHashTable *copyTable = [NSHashTable weakObjectsHashTable];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [copyTable unionHashTable:_enqueueWebViews];
    dispatch_semaphore_signal(_lock);
    return copyTable;
}

@end
