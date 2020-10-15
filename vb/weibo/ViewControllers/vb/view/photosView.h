//
//  photosView.h
//  weibo
//
//  Created by MacBook pro on 2020/5/30.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface photosView : UIView
@property (nonatomic, strong) NSArray *photosArray;
//图片的缓存处理//
@property (nonatomic,strong)NSMutableDictionary *photosDict;
@property (nonatomic,strong)NSMutableArray *photosA;
//磁盘的缓存处理
@property (nonatomic,copy) NSString *fullpath;
@property (nonatomic,strong) NSMutableArray *cachesA;
//创建队列
@property (nonatomic,strong)NSOperationQueue *queue;
//操作缓存//
@property (nonatomic,strong)NSMutableDictionary *operationDict;
@end
