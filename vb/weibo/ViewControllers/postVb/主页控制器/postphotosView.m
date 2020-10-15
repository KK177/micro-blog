//
//  postphotosView.m
//  weibo
//
//  Created by MacBook pro on 2020/6/5.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "postphotosView.h"

@implementation postphotosView

-(void)addimageV:(UIImage *) image
{
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.image = image;
    imageV.backgroundColor = [UIColor blueColor];
    [self addSubview:imageV];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //先把数组的总数拿出来，那么就不用经常重新调用get方法
    int count = (int) self.subviews.count;
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

@end
