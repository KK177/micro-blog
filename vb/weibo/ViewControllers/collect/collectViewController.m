//
//  collectViewController.m
//  weibo
//
//  Created by kkkak on 2020/5/4.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "collectViewController.h"
#import "vbcell.h"
#import "statuses.h"
#import "statusFrame.h"
#import "SDAutoLayout.h"

@interface collectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *collectArray;

@end

@implementation collectViewController

#pragma mark - 懒加载数据源
- (NSMutableArray *)collectArray
{
    if(!_collectArray){
        self.collectArray = [[NSMutableArray alloc] init];
        //初始化数据(把.json数据转成字典，再把字典转成模型数组)
        //这里加载的datacollect.plist文件是存储在沙盒里面的
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [path stringByAppendingPathComponent:@"lovecollect.plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:filepath];
        NSMutableArray *temp =[NSMutableArray array];
        for(NSString *str in dictArray){
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            statuses *status = [statuses statusesWithDict:dict];
            statusFrame *frame = [[statusFrame alloc] init];
            frame.status = status;
            [temp addObject:frame];
        }
        _collectArray = temp;
    }
    return _collectArray;
}

#pragma mark - 刷新出最新数据
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _collectArray = nil;
    [self.tableView reloadData];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏内容
    self.navigationItem.title = @"收藏列表";
    
    //初始化tableView
    [self setUptab];
}

#pragma mark - 初始化tableView
-(void)setUptab
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //数据刷新时界面不会跳动
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self. tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.tableFooterView= [[UIView alloc]init];
    [self.view addSubview:self.tableView];
//    //添加约束
    self.tableView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
}

#pragma mark - tableView的代理方法
//1.设置组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//2.设置行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectArray.count;
}
//3.每一行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    vbcell *cell = [vbcell cellWithtableView:tableView];
    //给cell传递模型数据
    cell.statusFrame = self.collectArray[indexPath.row];
    //取消点击的阴影效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    statusFrame *frame = self.collectArray[indexPath.row];
//    return frame.cellHeight;
    return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.frame.size.width tableView:tableView];
}
//使用系统默认的删除按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"lovecollect.plist"];
    NSMutableArray *dictArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    //在plist文件里面保存的是str的数据类型
    NSString *str = dictArray[indexPath.row];
    [dictArray removeObject:str];
    [dictArray writeToFile:filepath atomically:YES];
    _collectArray = nil;
    [self.tableView reloadData];
}
//自定义系统默认的删除按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消收藏";
}
//旋转屏幕时刷新tableView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.tableView reloadData];
}
@end
