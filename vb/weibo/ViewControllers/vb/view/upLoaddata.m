//
//  upLoaddata.m
//  weibo
//
//  Created by MacBook pro on 2020/5/20.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "upLoaddata.h"

@implementation upLoaddata

+(instancetype)setfooter
{
    //这个方法返回的是一个数组 loadNibNamed(加载带xib的控制器)是指要加载的文件名/owner文件拥有者/options加载时需要的数据
    return [[[NSBundle mainBundle] loadNibNamed:@"upLoaddata" owner:nil options:nil] lastObject];
}

////监听按钮的点击
//- (IBAction)button:(UIButton *)sender {
//    //发布通知来监听按钮的点击
//    //发布通知
//    NSNotification *post = [NSNotification notificationWithName:@"dowmloadmore" object:nil];
//    [[NSNotificationCenter defaultCenter]postNotification:post];
//}

@end
