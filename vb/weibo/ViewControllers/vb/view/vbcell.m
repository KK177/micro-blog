//
//  vbcell.m
//  weibo
//
//  Created by MacBook pro on 2020/5/16.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "vbcell.h"
#import "statuses.h"
#import "statusFrame.h"
#import "kkuser.h"
#import "VBtoolView.h"
#import "frameload.h"
#import "photosView.h"
#import <UIKit/UIKit.h>
#import "SDAutoLayout.h"
#import <AVKit/AVKit.h>

@interface vbcell()<UITextViewDelegate>
//原创微博
//整体view
@property (nonatomic,weak) UIView *myView;
//头像
@property (nonatomic,weak) UIImageView *iconView;
//发表的图片
@property (nonatomic,weak) photosView *photosview;
//时间
@property (nonatomic,weak) UILabel *timeLabel;
//呢称
@property (nonatomic,weak) UILabel *nameLabel;
//来源
@property (nonatomic,weak) UILabel *sourceLabel;
//文章内容
@property (nonatomic,weak) UITextView *textView;
//视频
@property (nonatomic,weak) UIView *videoview;

//转发微博
//转发微博整体
@property (nonatomic, weak) UIView *retweetView;
//转发微博正文和呢称
@property (nonatomic, weak) UITextView *retweetContentView;
//转发微博配图
@property (nonatomic, weak) photosView *retweetPhotosView;
//视频
@property (nonatomic, weak) UIView *retweetvideoView;

//收藏栏
@property (nonatomic, weak) UIButton *collectbtn;
//工具条
@property (nonatomic, weak) VBtoolView *toolView;


//队列的懒加载//
@property (nonatomic ,strong) NSOperationQueue *queue;

//下载操作的懒加载//
@property (nonatomic ,strong) NSMutableDictionary *operationDict;
@end

//点击微博上的url时进行传值用于webView加载
NSURL *url;
NSString *idstr;
//传递cell的下标
extern  NSInteger cellindex;;
//视频的str
NSString *videostr;
@implementation vbcell
//懒加载操作缓存字典//
-(NSMutableDictionary *)operationDict
{
    if(!_operationDict){
        _operationDict = [NSMutableDictionary dictionary];
    }
    return _operationDict;
}
//懒加载队列//
-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}
//懒加载字典//
-(NSMutableDictionary*)icondict
{
    if (!_icondict) {
        _icondict = [NSMutableDictionary dictionary];
    }
    return _icondict;
}
//创建cell
+(instancetype)cellWithtableView:(UITableView *)tableView
{
    static NSString *cellID = @"dataID";
    vbcell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[vbcell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    return cell;
}

//cell的初始化方法，一个cell只会调用一次
//在这里添加所有可能显示的子控件以及子控件的固定的设置
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        //初始化原创微博
        [self setUporiginal];
        //初始化转发微博
        [self setUpretweet];
        //初始化工具条
        [self setUptool];
    }
    return self;
}

//初始化原创微博
-(void)setUporiginal
{
    //微博整体view
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:myView];
    self.myView = myView;
    //头像
    UIImageView *iconView = [[UIImageView alloc] init];
    [myView addSubview:iconView];
    self.iconView = iconView;
    //发表的图片
    photosView *photosview = [[photosView alloc] init];
    [myView addSubview:photosview];
    self.photosview = photosview;
    //时间
    UILabel *timeLabel = [[UILabel alloc] init];
    //设置时间的字体
    timeLabel.textColor = [UIColor orangeColor];
    timeLabel.font = statustimeFont;
    [myView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    //呢称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = statusnameFont;
    [myView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    //来源
    UILabel *sourceLabel = [[UILabel alloc] init];
    sourceLabel.font = statussourceFont;
    [myView addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    //文本内容
    UITextView *textview = [[UITextView alloc] init];
    textview.font = statuscontentFont;
    textview.textContainerInset = UIEdgeInsetsZero;
    textview.textContainer.lineFragmentPadding = 0;
    [myView addSubview:textview];
    self.textView = textview;
    //视频
    UIView *videoV = [[UIView alloc] init];
    //videoV.backgroundColor = [UIColor lightGrayColor];
    videoV.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1];
    [self.myView addSubview:videoV];
    _videoview = videoV;
}

//初始化转发微博
-(void)setUpretweet
{
    //转发微博整体view
    UIView *retweetView = [[UIView alloc] init];
    retweetView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:retweetView];
    self.retweetView = retweetView;
    //文本内容
    UITextView *retweetContentView = [[UITextView alloc] init];
    
    retweetContentView.font = statusretweetcontentFont;
    //UITextView中有一个textContainer(用来展示文本)默认情况下 container与textView上下有8的边距
    //设置textView的上下边距为0
    retweetContentView.textContainerInset = UIEdgeInsetsZero;
    //而container里面的字段上下左右都默认有5的空白段
    retweetContentView.textContainer.lineFragmentPadding = 0;
    [retweetView addSubview:retweetContentView];
    self.retweetContentView = retweetContentView;
    //发表的图片
    photosView *retweetPhotosView = [[photosView alloc] init];
    [retweetView addSubview:retweetPhotosView];
    self.retweetPhotosView = retweetPhotosView;
    //视频
    UIView *rvideoV = [[UIView alloc] init];
    rvideoV.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1];
    [self.retweetView addSubview:rvideoV];
    _retweetvideoView = rvideoV;
}

//初始化工具条
-(void)setUptool
{
    VBtoolView *toolView = [[VBtoolView alloc] init];
    [self.contentView addSubview:toolView];
    self.toolView = toolView;
}

//给控件的frame赋值
-(void)setStatusFrame:(statusFrame *)statusFrame
{

    
    _statusFrame = statusFrame;
    statuses *status = statusFrame.status;
    kkuser *user = status.user;

    //头像
    self.iconView.sd_layout
    .leftSpaceToView(self.myView, 10)
    .topSpaceToView(self.myView, 10)
    .widthIs(35)
    .heightIs(35);
    
    //先判断缓存里是否已经下载好这张图片
    UIImage *image = [self.icondict objectForKey:status.user.name];
    if(image){
        self.iconView.image = image;
    }else{
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        NSString *filename = [user.profile_image_url lastPathComponent];
        //拼接caches缓存的全路径
        NSString *fullPath = [caches stringByAppendingString:filename];
        
        //检查磁盘缓存里有没有数据
        NSData *iconData = [NSData dataWithContentsOfFile:fullPath];
        if(iconData){
            //磁盘缓存中已存在数据
            self.iconView.image = [UIImage imageWithData:iconData];
        }else{
            //磁盘缓存中不存在数据
            NSString *imageUrl = user.profile_image_url;
            //先判断缓存中是否有下载操作
            NSBlockOperation *operation = [self.operationDict objectForKey:[imageUrl lastPathComponent]];
            if (operation) {
                return;
            }else{
                //实现异步下载图片
                    operation = [NSBlockOperation blockOperationWithBlock:^{
                    NSData *imagedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                    UIImage *image = [UIImage imageWithData:imagedata];
                    //线程间通信（imageView设置image要在主线程中进行）
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        self.iconView.image = image;
                    }];
                    //把图片保存到内存缓存里面
                    [self.icondict setObject:image forKey:status.user.name];
                    
                    //写数据到沙盒里面
                    [imagedata writeToFile:fullPath atomically:YES];
                    
                    //删除下载操作缓存
                    [self.operationDict removeObjectForKey:[imageUrl lastPathComponent]];
                }];
                //添加操作到缓存中
                [_operationDict setObject:operation forKey:[imageUrl lastPathComponent]];
                //把线程加入到队列中
                [self.queue addOperation:operation];
            }
            }
    }
    
    //呢称
    self.nameLabel.text = user.name;
    self.nameLabel.sd_layout
    .leftSpaceToView(self.iconView, 10)
    .topEqualToView(self.iconView)
    .widthIs(200)
    .autoHeightRatio(0);


    //时间
    frameload *frameLoad = [[frameload alloc] init];
    self.timeLabel.text = status.created_at;
    CGSize newtimeFrame = [frameLoad sizeWithText:status.created_at font:statustimeFont];
    //添加约束
    self.timeLabel.sd_layout
    .leftSpaceToView(self.iconView, 10)
    .topSpaceToView(self.nameLabel, 10)
    .widthIs(newtimeFrame.width)
    .autoHeightRatio(0);
    

    //来源
    CGSize sourceFrame = [frameLoad sizeWithText:status.source font:statussourceFont];
    //添加约束
    self.sourceLabel.text = status.source;
    self.sourceLabel.sd_layout
    .leftSpaceToView(self.timeLabel, 10)
    .topEqualToView(self.timeLabel)
    .widthIs(sourceFrame.width)
    .autoHeightRatio(0);

    //正文
    self.textView.delegate = self;
    self.textView.text = status.text;
    self.textView.editable = NO;
    NSString *str = @"http";
    if([status.text rangeOfString:str].location!=NSNotFound){
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:self.textView.text];
        NSArray *array = [self getURLFromStr:status.text];
        for(int i=0;i<array.count;i++){
            NSString *str1 = array[i];
            str1 = [str1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:str1];
            if([url isEqual:nil]){
            }else{
                [attrStr addAttribute:NSLinkAttributeName value:url range:[self.textView.text rangeOfString:str1]];
            }
        }
        self.textView.attributedText = attrStr;
        self.textView.editable = NO;
    }
    CGSize contentSize = [frameLoad sizeWithText:status.text font:[UIFont systemFontOfSize:12] maxW:[UIScreen mainScreen].bounds.size.width-20];
    //添加约束
    self.textView.sd_layout
    .leftSpaceToView(self.myView, 10)
    .topSpaceToView(self.timeLabel, 10)
    .widthIs(contentSize.width)
    .heightIs(contentSize.height);


    //发表的图片
    if (status.pic_urls != nil && ![status.pic_urls isKindOfClass:[NSNull class]] && status.pic_urls.count != 0){
        self.photosview.frame = statusFrame.photoViewsFrame;
        idstr = status.idstr;
        self.photosview.photosArray = status.pic_urls;
        self.photosview.hidden = NO;
        self.videoview.hidden = YES;
    }else{
        self.photosview.hidden = YES;
        
        if (status.videoUrls != nil && ![status.videoUrls isKindOfClass:[NSNull class]] && status.videoUrls.count != 0) {
            
                    self.videoview.sd_layout
                    .topSpaceToView(self.textView, 10)
                    .leftSpaceToView(self.myView, 10)
                    //.bottomSpaceToView(self.myView,10)
                    .widthIs(200)
                    .heightIs(100);
            
            
            //初始化按钮
            UIButton *clickplay = [UIButton buttonWithType:UIButtonTypeSystem];
            clickplay.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1];
            clickplay.frame = CGRectMake(75, 35,50 ,30 );
            clickplay.tag = cellindex;
            [clickplay setImage:[UIImage imageNamed:@"bofang3"] forState:UIControlStateNormal];
            [clickplay addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            [self.videoview addSubview:clickplay];
            self.videoview.hidden = NO;
        }else{
            self.videoview.hidden = YES;
        }
    }

//改动
    //整体原创微博view
    self.myView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(self.contentView, 15);
     if (status.pic_urls != nil && ![status.pic_urls isKindOfClass:[NSNull class]] && status.pic_urls.count != 0){
        [self.myView setupAutoHeightWithBottomView:self.photosview bottomMargin:10];
    }else{
        if (status.videoUrls != nil && ![status.videoUrls isKindOfClass:[NSNull class]] && status.videoUrls.count != 0){
            [self.myView setupAutoHeightWithBottomView:self.videoview bottomMargin:10];
        }else{
            [self.myView setupAutoHeightWithBottomView:self.textView bottomMargin:10];
            
         
        }
    }
   
    
    //转发微博
    if(status.retweeted_status.user.idstr){
        statuses *retweeted_status = status.retweeted_status;
        kkuser *retweeted_status_user = retweeted_status.user;

        //正文
        NSString *str = [NSString stringWithFormat:@"@%@ : %@",retweeted_status_user.name,retweeted_status.text];
        self.retweetContentView.text = str;
        self.retweetContentView.delegate = self;
        
        //设置名字的富文本
         NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:self.retweetContentView.text];
        NSString *name = [@"@" stringByAppendingString:retweeted_status.user.name];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:[self.retweetContentView.text rangeOfString:name]];
        //设置链接的富文本
        if([retweeted_status.text rangeOfString:@"http"].location!=NSNotFound){
            NSArray *array = [self getURLFromStr:retweeted_status.text];
            for(int i=0;i<array.count;i++){
                NSString *str1 = array[i];
                NSURL *url = [NSURL URLWithString:str1];
                [attrStr addAttribute:NSLinkAttributeName value:url range:[self.retweetContentView.text rangeOfString:str1]];
            }
        }
        self.retweetContentView.editable = NO;
        self.retweetContentView.attributedText = attrStr;
        CGSize textS = [frameLoad sizeWithText:str font:statusretweetcontentFont maxW:[UIScreen mainScreen].bounds.size.width-20];
        //添加约束
        self.retweetContentView.sd_layout
        .leftSpaceToView(self.retweetView, 10)
        .topSpaceToView(self.retweetView, 10)
        .widthIs(textS.width)
        .heightIs(textS.height);
        
     
        //发表的图片
         if (retweeted_status.pic_urls != nil && ![retweeted_status.pic_urls isKindOfClass:[NSNull class]] && retweeted_status.pic_urls.count != 0){
            self.retweetPhotosView.frame = statusFrame.retweetPhotoViewsFrame;
            self.retweetPhotosView.photosArray = retweeted_status.pic_urls;
            self.retweetPhotosView.hidden = NO;
             self.retweetvideoView.hidden = YES;
        }else{
            self.retweetPhotosView.hidden = YES;
       
             if (retweeted_status.videoUrls != nil && ![retweeted_status.videoUrls isKindOfClass:[NSNull class]] && retweeted_status.videoUrls.count != 0){
                
                self.retweetvideoView.sd_layout
                .topSpaceToView(self.retweetContentView, 10)
                .leftSpaceToView(self.retweetView, 10)
                //.bottomSpaceToView(self.myView,10)
                .widthIs(200)
                .heightIs(100);
                 //初始化按钮
                 UIButton *clickplay = [UIButton buttonWithType:UIButtonTypeSystem];
                 clickplay.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1];
                 clickplay.frame = CGRectMake(75, 35,50 ,30 );
                 clickplay.tag = cellindex;
                 [clickplay setImage:[UIImage imageNamed:@"bofang3"] forState:UIControlStateNormal];
                 [clickplay addTarget:self action:@selector(retweetclick:) forControlEvents:UIControlEventTouchUpInside];
                 [self.videoview addSubview:clickplay];
                self.retweetvideoView.hidden = NO;
                
            }else{
                self.retweetContentView.hidden = YES;
            }
        }
        //转发微博整体
        self.retweetView.hidden = NO;
        self.retweetView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(self.myView, 0);
        if (retweeted_status.pic_urls.count) {
            [self.retweetView setupAutoHeightWithBottomView:self.retweetPhotosView bottomMargin:10];
        }else{
            
            if (retweeted_status.videoUrls != nil && ![retweeted_status.videoUrls isKindOfClass:[NSNull class]] && retweeted_status.videoUrls.count != 0){
                [self.myView setupAutoHeightWithBottomView:self.retweetvideoView bottomMargin:10];
            }else{
                [self.retweetView setupAutoHeightWithBottomView:self.retweetContentView bottomMargin:10];
            }
        }
        //工具条
        self.toolView.status = status;
        
       
        [self.retweetView updateLayout];
        
        //工具条的约束
        self.toolView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .topSpaceToView(self.retweetView,1)
        //.bottomEqualToView(self.contentView)
        .rightSpaceToView(self.contentView, 0)
        .heightIs(35);
        
    }else{
        self.retweetView.hidden = YES;
        //工具条
        self.toolView.status = status;
        //工具条的约束
        self.toolView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .topSpaceToView(self.myView, 1)
        .rightSpaceToView(self.contentView, 0)
        .heightIs(35);
    }

    [self setupAutoHeightWithBottomView:self.toolView bottomMargin:0];
}

//文本上的url点击时响应的方法
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    url = URL;
    //发布通知
    NSNotification *post = [NSNotification notificationWithName:@"webLoad" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:post];
    return NO;
}

//把文本中的url过滤出来
- (NSArray*)getURLFromStr:(NSString *)string {
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    //NSRegularExpression是指正则表达式
    //NSRegularExpressionCaseInsensitive独立于大小写的模式匹配
    //&error这个是传递error的地址（如果有错误信息那就修改error里的东西）
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive  error:&error];
    //arrayOfAllMatches里面是已经匹配出url的正则表达式
    //matchesInString这个是返回带检测好的NSTextCheckingResult数组
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in arrayOfAllMatches){
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
    }
    return arr;
}

//原创微博下的视频
-(void)click:(UIButton *)btn
{
    videostr = _statusFrame.status.videoUrls.firstObject;
    //发布通知(告诉个人主页的控制器要刷新数据)
    NSNotification *post = [NSNotification notificationWithName:@"videoplay" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotification:post];
  
}
//转发微博下的视频
-(void)retweetclick:(UIButton *)btn
{
    videostr = _statusFrame.status.retweeted_status.videoUrls.firstObject;
    //发布通知(告诉个人主页的控制器要刷新数据)
    NSNotification *post = [NSNotification notificationWithName:@"videoplay" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotification:post];
}
@end
