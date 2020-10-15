//
//  statusFrame.m
//  weibo
//
//  Created by MacBook pro on 2020/5/17.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "statusFrame.h"
#import "statuses.h"
#import "kkuser.h"
#import "frameload.h"

@implementation statusFrame

//根据微博的图片数量计算imageView的宽和高
-(CGSize)photosSIzetocount:(int)count
{
    //设置图片的宽高为75，间距为10
    //求行数
    int rows = 0;
    if(count%3==0){
        rows = count / 3;
    }else{
        rows = count / 3 + 1;
    }
    CGFloat photosH = rows * 75 + (rows - 1) * 10;
    //求列数
    int cols = (count>2)?3:count;
    CGFloat photosW = cols * 75 + (cols - 1) * 10;
    
    return CGSizeMake(photosW, photosH);
}

//根据status数据计算控件的frame
-(void)setStatus:(statuses *)status
{
    frameload *frameLoad = [[frameload alloc] init];
    _status = status;
    kkuser *user = status.user;
    //cell的宽度
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    //原创微博
    //头像尺寸
    CGFloat iconX = statusborderW;
    CGFloat iconY = statusborderW;
    CGFloat iconWh = 35;
    self.iconViewFrame = CGRectMake(iconX, iconY, iconWh, iconWh);
    //呢称
    CGFloat nameX = statusborderW + CGRectGetMaxX(self.iconViewFrame);
    CGFloat nameY = iconY;
    CGSize nameSize = [frameLoad sizeWithText:user.name font:statusnameFont];
    self.nameLabelFrame = CGRectMake(nameX, nameY, nameSize.width, nameSize.height);
    //时间
    CGFloat timeX = nameX;
    CGFloat timeY = CGRectGetMaxY(self.nameLabelFrame) + statusborderW;
    CGSize timeSize = [frameLoad sizeWithText:status.created_at font:statustimeFont];
    self.timeLabelFrame = CGRectMake(timeX, timeY, timeSize.width, timeSize.height);
    //来源
    CGFloat sourceX = CGRectGetMaxX(self.timeLabelFrame) + statusborderW;
    CGFloat sourceY = timeY;
    CGSize sourceSize = [frameLoad sizeWithText:status.source font:statussourceFont];
    self.sourceLabelFrame = CGRectMake(sourceX, sourceY, sourceSize.width, sourceSize.height);
    //正文
    CGFloat contentX = iconX;
    CGFloat contentY = MAX(CGRectGetMaxY(self.iconViewFrame), CGRectGetMaxY(self.timeLabelFrame)) + statusborderW;
    CGFloat maxW = cellW - 2 * contentX ;
    CGSize contentSize = [frameLoad sizeWithText:status.text font:statuscontentFont maxW:maxW];
    self.contentLabelFrame = CGRectMake(contentX, contentY, contentSize.width, contentSize.height);
    //配图
    CGFloat originalH = 0;
    if (status.pic_urls != nil && ![status.pic_urls isKindOfClass:[NSNull class]] && status.pic_urls.count != 0){
        //有图片
        CGSize photoS = [self photosSIzetocount:(int)status.pic_urls.count];
        CGFloat photoX = contentX;
        CGFloat photoY = CGRectGetMaxY(self.contentLabelFrame) + statusborderW;
        self.photoViewsFrame = CGRectMake(photoX, photoY, photoS.width, photoS.height);
        originalH = CGRectGetMaxY(self.photoViewsFrame) + statusborderW;
    }else{
        //没图片
        originalH = CGRectGetMaxY(self.contentLabelFrame) + statusborderW;
    }
    //整个原创微博cell
    CGFloat originalX = 0;
    CGFloat originalY = 15;
    CGFloat originalW = cellW;
    self.myViewFrame = CGRectMake(originalX, originalY, originalW, originalH);

    //toolView的y值
    CGFloat toolViewY = 0;
    //转发微博(转发微博跟原创微博是独立开的)
    if(status.retweeted_status.idstr){
        statuses *retweeted_status = status.retweeted_status;
        kkuser *retweeted_status_user = retweeted_status.user;
        
        //正文内容
        NSString *str = [NSString stringWithFormat:@"@%@ : %@",retweeted_status_user.name,retweeted_status.text];
        CGFloat textX = statusborderW;
        CGFloat textY = statusborderW;
        CGSize textS = [frameLoad sizeWithText:str font:statusretweetcontentFont maxW:maxW];
        self.retweetContentViewFrame = CGRectMake(textX, textY, textS.width, textS.height);
        //配图
        CGFloat retweetH = 0;
        if (retweeted_status.pic_urls != nil && ![retweeted_status.pic_urls isKindOfClass:[NSNull class]] && retweeted_status.pic_urls.count != 0){
            CGSize retphotoS = [self photosSIzetocount:(int)retweeted_status.pic_urls.count];
            CGFloat retweetphotoX = textX;
            CGFloat retweetphotoY = CGRectGetMaxY(self.retweetContentViewFrame) + statusborderW;
            self.retweetPhotoViewsFrame = CGRectMake(retweetphotoX, retweetphotoY, retphotoS.width, retphotoS.height);
            retweetH = CGRectGetMaxY(self.retweetPhotoViewsFrame) + statusborderW;
        }else{
            retweetH = CGRectGetMaxY(self.retweetContentViewFrame) + statusborderW;
        }
        //转发微博整体
        CGFloat retweetX = 0;
        CGFloat retweetY = CGRectGetMaxY(self.myViewFrame);
        CGFloat retweetW = cellW;
        self.retweetViewFrame = CGRectMake(retweetX, retweetY, retweetW, retweetH);
        toolViewY = CGRectGetMaxY(self.retweetViewFrame) + 1;
    }else{
        toolViewY = CGRectGetMaxY(self.myViewFrame) + 1;
    }
    
    //工具条
    CGFloat toolViewX = 0;
    CGFloat toolViewW = cellW;
    CGFloat toolViewH = 35;
    self.toolViewFrame = CGRectMake(toolViewX, toolViewY, toolViewW, toolViewH);
    
    self.cellHeight = CGRectGetMaxY(self.toolViewFrame);
}

@end
