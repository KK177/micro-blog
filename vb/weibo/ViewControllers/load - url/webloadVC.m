//
//  webloadVC.m
//  weibo
//
//  Created by MacBook pro on 2020/5/25.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "webloadVC.h"
#import "SDAutoLayout.h"

@interface webloadVC ()
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UITableView *tview;
@end
extern NSURL *url;
@implementation webloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
    self.webView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    if(url){
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
