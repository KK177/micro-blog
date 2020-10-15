//
//  frameload.m
//  weibo
//
//  Created by MacBook pro on 2020/5/19.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "frameload.h"
#import <UIKit/UIKit.h>
@implementation frameload
//计算高度
-(CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW
{   //创建一个空字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //设置字号的大小
    dict[NSFontAttributeName] = font;
    //设置最大宽度和最大高度
    CGSize maxSize = CGSizeMake(maxW, 1000);
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
}
-(CGSize)sizeWithText:(NSString *)text font:(UIFont *)font
{
    return [self sizeWithText:text font:font maxW:MAXFLOAT];
}
@end
