//
//  myphotosView.m
//  weibo
//
//  Created by MacBook pro on 2020/6/5.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "myphotosView.h"

@implementation myphotosView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//根据传进来的照片数据来创建足够多的imageView
-(void)setPhotosArray:(NSArray *)photosArray
{
    _photosArray = photosArray;
    //先把数组的总数拿出来，那么就不用经常重新调用get方法
    int count = (int) photosArray.count;
    //创建足够多的imageView来显示图片
    while (self.subviews.count<count) {
        UIImageView *imageV = [[UIImageView alloc] init];
        [self addSubview:imageV];
    }
    //给设置好的imageV添加图片
    for (int i=0; i<self.subviews.count; i++) {
        UIImageView *photoV = self.subviews[i];
        if(i<count){
            photoV.hidden = NO;
            photoV.image = photosArray[i];
        }else{
            //多余的imageV就把它隐藏
            photoV.hidden = YES;
        }
    }
}

//设置子控件imageView的尺寸
-(void)layoutSubviews
{
    [super layoutSubviews];
    //先把数组的总数拿出来，那么就不用经常重新调用get方法
    int count = (int) _photosArray.count;
    //这是只有四张图片的时候
    if(count==4){
        for (int i=0; i<count; i++) {
            UIImageView *photoV = self.subviews[i];
            //设置图片的宽高为75，间距为10
            int col = i%2;
            CGFloat photoX = col * (75+10);
            int row = i/2;
            CGFloat photoY = row *(75+10);
            photoV.frame = CGRectMake(photoX, photoY, 75, 75);
        }
    }else{
        for (int i=0; i<count; i++) {
            UIImageView *photoV = self.subviews[i];
            //设置图片的宽高为75，间距为10
            int col = i%3;
            CGFloat photoX = col * (75+10);
            int row = i/3;
            CGFloat photoY = row *(75+10);
            photoV.frame = CGRectMake(photoX, photoY, 75, 75);
    }
    }
}

@end
