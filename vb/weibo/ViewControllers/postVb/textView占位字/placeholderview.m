//
//  placeholderview.m
//  weibo
//
//  Created by MacBook pro on 2020/5/26.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "placeholderview.h"

@implementation placeholderview
//这个方法是对象初始化时都会调用的
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        //文本内容改变时监听通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textchange) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

//文本内容改变时重新绘画文字
-(void)textchange
{
    //重新绘制
    [self setNeedsDisplay];
}

//重写set方法
-(void)setPlaceColor:(UIColor *)placeColor
{
    _placeColor = [placeColor copy];
    //重新绘画一次
    [self setNeedsDisplay];
}
-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    //重新绘画一次
    //setNeedsDisplay这个方法不是一设置就会调用，它是收集好全部信息再重新画一次
    //setNeedsDisplay这个方法是会自动去调用drawRect这个方法的
    [self setNeedsDisplay];
}

//这个方法每次执行会先把之前绘制的去掉
//而且是把要改的信息收集好才会去重新绘画一次
-(void)drawRect:(CGRect)rect
{
    if(!self.hasText){
        //文字的属性
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //dict[NSFontAttributeName]，dict[NSForegroundColorAttributeName]这些是文字属性字典
        dict[NSFontAttributeName] = self.font;
        dict[NSForegroundColorAttributeName] = self.placeColor;
        //画文字(rect是textView的bounds)
        CGRect textRect = CGRectMake(5, 8, rect.size.width, rect.size.height);
        [self.placeholder drawInRect:textRect withAttributes:dict];
    }
}

@end
