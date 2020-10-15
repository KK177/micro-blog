//
//  postModel.m
//  weibo
//
//  Created by kkkak on 2020/5/8.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "postModel.h"

@implementation postModel
+(instancetype)myViewdataWithdict:(NSDictionary *)myViewdict
{
    postModel *myViewdata = [[self alloc] init];
    [myViewdata setValuesForKeysWithDictionary:myViewdict];
    return myViewdata;
}
@end
