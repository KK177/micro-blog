//
//  statuses.h
//  weibo
//
//  Created by MacBook pro on 2020/5/16.
//  Copyright © 2020年 kkkak. All rights reserved.
//  微博内容

#import <Foundation/Foundation.h>
#import "kkuser.h"
@interface statuses : NSObject
//微博ID
@property (nonatomic, copy) NSString *idstr;
//显示的文本内容
@property (nonatomic, copy) NSString *text;
//作者的信息
@property (nonatomic, strong) kkuser *user;
//微博创建时间
@property (nonatomic, copy) NSString *created_at;
//微博来源
@property (nonatomic, copy) NSString *source;
//发表的图片
@property (nonatomic, strong) NSArray *pic_urls;
//转发的模型
@property (nonatomic, strong) statuses *retweeted_status;
//转发数
@property (nonatomic, assign) int reposts_count;
//评论数
@property (nonatomic, assign) int comments_count;
//点赞数
@property (nonatomic, assign) int attitudes_count;
//视频
@property (nonatomic, copy) NSArray *videoUrls;
//快速创建
+(instancetype)statusesWithDict:(NSDictionary *)dict;
@end
