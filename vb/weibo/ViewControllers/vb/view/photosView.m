//
//  photosView.m
//  weibo
//
//  Created by MacBook pro on 2020/5/30.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "photosView.h"

@interface photosView()


@end
extern NSString *idstr;
@implementation photosView
//懒加载操作缓存字典//
-(NSMutableDictionary *)operationDict
{
    if(!_operationDict){
        _operationDict = [NSMutableDictionary dictionary];
    }
    return _operationDict;
}
//队列的懒加载
-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}
//懒加载caches数组
-(NSMutableArray *)cachesA
{
    if(!_cachesA){
        _cachesA = [NSMutableArray array];
    }
    return _cachesA;
}
//懒加载caches全路径
-(NSString *)fullpath
{
    if (_fullpath == nil || _fullpath == NULL){
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        _fullpath = [caches stringByAppendingString:idstr];
    }
    return _fullpath;
}
//懒加载缓存字典//
-(NSMutableDictionary *)photosDict
{
    if(!_photosDict){
        _photosDict = [NSMutableDictionary dictionary];
    }
    return _photosDict;
}
-(NSMutableArray *)photosA
{
    if(!_photosA){
        _photosA = [NSMutableArray array];
    }
    return _photosA;
}
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
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _photosArray = photosArray;
    //取出图片数组的总数
    int count =  photosArray.count;

    //创建足够多的imageView来存储照片
    while (self.subviews.count<count) {
        UIImageView *imagev = [[UIImageView alloc] init];
        [self addSubview:imagev];
    }
    //给每一个imageView添加图片
    int subcount = self.subviews.count;
    for (int i=0; i<self.subviews.count; i++) {
        UIImageView *photoV = self.subviews[i];
        if (i<count) {
            //先看看内存缓存里是否已经有数据
            NSArray *array = [_photosDict objectForKey:idstr];
            //内存缓存里有数据
            if (array != nil && ![array isKindOfClass:[NSNull class]] && array.count != 0){
                photoV.image = array[i];
            }else{
                //内存缓存里没有数据
                //看看磁盘缓存里是否有数据
                NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
               NSString *str = _photosArray[i];
                NSString *filename = [str lastPathComponent];
                //拼接caches缓存的全路径
                NSString *fullPath = [caches stringByAppendingString:filename];
                //检查磁盘缓存里有没有数据
                NSData *photoData = [NSData dataWithContentsOfFile:fullPath];
                //磁盘缓存里存在数据
                if (photoData) {
                    NSLog(@"磁盘缓存");
                    photoV.image = [UIImage imageWithData:photoData];
                }else{
                    //磁盘缓存里没有数据
                    //看看下载操作是否在缓存中
                    //检测下载操作是否在缓存里
                    NSBlockOperation *download = [self.operationDict objectForKey:[str lastPathComponent]];
                    //下载操作在缓存中
                    if (download) {
                        return;
                    }else{
                        //下载操作不在缓存中
                        //启动下载
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            NSData *imagedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
                            UIImage *image = [UIImage imageWithData:imagedata];
                            //线程间通信
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                photoV.image = image;
                            }];
                            //把下载好的图片保存到缓存里
                            [self->_photosA addObject:image];
                            //把图片的data保存到磁盘上
                            [imagedata writeToFile:fullPath atomically:YES];
                            //下载完之后删除操作缓存
                            [self.operationDict removeObjectForKey:[str lastPathComponent]];
                            //把该微博的图片保存到字典里
                            if (i == subcount-1) {
                                [self.photosDict setObject:self.photosA forKey:idstr];
                            }


                        }];
                        //添加操作到缓存中
                        [self.operationDict setObject:operation forKey:[str lastPathComponent]];
                        //把线程加入到队列中
                        [self.queue addOperation:operation];
                    }
                }

            }
        }else{
            //隐藏多余的imageView
            photoV.hidden = YES;
        }
    }
}

//设置子控件imageView的尺寸
-(void)layoutSubviews
{
    [super layoutSubviews];
    //先把数组的总数拿出来，那么就不用经常重新调用get方法
    int count =  _photosArray.count;
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
