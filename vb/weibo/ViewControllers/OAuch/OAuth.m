//
//  OAuth.m
//  weibo
//
//  Created by MacBook pro on 2020/5/12.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "OAuth.h"
#import "Extension.h"
#import "AFNetworking.h"

@interface OAuth ()<UIWebViewDelegate>
@property (strong,nonatomic)UIWebView *webView;
@end

@implementation OAuth

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.delegate = self;
    [self.view addSubview:self.webView];
    //给webView添加约束
    NSDictionary *views = @{@"webView":_webView,
                            @"view":self.view
                            };
    //水平约束
    NSString *hcls = @"H:|-0-[webView(==view)]-0-|";
    NSArray *webhlcs = [NSLayoutConstraint constraintsWithVisualFormat:hcls options:kNilOptions metrics:nil views:views];
    [self.view addConstraints:webhlcs];
    //垂直方向上
    NSString *vstr = @"V:|-0-[webView(==view)]-0-|";
    NSArray *webvlcs = [NSLayoutConstraint constraintsWithVisualFormat:vstr options:kNilOptions metrics:nil views:views];
    [self.view addConstraints:webvlcs];
    
    //利用webView来加载新浪微博的登录页面
    //请求地址:https://api.weibo.com/oauth2/authorize
    //传递参数:client_id:2272197617 回调地址:redirect_uri:http://www.baidu.com
    NSURL *url = [NSURL URLWithString:@"https://api.weibo.com/oauth2/authorize?client_id=2272197617&redirect_uri=http://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //拦截webView的请求
    //拦截code来换取访问授权
    NSString *url = request.URL.absoluteString;
    //rangeOfString方法返回的是NSRange的结构体
    NSRange range = [url rangeOfString:@"code="];
    //截取code
    if(range.length != 0)
    {
        long int index = range.location + range.length;
        NSString *code = [url substringFromIndex:index];
        [self accessTocode:code];
        //不需要再去加载request（因为已经拿到了access_token)
        return NO;
    }
    return YES;
}

-(void)accessTocode:(NSString *)code
{
    //创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *dict = @{
                           @"client_id":@"2272197617",
                           @"client_secret":@"1118f6abb988342d2cbe19b5cad15c7a",
                           @"grant_type":@"authorization_code",
                           @"redirect_uri":@"http://www.baidu.com",
                           @"code":code
                           };
    //发送POST请求
    [manager POST:@"https://api.weibo.com/oauth2/access_token" parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //获取沙盒路径
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
            NSString *filepath = [path stringByAppendingPathComponent:@"account.plist"];
            [responseObject writeToFile:filepath atomically:YES];
//            //当启动完下载后再回到主线程调用tableView刷新的方法
//            [self performSelectorOnMainThread:@selector(changeController) withObject:nil waitUntilDone:YES];
            [self changeController];
        }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"请求失败");
     }];
}
-(void)changeController
{
    //切换根控制器
    [Extension changeRootViewController];
}

@end
