//
//  picView.m
//  weibo
//
//  Created by MacBook pro on 2020/5/29.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "picView.h"

@implementation picView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor lightGrayColor];
        //初始化按钮
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"tupian"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

//设置子控件的frame
-(void)layoutSubviews
{
    UIButton *btn = self.subviews.lastObject;
    btn.frame = CGRectMake(self.bounds.size.width/3+15, 0, self.bounds.size.width/4, self.bounds.size.height);
}

//监听按钮的点击
-(void)btnClick:(UIButton *)btn
{
    //如果self的代理实现了代理里面的方法就会返回YES
    if([self.delegate respondsToSelector:@selector(clickpicView:)]){
        [self.delegate clickpicView:btn];
    }
}

@end
