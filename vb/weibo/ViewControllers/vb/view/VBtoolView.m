//
//  VBtoolView.m
//  weibo
//
//  Created by MacBook pro on 2020/5/19.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "VBtoolView.h"
#import "statuses.h"
@interface VBtoolView()
@property (nonatomic, weak) UIButton *repostsbtn;
@property (nonatomic, weak) UIButton *commentsbtn;
@property (nonatomic, weak) UIButton *attitudesbtn;
@end
@implementation VBtoolView

//供外部调用的类方法
+(instancetype)toolView
{
    return [[self alloc] init];
}

//工具条内部三个按钮的初始化
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        //初始化按钮
        self.repostsbtn =  [self button:@"转发" icon:@"fenxiang"];
        self.commentsbtn = [self button:@"评论" icon:@"pinglun"];
        self.attitudesbtn = [self button:@"点赞" icon:@"zan"];
    }
    return self;
}

//将初始化按钮的方法封装起来
//初始化按钮的点赞评论转发图标
-(UIButton *)button:(NSString *)title icon:(NSString *)icon
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    //设置偏移量
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:btn];
    return btn;
}

//工具条子控件的frame（系统自带的）
-(void)layoutSubviews
{
    [super layoutSubviews];
    int count = (int)self.subviews.count;
    CGFloat toolH = self.bounds.size.height;
    CGFloat toolW = self.bounds.size.width / count;
    for(int i=0;i<count;i++){
        UIButton *tool = self.subviews[i];
        tool.frame = CGRectMake(i*toolW, 0, toolW, toolH);
    }
}

//根据status提供的数据来更新点赞评论转发数
-(void)setStatus:(statuses *)status
{
    [self setUpcount:status.reposts_count btn:self.repostsbtn title:@"转发"];
    
    [self setUpcount:status.comments_count btn:self.commentsbtn title:@"评论"];
    
    [self setUpcount:status.attitudes_count btn:self.attitudesbtn title:@"点赞"];
}
//设置数目
-(void)setUpcount:(int)count btn:(UIButton *)btn title:(NSString *)title
{
    if(count){
        if(count < 10000){
            title = [NSString stringWithFormat:@"%d",count];
        }else{
            double kcount = count / 10000.0;
            title = [NSString stringWithFormat:@"%.1f万",kcount];
            //把显示.0的去掉
            title = [title stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }
    }
    [btn setTitle:title forState:UIControlStateNormal];
}
@end
