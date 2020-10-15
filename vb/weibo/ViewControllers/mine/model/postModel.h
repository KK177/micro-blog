//
//  postModel.h
//  weibo
//
//  Created by kkkak on 2020/5/8.
//  Copyright © 2020 kkkak. All rights reserved.
//  个人主页发说说的model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface postModel : NSObject
//文本内容
@property (nonatomic,copy) NSString *text;
//图片
@property (nonatomic,copy) NSArray *photo;
//判断是否有图片
@property (nonatomic,assign) NSNumber *hasphoto;
//点赞数
@property (nonatomic,copy) NSNumber *clapSum;
//评论数
@property (nonatomic,copy) NSNumber *commentSum;
//转发数
@property (nonatomic,copy) NSNumber *forwardSum;
//view的高度
@property (nonatomic,copy) NSNumber *cellHeight;
//model下标
@property (nonatomic,copy) NSNumber *index;
//快速赋值
+(instancetype)myViewdataWithdict:(NSDictionary *)myViewdict;
@end

NS_ASSUME_NONNULL_END
