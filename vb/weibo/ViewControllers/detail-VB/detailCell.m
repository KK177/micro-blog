//
//  detailCell.m
//  weibo
//
//  Created by MacBook pro on 2020/5/21.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "detailCell.h"
#import "vbcell.h"
#import "statusFrame.h"
#import "statuses.h"
#import "SDAutoLayout.h"

@interface detailCell ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *detailTableView;
@property (nonatomic, strong) statusFrame *frame;
@end
//点击微博的cell时传进来的微博数据
extern NSDictionary *dict;
extern BOOL insearch;
@implementation detailCell

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数据源
    [self changetomodel];
    
    //初始化tableView;
    [self setUptableView];
    
    //初始化收藏按钮
    [self setUpcollectbtn];
    
    //把当前数据写进plist文件（浏览记录功能)
    [self writetoFile];
    
}

#pragma mark - 把传进来的字典转成模型(初始化数据源)
-(void)changetomodel
{
    statuses *status = [statuses statusesWithDict:dict];
    _frame = [[statusFrame alloc] init];
    _frame.status = status;
}

#pragma mark - 初始化tableView
-(void)setUptableView
{
    self.detailTableView = [[UITableView alloc] init];
    self.detailTableView.dataSource = self;
    self.detailTableView.delegate = self;
    self.detailTableView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.detailTableView];
    self.detailTableView.tableFooterView= [[UIView alloc]init];
    //添加约束
    self.detailTableView.sd_layout
    .topEqualToView(self.view)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
}

#pragma mark - 把当前数据源写进浏览记录的plist
-(void)writetoFile
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"1vbcollect.plist"];
    NSMutableArray *dataArray = [NSMutableArray array];
    if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
        NSArray *kArr = [NSArray array];
        BOOL ret = [kArr writeToFile:filepath atomically:YES];
        if (ret) {
            dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        else{
            NSLog(@"创建plist失败了");
        }
        
    }
    else{
        //获取vbcollect.plist文件里面原有的数据
        dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    BOOL isinlist = NO;
    //先判断是否已经写进文件里面
    for(NSString *str in dataArray){
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *kdict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        statuses *status = [statuses statusesWithDict:kdict];
        if([status.idstr isEqualToString:_frame.status.idstr]){
            isinlist = YES;
            break;
        }
    }
    if(isinlist == NO){
        //由于微博返回的数据里面可能含有nil值.而plist文件是不可以把nil的值写进plist的.所以可以通过转码的形式再存进plist文件里面
        //把字典转成.json数据再保存到plist文件中
        NSError *parseError = nil;
        //dict里面装着的是.json数据
        //NSJSONWritingPrettyPrinted是指将数据格式化输出这样可读性就会高
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [dataArray insertObject:str atIndex:0];
        BOOL flag =[dataArray writeToFile:filepath atomically:YES];
        if(flag){
            NSLog(@"写入成功");
        }else{
            NSLog(@"写入失败");
        }
    }
}

#pragma mark - 初始化收藏按钮（并判断该微博是否被收藏）
-(void)setUpcollectbtn
{
    if([self isincollect]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"collect"] style:0 target:self action:@selector(iscollect)];
          [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blueColor]];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"noncollect"] style:0 target:self action:@selector(notcollect)];
             [self.navigationItem.rightBarButtonItem setTintColor:[UIColor grayColor]];
    }
}
//表示已经收藏
-(void)iscollect
{
    //设置弹窗
    //UIAlertControllerStyleAlert 在视图中间弹出提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"取消收藏该微博？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //默认的取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //默认的确定按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //取消plist文件中的数据
        [self cancelcollect];
        //改变收藏按钮的状态
        [self setUpcollectbtn];
    }];
    //把提示框按钮添加到提示控制器上
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    //让提示框可以显示
    [self presentViewController:alertController animated:YES completion:nil];
}
//表示还没有收藏
-(void)notcollect
{
    //设置弹窗
    //UIAlertControllerStyleAlert 在视图中间弹出提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定收藏该微博?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //默认的取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //默认的确定按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [self writetocollectFile];
        //收藏按钮再次点击时会是显示已经收藏
        [self setUpcollectbtn];
    }];
    //把提示框按钮添加到提示控制器上
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    //让提示框可以显示
    [self presentViewController:alertController animated:YES completion:nil];
}
//取消收藏的数据
-(void)cancelcollect
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"lovecollect.plist"];
    NSMutableArray *dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];

    //把字典转成.json数据再保存到plist文件中
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [dataArray removeObject:str];
    BOOL flag =[dataArray writeToFile:filepath atomically:YES];
    if(flag){
        NSLog(@"写入成功");
    }else{
        NSLog(@"写入失败");
    }
}
//收藏数据到plist
-(void)writetocollectFile
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"lovecollect.plist"];
    NSMutableArray *dataArray = [NSMutableArray array];
    if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
        NSArray *kArr = [NSArray array];
        BOOL ret = [kArr writeToFile:filepath atomically:YES];
        if (ret) {
            dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        else
        {
            NSLog(@"创建plist失败了");
        }
        
    }
    else{
        //获取vbcollect.plist文件里面原有的数据
        dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    //把字典转成.json数据再保存到plist文件中
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [dataArray insertObject:str atIndex:0];
    BOOL flag =[dataArray writeToFile:filepath atomically:YES];
    if(flag){
        NSLog(@"写入成功");
    }else{
        NSLog(@"写入失败");
    }
}
//判断当前数据源是否已经写到plist里面
-(BOOL)isincollect
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"lovecollect.plist"];
    NSMutableArray *dataArray = [NSMutableArray array];
    if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
        NSArray *kArr = [NSArray array];
        BOOL ret = [kArr writeToFile:filepath atomically:YES];
        if (ret) {
            dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        else
        {
            NSLog(@"创建plist失败了");
        }
        
    }
    else{
        //获取vbcollect.plist文件里面原有的数据
        dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    //先判断是否已经写进文件里面
    for(NSString *str in dataArray){
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *kdict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        statuses *status = [statuses statusesWithDict:kdict];
        if([status.idstr isEqualToString:_frame.status.idstr]){
            return YES;
        }
    }
    return NO;
}



#pragma mark - tableView的代理方法
//组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
//每一行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    vbcell *cell = [vbcell cellWithtableView:tableView];
    //给cell传递模型数据
    cell.statusFrame = _frame;
    //取消点击的阴影效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _frame.cellHeight;
}

@end
