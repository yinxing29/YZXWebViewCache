//
//  FirstViewController.m
//  webView
//
//  Created by 尹星 on 2018/3/22.
//  Copyright © 2018年 尹星. All rights reserved.
//

#import "YZXWebViewController.h"
#import <WebKit/WebKit.h>

@interface YZXWebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView       *webView;

@property (nonatomic, strong) UILabel       *start;
@property (nonatomic, strong) UILabel       *end;
@property (nonatomic, strong) UILabel       *elapsedTime;

@property (nonatomic, strong) NSDateFormatter       *formatter;

@property (nonatomic, strong) NSDate       *startDate;

@property (nonatomic, strong) UIActivityIndicatorView       *indicator;

@end

@implementation YZXWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    self.title = @"WebViewCache";
    
    NSURL *url = [NSURL URLWithString:@"https:www.baidu.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //修改请求方式，使其只请求到responseHeader
    request.HTTPMethod = @"HEAD";
    NSDictionary *cachedHeaders = [[NSUserDefaults standardUserDefaults] objectForKey:url.absoluteString];
    if (cachedHeaders) {
        NSString *etag = [cachedHeaders objectForKey:@"Etag"];
        if (etag) {
            [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
        }
        NSString *lastModified = [cachedHeaders objectForKey:@"Last-Modified"];
        if (lastModified) {
            [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
        }
    }
    
    NSLog(@"------ %f",[[NSDate date] timeIntervalSince1970] * 1000);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"======= %f",[[NSDate date] timeIntervalSince1970] * 1000);
        // 类型转换
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"statusCode == %@", @(httpResponse.statusCode));
        // 判断响应的状态码
        if (httpResponse.statusCode == 304 || httpResponse.statusCode == 0) {
            //如果状态码为304或者0(网络不通?)，则设置request的缓存策略为读取本地缓存
            [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        }else {
            //如果状态码为200，则保存本次的response headers，并设置request的缓存策略为忽略本地缓存，重新请求数据
            [[NSUserDefaults standardUserDefaults] setObject:httpResponse.allHeaderFields forKey:request.URL.absoluteString];
            //如果状态码为200，则设置request的缓存策略为忽略本地缓存
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        }
        
        //未更新的情况下读取缓存
        dispatch_async(dispatch_get_main_queue(), ^{
            //判断结束之后，修改请求方式，加载网页
            request.HTTPMethod = @"GET";
            [self.webView loadRequest:request];
        });
    }] resume];
    
    [self.view addSubview:self.start];
    [self.view addSubview:self.end];
    [self.view addSubview:self.elapsedTime];
}

#pragma mark - <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载开始 %@",[self.formatter stringFromDate:[NSDate date]]);
    self.startDate = [NSDate date];
    self.start.text = [NSString stringWithFormat:@"加载开始 %@",[self.formatter stringFromDate:[NSDate date]]];
    [self.start sizeToFit];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载完成 %@",[self.formatter stringFromDate:[NSDate date]]);
    self.end.text = [NSString stringWithFormat:@"加载完成 %@",[self.formatter stringFromDate:[NSDate date]]];
    [self.end sizeToFit];
    double date1 = [self.startDate timeIntervalSince1970] * 1000;
    double date2 = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"加载耗时 %.0lf ms",date2 - date1);
    self.elapsedTime.text = [NSString stringWithFormat:@"加载耗时： %.0lf ms",date2 - date1];
    [self.elapsedTime sizeToFit];
}

#pragma mark - ------------------------------------------------------------------------------------

#pragma mark - 懒加载
- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UILabel *)start
{
    if (!_start) {
        _start = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 100, 30)];
        _start.textColor = [UIColor redColor];
    }
    return _start;
}

- (UILabel *)end
{
    if (!_end) {
        _end = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 100, 30)];
        _end.textColor = [UIColor redColor];
    }
    return _end;
}

- (UILabel *)elapsedTime
{
    if (!_elapsedTime) {
        _elapsedTime = [[UILabel alloc] initWithFrame:CGRectMake(40, 300, 100, 30)];
        _elapsedTime.textColor = [UIColor redColor];
    }
    return _elapsedTime;
}

- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"HH:mm:ss";
    }
    return _formatter;
}
#pragma mark - ------------------------------------------------------------------------------------

@end
