//
//  ViewController.m
//  YZXWebViewCache
//
//  Created by 尹星 on 2018/5/15.
//  Copyright © 2018年 尹星. All rights reserved.
//

#import "ViewController.h"
#import "YZXWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    YZXWebViewController *vc = [[YZXWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
