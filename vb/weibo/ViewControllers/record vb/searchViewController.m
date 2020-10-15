//
//  searchViewController.m
//  weibo
//
//  Created by kkkak on 2020/5/4.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "searchViewController.h"
#import "vbcell.h"
#import "statuses.h"
#import "statusFrame.h"
#import "SDAutoLayout.h"

@interface searchViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *watchArray;
@end

@implementation searchViewController
#pragma mark - 懒加载数据源
- (NSMutableArray *)watchArray
{
    if(!_watchArray){
        self.watchArray = [[NSMutableArray alloc] init];
        //初始化数据(把.json数据转成字典，再把字典转成模型数组)
        //这里加载的datacollect.plist文件是存储在沙盒里面的
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [path stringByAppendingPathComponent:@"1vbcollect.plist"];
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
         _watchArray = temp;
    }
    return _watchArray;
}

#pragma mark - 页面显示更新数据源
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _watchArray = nil;
    [self.tableView reloadData];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏的内容
    self.navigationItem.title = @"浏览历史记录";
    
    //初始化tableView
    [self setUptab];
}

#pragma mark - 初始化tableView
-(void)setUptab
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor grayColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView= [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    //添加约束
    self.tableView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
}

#pragma mark - tableView的代理方法
//组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.watchArray.count;
}
//每一行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    vbcell *cell = [vbcell cellWithtableView:tableView];
    //给cell传递模型数据
    cell.statusFrame = self.watchArray[indexPath.row];
    //取消点击的阴影效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    statusFrame *frame = self.watchArray[indexPath.row];
    return frame.cellHeight;
}


@end
