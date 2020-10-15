//
//  postView.m
//  weibo
//
//  Created by kkkak on 2020/5/8.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "postView.h"
#import "postModel.h"
#import "myviewController.h"
#import "frameload.h"
#import "myphotosView.h"
#import "SDAutoLayout.h"

//cell的宽度
#define cellW [UIScreen mainScreen].bounds.size.width
@interface postView()
//创建cell视图所包含的内容
//里面的控件
@property (nonatomic,retain) UIButton *clapButton;
@property (nonatomic,retain) UIButton *commentButton;
@property (nonatomic,retain) UIButton *forwardButton;
@property (nonatomic,retain) UILabel *postLabel;
@property (nonatomic,strong) myphotosView *photosView;
//model属性
@property (nonatomic,strong) postModel *postmodel;

//BOOL判断微博是否含有图片
@property (nonatomic, assign) BOOL hasphoto;
@end
@implementation postView

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

//经过initWithCoder创建出来的控件是死的，然后通过awakeFromNib来唤醒，这会有一个先后的调用顺序
//initWithCoder是指从xib或者storyboard上创建的控件
//而initWithFrame是自己在代码中创建的控件
- (void)awakeFromNib {
    [super awakeFromNib];
}
#pragma mark - 初始化发微博的view
-(postView *)buildpostView: (postModel *)postmodel
{
    //先拿出数组的总数
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"datacollect.plist"];
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:filepath];
    //用count来计算index
    int count = (int)dictArray.count;
    
    
    //设置文本label
    self.postLabel = [[UILabel alloc] init];
    self.postLabel.numberOfLines = 0;
    self.postLabel.font = [UIFont systemFontOfSize:17];
    //从model中取出数据更新view
    self.postLabel.text = postmodel.text;
    self.postLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.postLabel];
    
    //autoHeightRatio设置为0是为了实现高度自适应
    self.postLabel.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .topEqualToView(self.contentView)
    .rightSpaceToView(self.contentView, 10)
    .autoHeightRatio(0);
    
    //显示图片
    if([postmodel.hasphoto intValue]){
        //初始化显示图片的photosView
        self.photosView = [[myphotosView alloc] init];
        [self.contentView addSubview:self.photosView];
        //todo
        //设置photosView的frame
        int count = (int)postmodel.photo.count;
        //根据要显示的图片数量来计算photosView的宽和高
        CGSize size = [self photosSIzetocount:count];
        self.photosView.sd_layout
        .topSpaceToView(self.postLabel, 10)
        .leftSpaceToView(self.contentView, 10)
        .heightIs(size.height)
        .widthIs(size.width);
        //给photosView里面的子视图imageView添加图片
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<(int)postmodel.photo.count; i++) {
            NSString *str = postmodel.photo[i];
            NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *decodedImage= [UIImage imageWithData:decodedImageData];
            [array addObject:decodedImage];
        }
        self.photosView.photosArray = array;
        self.hasphoto = YES;
    }else{
        self.hasphoto = NO;
    }
    
    //设置点赞按钮
    self.clapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clapButton.backgroundColor = [UIColor whiteColor];
    [self.clapButton setImage:[UIImage imageNamed:@"zan"] forState:UIControlStateNormal];
    //给button添加响应事件
    //根据按钮的tag值来判断是哪个cell上的按钮
    self.clapButton.tag =count-1-[postmodel.index intValue];
    [self.clapButton addTarget:self action:@selector(clapclick:) forControlEvents:UIControlEventTouchUpInside];
    [self buttonup:self.clapButton : postmodel.clapSum];
    
    //设置frame
    [self.contentView addSubview:self.clapButton];
    if (self.hasphoto) {
        self.clapButton.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .topSpaceToView(self.photosView, 10)
        .rightSpaceToView(self.contentView, 2*cellW/3)
        .heightIs(35);
    }else{
        self.clapButton.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .topSpaceToView(self.postLabel, 10)
        .rightSpaceToView(self.contentView, 2*cellW/3)
        .heightIs(35);
    }
    
    //设置评论按钮
    self.commentButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.commentButton.backgroundColor = [UIColor whiteColor];
    [self.commentButton setImage:[UIImage imageNamed:@"pinglun"] forState:UIControlStateNormal];
    //添加点击事件
    self.commentButton.tag =count-1-[postmodel.index intValue];
    [self.commentButton addTarget:self action:@selector(commentclick:) forControlEvents:UIControlEventTouchUpInside];
    [self buttonup:self.commentButton : postmodel.commentSum];
    //添加约束
    [self.contentView addSubview:self.commentButton];
    self.commentButton.sd_layout
    .topEqualToView(self.clapButton)
    .bottomEqualToView(self.clapButton)
    .leftSpaceToView(self.clapButton, 0)
    .rightSpaceToView(self.contentView, cellW/3);
    
    //设置转发按钮
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.forwardButton.backgroundColor = [UIColor whiteColor];
    [self.forwardButton setImage:[UIImage imageNamed:@"fenxiang"] forState:UIControlStateNormal];
    self.forwardButton.tag = count-1-[postmodel.index intValue];
    [self.forwardButton addTarget:self action:@selector(forwardclick:) forControlEvents:UIControlEventTouchUpInside];
    [self buttonup:self.forwardButton : postmodel.forwardSum];
    //设置frame
    [self.contentView addSubview:self.forwardButton];
    self.forwardButton.sd_layout
    .topEqualToView(self.clapButton)
    .bottomEqualToView(self.clapButton)
    .leftSpaceToView(self.commentButton, 0)
    .rightSpaceToView(self.contentView, 0);
    
    [self setupAutoHeightWithBottomView:self.clapButton bottomMargin:10];
    
    return self;
}

#pragma mark - 给button加上角标
-(postView *)buttonup: (UIButton *)button : (NSNumber *) model
{
    postView *view = [[postView alloc] init];
    //给button控件加上角标
    //CATextLayer相当于一个文本标签
    CATextLayer *badgeLayer = [[CATextLayer alloc] init];
    //字体颜色
    badgeLayer.foregroundColor = [UIColor grayColor].CGColor;
    //设置位置
    [badgeLayer setFrame:CGRectMake(0, 0, 18, 18)];
    badgeLayer.position=CGPointMake(105, 13);
    badgeLayer.cornerRadius = 9.0f;
    //设置字体大小
    [badgeLayer setFontSize:16];
    //设置渲染方式(不模糊）
    badgeLayer.contentsScale = [[UIScreen mainScreen] scale];
    //给点赞button加角标
    //将数据转变为字符串
    NSString *str = model.description;
    //将NSNumber转变为int
    if ([model intValue] == 0)
    {
        [badgeLayer setString:@"0"];
    }else{
        [badgeLayer setString:str];
    }
    [button.layer addSublayer:badgeLayer];
    return view;
}

#pragma mark - 点赞数改变
-(postView *)clapclick:(UIButton *)btn
{
    postView *view = [[postView alloc] init];
    //改变plist文件里的数据
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"datacollect.plist"];
    NSMutableArray *dictArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    NSDictionary *dict =dictArray[btn.tag];
    int clapSum = [dict[@"clapSum"] intValue] + 1;
    NSNumber *number = [NSNumber numberWithInt:clapSum];
    //把字典里的点赞数改了再重新写进plist文件
    [dict setValue:number forKey:@"clapSum"];
    [dictArray replaceObjectAtIndex:btn.tag withObject:dict];
    [dictArray writeToFile:filepath atomically:YES];
    //发布通知
    NSNotification *post = [NSNotification notificationWithName:@"reload" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:post];
    return view;
}


#pragma mark - 评论数改变
-(postView *)commentclick:(UIButton *)btn
{
    postView *view = [[postView alloc] init];
    //改变plist文件里的数据
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"datacollect.plist"];
    NSMutableArray *dictArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    NSDictionary *dict =dictArray[btn.tag];
    int commentSum = [dict[@"commentSum"] intValue] + 1;
    NSNumber *number = [NSNumber numberWithInt:commentSum];
    //把字典里的评论数改了再重新写进plist文件
    [dict setValue:number forKey:@"commentSum"];
    [dictArray replaceObjectAtIndex:btn.tag withObject:dict];
    [dictArray writeToFile:filepath atomically:YES];
    //发布通知
    NSNotification *post = [NSNotification notificationWithName:@"reload" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:post];
    return view;
}

#pragma mark - 转发数改变
-(postView *)forwardclick:(UIButton *)btn
{
    postView *view = [[postView alloc] init];
    //改变plist文件里的数据
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"datacollect.plist"];
    NSMutableArray *dictArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    NSDictionary *dict =dictArray[btn.tag];
    int forwardSum = [dict[@"forwardSum"] intValue] + 1;
    NSNumber *number = [NSNumber numberWithInt:forwardSum];
    //把字典里面的转发数改了再重新写进plist文件
    [dict setValue:number forKey:@"forwardSum"];
    [dictArray replaceObjectAtIndex:btn.tag withObject:dict];
    [dictArray writeToFile:filepath atomically:YES];
    //发布通知
    NSNotification *post = [NSNotification notificationWithName:@"reload" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:post];
    return view;
}

@end

