//
//  kkuser.h
//  weibo
//
//  Created by MacBook pro on 2020/5/16.
//  Copyright © 2020年 kkkak. All rights reserved.
//  微博用户信息

#import <Foundation/Foundation.h>

@interface kkuser : NSObject
//用户ID
@property (nonatomic, copy) NSString *idstr;
//显示的名称
@property (nonatomic, copy) NSString *name;
//头像的url
@property (nonatomic ,copy) NSString *profile_image_url;
//快速创建
+(instancetype)userWithDict:(NSDictionary *)dict;
@end
