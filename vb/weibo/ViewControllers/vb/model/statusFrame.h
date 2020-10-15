//
//  statusFrame.h
//  weibo
//
//  Created by MacBook pro on 2020/5/17.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class statuses;
#define statusborderW 10
//呢称字体大小
#define statusnameFont [UIFont systemFontOfSize:15]
//时间字体大小
#define statustimeFont [UIFont systemFontOfSize:12]
//来源字体
#define statussourceFont [UIFont systemFontOfSize:12]
//正文字体
#define statuscontentFont [UIFont systemFontOfSize:12]
//转发微博正文字体
#define statusretweetcontentFont [UIFont systemFontOfSize:12]
@interface statusFrame : NSObject
@property (nonatomic, strong) statuses *status;
//原创微博
//整体view
@property (nonatomic, assign) CGRect myViewFrame;
//头像
@property (nonatomic, assign) CGRect iconViewFrame;
//发表的图片
@property (nonatomic, assign) CGRect photoViewsFrame;
//时间
@property (nonatomic, assign) CGRect timeLabelFrame;
//呢称
@property (nonatomic, assign) CGRect nameLabelFrame;
//来源
@property (nonatomic, assign) CGRect sourceLabelFrame;
//文章内容
@property (nonatomic, assign) CGRect contentLabelFrame;

//转发微博整体
@property (nonatomic, assign) CGRect retweetViewFrame;
//转发微博正文
@property (nonatomic, assign) CGRect retweetContentViewFrame;
//转发微博配图
@property (nonatomic, assign) CGRect retweetPhotoViewsFrame;


//工具条
@property (nonatomic, assign) CGRect toolViewFrame;
//cell的高度
@property (nonatomic, assign) CGFloat cellHeight;


@end
