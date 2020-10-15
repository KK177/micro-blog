//
//  Extension.m
//  weibo
//
//  Created by MacBook pro on 2020/5/14.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "Extension.h"
#import "weiboViewController.h"
#import "searchViewController.h"
#import "collectViewController.h"
#import "myViewController.h"

@implementation Extension
+(void)changeRootViewController
{
    //由于在appdelegate那里已经设置了主窗口所以得要拿到之间设置的主窗口
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //设置tabbar
    UITabBarController *tabVc = [[UITabBarController alloc] init];
    //设置微博主页的view
    weiboViewController *vc1 = [[weiboViewController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    nav1.tabBarItem.title = @"微博";
    nav1.tabBarItem.image = [UIImage imageNamed:@"微博"];
    [tabVc addChildViewController:nav1];
    
    //设置记录主页的view
    searchViewController *vc2 = [[searchViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    nav2.tabBarItem.title = @"记录";
    nav2.tabBarItem.image = [UIImage imageNamed:@"liulanlishi"];
    [tabVc addChildViewController:nav2];
    
    //设置收藏主页的view
    collectViewController *vc3 = [[collectViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    nav3.tabBarItem.title = @"收藏";
    nav3.tabBarItem.image = [UIImage imageNamed:@"收藏"];
    [tabVc addChildViewController:nav3];
    
    //设置个人主页的view
    myViewController *vc4 = [[myViewController alloc] init];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    nav4.tabBarItem.title = @"我";
    nav4.tabBarItem.image = [UIImage imageNamed:@"我"];
    [tabVc addChildViewController:nav4];
    //设置根控制器
    window.rootViewController = tabVc;
}

@end
