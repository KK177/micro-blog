//
//  statuses.m
//  weibo
//
//  Created by MacBook pro on 2020/5/16.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "statuses.h"
#import "kkuser.h"
@implementation statuses
+(instancetype)statusesWithDict:(NSDictionary *)dict
{
    statuses *status = [[self alloc] init];
    NSMutableDictionary *dict2 = dict[@"from"];
    NSMutableDictionary *dict1 = dict[@"mblog"];
    status.idstr = dict1[@"idstr"];
    status.text = dict[@"content"];
    status.user = [kkuser userWithDict:dict2[@"extend"]];
    status.created_at = dict[@"pDate"];
    status.pic_urls = dict[@"imageUrls"];
    status.retweeted_status = [self retweetstatusesWithDict:dict1[@"retweeted_status"]];
    int i1 = [dict[@"commentCount"] intValue];
    status.comments_count = i1;
    int i2 = [dict[@"shareCount"] intValue];
    status.reposts_count = i2;
    int i3 = [dict2[@"likeCount"] intValue];
    status.attitudes_count = i3;
    status.videoUrls = dict[@"videoUrls"];
    return status;
}

//转发微博数据的快速赋值
+(statuses *)retweetstatusesWithDict:(NSDictionary *)dict
{
    statuses *retweet = [[self alloc] init];
    retweet.idstr = dict[@"mid"];
    retweet.text = dict[@"text"];
    retweet.user = [kkuser userWithDict:dict[@"user"]];
    retweet.pic_urls = dict[@"pic_urls"];
    retweet.videoUrls = dict[@"videoUrls"];
    return retweet;

}

//不要写set方法（set方法只会在转模型的时候才会访问)
//重写获取时间的get方法
-(NSString *)created_at
{
    //微博返回的时间格式     Tue May 19 14:35:57 +0800 2020
    //对数据进行解析规定格式  EEE MMM dd HH:mm:ss Z yyyy
    NSDateFormatter *ftr = [[NSDateFormatter alloc] init];
    //转换成NSDate的格式
      ftr.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *createTime = [ftr dateFromString:_created_at];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    //这是计算出二者的差值
    NSDateComponents *cps = [calendar components:unit fromDate:createTime toDate:now options:0];
    if([self isthisyear:createTime]){//判断是不是今年
        if([self isyesterday:createTime]){//判断是不是昨天
            ftr.dateFormat = @"昨天 HH:mm";
            return [ftr stringFromDate:createTime];
        }else if([self istoday:createTime]){//判断是不是今天
            if(cps.hour>=1){//判断相差多少
                return [NSString stringWithFormat:@"%ld小时前",(long)cps.hour];
            }else if(cps.minute>=1){
                return [NSString stringWithFormat:@"%ld分钟前",(long)cps.minute];
            }else{
                return @"刚刚";
            }
        }else{
            ftr.dateFormat = @"MM-dd HH:mm";
            return [ftr stringFromDate:createTime];
        }
    }else{
        ftr.dateFormat = @"yyyy-MM-dd HH:mm";
        return [ftr stringFromDate:createTime];
    }
}

//判断微博日期是不是今天
-(BOOL)isthisyear:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //获取年份
    NSDateComponents *kkdate = [calendar components:NSCalendarUnitYear fromDate:date];
    NSDateComponents *nowdate = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return kkdate.year == nowdate.year;
    
}

//判断微博日期是不是昨天
-(BOOL)isyesterday:(NSDate *)date
{
    //获取当前时间
    NSDate *now = [NSDate date];
    NSDateFormatter *change = [[NSDateFormatter alloc] init];
    //将时间格式进行转变
    change.dateFormat = @"yyyy-MM-dd";
    NSString *datestr = [change stringFromDate:date];
    NSString *nowstr = [change stringFromDate:now];
    date = [change dateFromString:datestr];
    now = [change dateFromString:nowstr];
    //进行时间对比
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unit fromDate:date toDate:now options:0];
    return components.year == 0 && components.month == 0 && components.day == 1;
}

//判断微博日期是不是今天
-(BOOL)istoday:(NSDate *)date
{
    //获取当前时间
    NSDate *now = [NSDate date];
    NSDateFormatter *change = [[NSDateFormatter alloc] init];
    //将时间格式进行转变
    change.dateFormat = @"yyyy-MM-dd";
    NSString *datestr = [change stringFromDate:date];
    NSString *nowstr = [change stringFromDate:now];
    return [datestr isEqualToString:nowstr];
}

//重写来源的set方法
-(void)setSource:(NSString *)source
{
    if(![source isEqual:@""]){
        NSRange range;
        range.location = [source rangeOfString:@">"].location + 1;
        range.length = [source rangeOfString:@"</"].location - range.location;
        _source = [NSString stringWithFormat:@"来自 %@",[source substringWithRange:range]];
    }
}

@end
