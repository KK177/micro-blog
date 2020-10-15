//
//  myViewController.m
//  weibo
//
//  Created by kkkak on 2020/5/4.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "myViewController.h"
#import "sendViewController.h"
#import "postView.h"
#import "postModel.h"
#import "SDAutoLayout.h"
@interface myViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *myView;
@property (nonatomic,strong) UIImageView *myimageView;
@property (nonatomic,retain) UILabel *mylabel;
@property (nonatomic,strong) UIView *currentView;
@property (nonatomic,strong) UIView *preView;
@property (nonatomic,retain) UIButton *clapButton;
@property (nonatomic,retain) UIButton *commentButton;
@property (nonatomic,retain) UIButton *forwardButton;
@property (nonatomic,retain) UILabel *postLabel;
@property (nonatomic,strong) postView *postview;
@property (nonatomic,strong) NSArray *modelArray;
@end

//判断是否是发送带图片的微博
extern BOOL isphotoView;

@implementation myViewController
//懒加载cell的模型数据
-(NSArray *)modelArray
{
    if(!_modelArray){
    //这里加载的datacollect.plist文件是存储在沙盒里面的
    //得到documents的目录
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"datacollect.plist"];
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:filepath];
    NSMutableArray *temp =[NSMutableArray array];
    for(NSDictionary *dataDict in dictArray){
        [temp addObject:[postModel myViewdataWithdict:dataDict]];
    }
    _modelArray = temp;
    }
    return _modelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景view的图层颜色
    self.view.backgroundColor = [UIColor grayColor];
    
    //设置导航栏内容
    [self setUpnav];
    
    //设置头像以及名称
    [self serUpiconandname];
    
    //初始化tableView
    [self setUptab];
    
    //监听发布微博确认按钮的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didpostView) name:@"didpost" object:nil];
    
    //监听点赞数改变刷新列表通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"reload" object:nil];
}

#pragma mark - 设置导航栏内容
-(void)setUpnav
{
    //设置导航栏内容
    self.navigationItem.title = @"个人主页";
    //点击转到发微博的界面
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"添加"] style:0 target:self action:@selector(clickchange)];
}
#pragma mark - 设置头像和名称
-(void)serUpiconandname
{
    //设置个人介绍myView
    self.myView = [[UIView alloc] init];
    self.myView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.myView];
    self.myView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .heightIs(200);

    //添加圆形头像
    self.myimageView =[[UIImageView alloc] init];
    self.myimageView.image = [UIImage imageNamed:@"头像"];
    //圆的半径
    self.myimageView.layer.cornerRadius = 30;
    self.myimageView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.myimageView.layer.borderWidth = 1;
    self.myimageView.layer.masksToBounds = YES;

    //设置呢称
    //2.添加label
    self.mylabel = [[UILabel alloc] init];
    self.mylabel.text = @"kk177-";

    [self.myView sd_addSubviews:@[self.myimageView,self.mylabel]];

    //设置子控件的frame
    self.myimageView.sd_layout
    .leftSpaceToView(self.myView, 20)
    .widthIs(60)
    .heightIs(60)
    .topSpaceToView(self.myView, 120);

    self.mylabel.sd_layout
    .leftSpaceToView(self.myimageView, 20)
    .widthIs(60)
    .heightIs(60)
    .topSpaceToView(self.myView, 120);

}


#pragma mark - 初始化tableView
-(void)setUptab
{
    //设置tableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    //设置底部没有多余的黑线
    self.tableView.tableFooterView= [[UIView alloc]init];
    //数据刷新时界面不会跳动
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self. tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:self.tableView];
    //设置tableView的frame
    self.tableView.sd_layout
    .leftSpaceToView(self.view , 0)
    .topSpaceToView(self.myView, 10)
    .rightSpaceToView(self.view, 0)
    .bottomEqualToView(self.view);
}

#pragma mark - 更新点赞评论转发数
-(void)reload
{
    //重新加载数据
    self.modelArray = nil;
    [self.tableView reloadData];
}

#pragma mark - 点击编辑内容（发微博）
-(void)clickchange
{
    sendViewController *sendVc = [[sendViewController alloc] init];
    //隐藏tabBar
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sendVc animated:YES];
    //退出时重现tabbar
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 更新发布的View
-(void)didpostView
{
    _modelArray = nil;
    [self.tableView reloadData];
}

#pragma mark - tableView的代理方法
//1.设置组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//2.设置每组有多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

//3.每一行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *phototCellId = @"photoID";
    postView *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:phototCellId];
    if(!cell){
        cell = [[postView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:phototCellId];
        }
    //给postView添加数据
    postModel *postmodel = self.modelArray[indexPath.row];
    postView *postview = [[postView alloc] init];
    cell = [postview buildpostView:postmodel];
    //cell点击没有阴影效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//4.cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.frame.size.width tableView:tableView];
}

@end

    
