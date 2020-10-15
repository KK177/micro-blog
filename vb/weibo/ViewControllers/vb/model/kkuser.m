//
//  kkuser.m
//  weibo
//
//  Created by MacBook pro on 2020/5/16.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "kkuser.h"

@implementation kkuser
+(instancetype)userWithDict:(NSDictionary *)dict
{
    kkuser *user = [[self alloc] init];
    user.idstr = dict[@"idstr"];
    user.name = dict[@"screen_name"];
    user.profile_image_url = dict[@"profile_image_url"];
    return user;
}
@end
