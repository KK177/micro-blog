
//  weiboViewController.m
//  weibo
//
//  Created by kkkak on 2020/5/4.
//  Copyright © 2020 kkkak. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "weiboViewController.h"
#import "kkuser.h"
#import "statuses.h"
#import "vbcell.h"
#import "statusFrame.h"
#import "upLoaddata.h"
#import "detailCell.h"
#import "webloadVC.h"
#import "searchCell.h"
#import "photosView.h"
#import "AFNetworking.h"
#import "SDAutoLayout.h"
#import "videoPlay.h"
#import <AVKit/AVKit.h>
@interface weiboViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UISearchBar *search;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,strong) UITableView *moretableView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *belowView;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIRefreshControl *control;
@property (nonatomic,assign) BOOL iscollect;
@property (nonatomic,assign) BOOL addkeysearch;
@property (nonatomic,assign) BOOL deletekey;
@property (nonatomic,assign) NSInteger keyindex;
//数组里面是模型，每个模型里面装的是一条微博
@property (nonatomic, strong) NSMutableArray *statusFramesArray;
//数组来存微博返回的.json数据
@property (nonatomic, strong) NSMutableArray *jsonArray;
//数组里面存微博的文本内容来实现搜索
@property (nonatomic, strong) NSMutableArray *textArray;
//数组里面存的是搜索框的搜索记录
@property (nonatomic, strong) NSMutableArray *searchArray;
//数组里面存的是搜索后的微博的.json数据
@property (nonatomic, strong) NSMutableArray *searchdetailArray;

@property (nonatomic,assign) BOOL isrequest;

@property (nonatomic,assign) BOOL isclick;
//获取api接口的翻页码
@property (nonatomic,copy) NSString *pageToken;
//数组里面的是scrollView上的按钮title
@property (nonatomic,strong) NSMutableArray *titleArray;
//数组里面的是statusFrame的前几个数据
@property (nonatomic,strong) NSMutableArray *tempArray;
@end

NSDictionary *dict;
//判断是不是要显示搜索后的数据
int isinlist;
//判断是不是显示搜索记录
int isinsearch;
//判断点击更多按钮的状态
BOOL clickmore;
//传递cell的下标
NSInteger cellindex;
//视频url的string
NSString *videostring;;
//视频的url
extern NSString *videostr;
@implementation weiboViewController
#pragma mark - 懒加载临时数据
- (NSMutableArray *)tempArray
{
    if(!_tempArray){
        _tempArray = [[NSMutableArray alloc] init];
    }
    return _tempArray;
}
#pragma mark - 初始化输入框
-(UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
    }
    return _textField;
}
#pragma mark - 懒加载scrollView上的按钮title
- (NSMutableArray *)titleArray
{
    if(!_titleArray){
        _titleArray = [[NSMutableArray alloc] init];
    }
    return _titleArray;
}
#pragma mark - 懒加载cell的模型数据
- (NSMutableArray *)statusFramesArray
{
    if(!_statusFramesArray){
        self.statusFramesArray = [[NSMutableArray alloc] init];
    }
    return _statusFramesArray;
}
#pragma mark - 懒加载微博返回的原始数据
- (NSMutableArray *)jsonArray
{
    if(!_jsonArray){
        self.jsonArray = [[NSMutableArray alloc] init];
    }
    return _jsonArray;
}
#pragma mark - 懒加载搜索框搜索结果的数据
- (NSMutableArray *)textArray
{
    if(!_textArray){
        self.textArray = [[NSMutableArray alloc] init];
    }
    return _textArray;
}
#pragma mark - 懒加载显示搜索框搜索记录的数据
- (NSMutableArray *)searchArray
{
    if(!_searchArray){
        self.searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}
#pragma mark - 懒加载保存搜索结果数据的原始数据
- (NSMutableArray *)searchdetailArray
{
    if(!_searchdetailArray){
        self.searchdetailArray = [[NSMutableArray alloc] init];
    }
    return _searchdetailArray;
}
//释放缓存
-(void)didReceiveMemoryWarning
{
    photosView *view = [[photosView alloc] init];
    [view.photosDict removeAllObjects];
    [view.cachesA removeAllObjects];
    [view.photosA removeAllObjects];
    [view.queue cancelAllOperations];
    
    vbcell *cell = [[vbcell alloc] init];
    [cell.icondict removeAllObjects];
    
    [self.jsonArray removeAllObjects];
    [self.statusFramesArray removeAllObjects];
    [self.tempArray removeAllObjects];
}




#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _deletekey = NO;
    
    _isclick = NO;
    
    _isrequest  = NO;
    
    _addkeysearch = NO;
    
    _textField.delegate = self;
    //初始化导航栏内容
    [self setUpnavigation];
    
    //初始化tableView
    [self setUptableView];
    
    //初始化scrollView
    [self setUpscrollView];
    
    
    //下拉刷新最新微博数（苹果自带的下拉刷新）
    [self loadRefresh];
    
    //监听web加载网页的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webLoad) name:@"webLoad" object:nil];
    
    //监听发布微博确认按钮的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlay:) name:@"videoplay" object:nil];
}

-(void)videoPlay:(NSNotification *)videodict
{
    
   // videostring = videodict.userInfo[@"videourl"];
    //NSLog(@"%@",videostring);
    //控制器跳转
    videoPlay *videoplay = [[videoPlay alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:videoplay animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 初始化scrollView
-(void)setUpscrollView
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"keysearch.plist"];
    if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
        NSArray *kArr = [NSArray array];
        BOOL ret = [kArr writeToFile:filepath atomically:YES];
        if (ret) {
            //获取collect.plist文件里面原有的数据
            _titleArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        else
        {
            NSLog(@"创建collect.plist失败了");
        }
        
    }
    
    else{
        //获取plist文件里面原有的数据
        _titleArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    [self.view addSubview:self.scrollView];
    
    //scrollView的约束
    _scrollView.sd_layout
    .topSpaceToView(self.navigationController.navigationBar, 0)
    .leftSpaceToView(self.view, 0)
    .rightEqualToView(self.view)
    .heightIs(35);
    
    for (int i=0; i<_titleArray.count; i++) {
        UIButton * titleButton=[UIButton buttonWithType:UIButtonTypeCustom];
        titleButton=[[UIButton alloc] initWithFrame:CGRectMake(i*80,0, 60,30)];
        [titleButton setTitle:[self.titleArray objectAtIndex:i] forState:UIControlStateNormal];
        titleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        titleButton.tag = i;
        [titleButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [titleButton  addTarget:self action:@selector(btnClcik:) forControlEvents:UIControlEventTouchUpInside];
        //  按钮长按
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
       
        longPress.minimumPressDuration = 0.8;
        [titleButton addGestureRecognizer:longPress];
        
        //判断按钮的选中状态
        if (_addkeysearch) {
            if (i==_titleArray.count-1) {
                titleButton.selected = YES;
            }
        }else{
            if (_deletekey) {
                if (i == _keyindex) {
                    titleButton.selected = YES;
                }
            }else{
                if (i==0) {
                    titleButton.selected = YES;
                }
            }
        }
        [self.scrollView addSubview:titleButton];
    }
    
    //添加按钮的布局
    if (_titleArray != nil && ![_titleArray isKindOfClass:[NSNull class]] && _titleArray.count != 0){
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((_titleArray.count)*80, 0, 60, 30)];
        btn.tag = _titleArray.count;
        [btn setImage:[UIImage imageNamed:@"tianjia1"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addtitle:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btn];
    }else{
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        btn.tag = 0;
        [btn setImage:[UIImage imageNamed:@"tianjia1"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addtitle:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btn];
    }
    
    if (self.titleArray.count*80>self.view.frame.size.width) {
        _scrollView.contentSize = CGSizeMake((self.titleArray.count+1)*80, 0);
    }
    if (_addkeysearch) {
        if (self.titleArray.count>3) {
            self.scrollView.contentOffset = CGPointMake((self.titleArray.count-4)*80, 0);
        }else{
            
        }
    }

   
    self.belowView = [[UIView alloc] init];
    self.belowView.backgroundColor = [UIColor orangeColor];
    self.belowView.frame = CGRectMake(0, 30, 60, 5);
    if (_addkeysearch) {
        self.belowView.transform = CGAffineTransformMakeTranslation(80*(self.titleArray.count-1), 0);
    }else{
        if (_deletekey) {
            self.belowView.transform = CGAffineTransformMakeTranslation(80*_keyindex, 0);
        }
    }
    [self.scrollView addSubview:self.belowView];
    
    //判断是否有添加关键字
    _addkeysearch = NO;
    //判断删除关键字
    _deletekey = NO;
}

#pragma mark - 监听title的添加
-(void)addtitle:(UIButton *)btn
{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.belowView.transform = CGAffineTransformMakeTranslation(80*btn.tag, 0);
        
    }];
    //弹出输入框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入关键字" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     UITextField *userNameTextField = alertController.textFields.firstObject;
        //获取沙盒文件里面的collect.plist路径
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [path stringByAppendingPathComponent:@"keysearch.plist"];
        NSMutableArray *dataArray = [NSMutableArray array];
        if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
            NSArray *kArr = [NSArray array];
            BOOL ret = [kArr writeToFile:filepath atomically:YES];
            if (ret) {
                //获取collect.plist文件里面原有的数据
                dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
            }
            else
            {
                NSLog(@"创建plist失败了");
            }

        }
        else{
            //获取collect.plist文件里面原有的数据
            dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        BOOL isinkeylist = NO;
        NSRange range = [userNameTextField.text rangeOfString:@" "];
        for (int i=0; i<dataArray.count; i++) {
            if ([dataArray[i] isEqualToString:userNameTextField.text]) {
                isinkeylist = YES;
            }
        }
        if (isinkeylist==NO) {
            if ( [userNameTextField.text  isEqual: @""] || range.location!=NSNotFound){
                //弹出输入框
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入有效字符(中文）" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                if (userNameTextField.text.length>4) {
                    //弹出提示框
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"最多输入四个汉字" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }else{
                    [dataArray addObject:userNameTextField.text];
                    [dataArray writeToFile:filepath atomically:YES];
                    self->_addkeysearch = YES;
                    
                    [self setUpscrollView];
                    //清空之前关键字搜索的数据
                    [self.jsonArray removeAllObjects];
                    [self.statusFramesArray removeAllObjects];
                    
                    //刷新效果
                    [self->_control beginRefreshing];
                    
                    //用tag来传值来判断是哪个关键字
                    self->_control.tag = dataArray.count-1;
                     [self reFreshstatus:self->_control];
                    
                    //tableView回到顶部位置
                    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                }
            }
        }else{
            //弹出输入框
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"标签已存在" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField*_NonnulltextField) {
        _NonnulltextField.placeholder=@"请输入关键字";
        _NonnulltextField.delegate = self;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}



#pragma mark - 监听按钮的点击
-(void)btnClcik:(UIButton *)btn
{
    //判断按钮是否被点击
    _isclick = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.belowView.transform = CGAffineTransformMakeTranslation(80*btn.tag, 0);
        
        if (btn.tag == 0||btn.tag == 1||btn.tag == 2) {
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }else{
            self.scrollView.contentOffset = CGPointMake((btn.tag-3)*80, 0);
        }
    }];
    for (int i=0; i<self.titleArray.count; i++) {
        UIButton *button = self.scrollView.subviews[i];
        if(i == btn.tag){
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
    //清空之前关键字搜索的数据
    [self.jsonArray removeAllObjects];
    [self.statusFramesArray removeAllObjects];
    
    //刷新效果
    [_control beginRefreshing];
    
    
    //用tag来传值来判断是哪个关键字
    _control.tag = btn.tag;
    NSLog(@"%ld",_control.tag);
    //刷新出最新数据
    [self reFreshstatus:_control];
    NSString *key = _titleArray[btn.tag];
    NSLog(@"%@",key);
    _isclick = YES;
    
    //tableView回到顶部位置
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
}

#pragma mark - button长按
-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        UIButton *btn = gestureRecognizer.view;
        NSLog(@"%ld",btn.tag);
        NSLog(@"%ld",_control.tag);
        //设置弹窗
        //UIAlertControllerStyleAlert 在视图中间弹出提示框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除该标签？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //默认的取消按钮
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        //默认的确定按钮
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //删除该标签
            //获取沙盒文件里面的collect.plist路径
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
            NSString *filepath = [path stringByAppendingPathComponent:@"keysearch.plist"];
            NSMutableArray *dataArray = [NSMutableArray array];
            //获取collect.plist文件里面原有的数据
                dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
            NSInteger index = btn.tag;
            NSString *str = self.titleArray[index];
            [dataArray removeObject:str];
            [dataArray writeToFile:filepath atomically:YES];
            if (self->_control.tag == index) {
                if(dataArray != nil && ![dataArray isKindOfClass:[NSNull class]] && dataArray.count != 0) {
                    self->_control.tag = 0;
                    btn.tag = 0;
                    [self setUpscrollView];
                    [self btnClcik:btn];
                }else{
                    [self setUpscrollView];
                    [self reFreshstatus:self->_control];
                }
            }else{
                self->_deletekey = YES;
                NSString *str = self->_titleArray[self->_control.tag];
                for (int i=0; i<dataArray.count; i++) {
                    NSString *key = dataArray[i];
                    if ([str isEqualToString:key]) {
                        self->_keyindex = i;
                    }
                }
                [self setUpscrollView];
            }
       
        }];
        //把提示框按钮添加到提示控制器上
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        //让提示框可以显示
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 初始化导航栏内容（包括搜索框）
-(void)setUpnavigation
{
    clickmore = YES;
    //设置导航栏内容
    self.navigationItem.title = @"微博主页";
    //点击加载更多
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gengduo"] style:0 target:self action:@selector(listchoose)];

    _search = [[UISearchBar alloc] init];
    //显示搜索框的cancel按钮
    _search.showsCancelButton = YES;
    //设置代理
    _search.delegate = self;
    //[UIApplication sharedApplication].statusBarFrame.size.height这是获取状态栏的高度
    //把搜索框隐藏在navigationBar的后面
    [self.navigationController.view insertSubview:_search belowSubview:self.navigationController.navigationBar];
    
    //添加约束
    _search.sd_layout
    .topSpaceToView(self.navigationController.view, [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height-35)
    .bottomEqualToView(self.navigationController.navigationBar)
    .leftEqualToView(self.navigationController.navigationBar)
    .rightEqualToView(self.navigationController.navigationBar)
    .heightIs(35);
}

#pragma mark - 初始化tableView
-(void)setUptableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tag = 1;
    //数据刷新时界面不会跳动
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.frame = self.view.frame;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.tableView];
    
    //添加约束
    self.tableView.sd_layout
    .topSpaceToView(self.navigationController.navigationBar, 35)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
}

#pragma mark - 下拉刷新最新数据
-(void)loadRefresh
{
    //UIRefreshControl是系统自带的下拉刷新
    _control = [[UIRefreshControl alloc] init];
    if (_titleArray != nil && ![_titleArray isKindOfClass:[NSNull class]] && _titleArray.count != 0){
        _control.tag = 0;
    }
    [_control addTarget:self action:@selector(reFreshstatus:) forControlEvents:UIControlEventValueChanged];
    //不用自定义frame
    [self.tableView addSubview:_control];
    //一进来就有刷新效果（但刷新数据是要手动的)
    [_control beginRefreshing];
    [self reFreshstatus:_control];
}

-(void)reFreshstatus:(UIRefreshControl *)control
{
     NSDictionary *dict = [NSDictionary dictionary];
    if (_titleArray != nil && ![_titleArray isKindOfClass:[NSNull class]] && _titleArray.count != 0)
    {
        NSInteger index = control.tag;
        NSString *key = _titleArray[index];
        dict = @{
                 @"apikey":@"sfyE4phmFsBGF4pxhk8Pz23VGR5eVgGFqByLhaZULYvyD4kugxm2XUqFvhen2ohG",
                 @"type":@"hot",
                 @"kw":key
                 };
    }else{
        dict = @{
                 @"apikey":@"sfyE4phmFsBGF4pxhk8Pz23VGR5eVgGFqByLhaZULYvyD4kugxm2XUqFvhen2ohG",
                 @"uid":@"2803301701"
                 };
    }
    //创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //发送GET请求
    [manager GET:@"http://api02.idataapi.cn:8000/post/weibo" parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //获取翻页码
        self->_pageToken = responseObject[@"pageToken"];
        //取得微博的字典数组
        NSArray *dictArray = responseObject[@"data"];
        //过滤掉重复的微博
        BOOL isinlist = NO;
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in dictArray){
            isinlist = NO;
            NSMutableDictionary *dict1 = dict[@"mblog"];
            NSString *idstr = dict1[@"idstr"];;
            for (NSDictionary *dict2 in self.jsonArray) {
                NSMutableDictionary *dict3 = dict2[@"mblog"];
                NSString *jsonidstr = dict3[@"idstr"];
                if ([jsonidstr isEqualToString:idstr]) {
                    isinlist = YES;
                }
            }
            if (isinlist==NO) {
                [array addObject:dict];
            }
        }
        //将最新的微博数据添加到json总数组的最前面
        NSRange jsonrange = NSMakeRange(0, array.count);
        NSIndexSet *jsonindex = [NSIndexSet indexSetWithIndexesInRange:jsonrange];
        [self.jsonArray insertObjects:array atIndexes:jsonindex];
        //创建一个可变数组来存储最新微博模型
        NSMutableArray *newstatus = [NSMutableArray array];
        //将字典数组转变成模型数组
        for (NSDictionary *dict in array){
            statuses *status = [statuses statusesWithDict:dict];
            [newstatus addObject:status];
        }
        //将status数组转变为statusFrame数组
        NSMutableArray *frameArray = [NSMutableArray array];
        for (statuses *status in newstatus){
            statusFrame *aframe = [[statusFrame alloc] init];
            aframe.status = status;
            [frameArray addObject:aframe];
        }
        //将最新的微博数据添加到总数组的最前面
        NSRange range = NSMakeRange(0, frameArray.count);
        NSIndexSet *index = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.statusFramesArray insertObjects:frameArray atIndexes:index];
        //临时数据
        NSRange temprange = NSMakeRange(0, self.statusFramesArray.count);
        NSIndexSet *tempindex = [NSIndexSet indexSetWithIndexesInRange:temprange];
        [self.tempArray insertObjects:self.statusFramesArray atIndexes:tempindex];
        //结束刷新
        [control endRefreshing];
        //刷新最新微博数量
        [self.tableView reloadData];
        //显示最新微博数量
        [self shownewStatus:(int)newstatus.count];
        //上拉也加载数据（初始化footerView)
        [self downdata];
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败");
              //结束刷新
              [control endRefreshing];
          }];
}

#pragma mark - 底部点击刷新最新数据
//初始化底部点击刷新数据按钮
-(void)downdata
{
    self.tableView.tableFooterView = [upLoaddata setfooter];
}
//监听tableView的高度来实现下拉刷新
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.2) {
        if (_isrequest) {
        }else{
            _isrequest = YES;
            [self downmoredata];
        }
    }
}

//底部按钮加载数据
-(void)downmoredata
{
    ///创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSInteger index = _control.tag;
    NSString *key = _titleArray[index];
    NSDictionary *dict = [NSDictionary dictionary];
    dict = @{
             @"apikey":@"sfyE4phmFsBGF4pxhk8Pz23VGR5eVgGFqByLhaZULYvyD4kugxm2XUqFvhen2ohG",
             @"type":@"hot",
             @"kw":key,
             @"pageToken":_pageToken
             };
    //发送GET请求
    [manager GET:@"http://api02.idataapi.cn:8000/post/weibo" parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //取得微博的字典数组
        NSMutableArray *dictArray = responseObject[@"data"];
        //将最新的微博数据添加到json总数组的最后面
        [self.jsonArray addObjectsFromArray:dictArray];
        //创建一个可变数组来存储最新微博模型
        NSMutableArray *newstatus = [NSMutableArray array];
        //将字典数组转变成模型数组
        for (NSDictionary *dict in dictArray){
            statuses *status = [statuses statusesWithDict:dict];
            [newstatus addObject:status];
        }
        //将status数组转变为statusFrame数组
        NSMutableArray *frameArray = [NSMutableArray array];
        for (statuses *status in newstatus){
            statusFrame *aframe = [[statusFrame alloc] init];
            aframe.status = status;
            [frameArray addObject:aframe];
        }
        //将最新的微博数据添加到总数组的最后面
        [self.statusFramesArray addObjectsFromArray:frameArray];
        [self.tableView reloadData];
        NSLog(@"请求成功");
        self->_isrequest = NO;
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败");
          }];
}

#pragma mark - 显示加载出的最新数据的数量
-(void)shownewStatus:(int)count
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height-35, [UIScreen mainScreen].bounds.size.width, 35);
    label.backgroundColor = [UIColor orangeColor];
    if(count == 0){
        label.text = @"没有最新的微博数据";
    }else{
        label.text = [NSString stringWithFormat:@"已加载%d条最新的微博数据",count];
    }
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0];
    [self.navigationController.view insertSubview:label belowSubview:self.navigationController.navigationBar];
    //动画显示
    [UIView animateWithDuration:1.0 animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, 35);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}

#pragma mark - 点击url加载网页
-(void)webLoad
{
    webloadVC *web = [[webloadVC alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 点击显示更多实现(定时器，搜索框)
-(void)listchoose
{
    if(clickmore){
        _moretableView = [[UITableView alloc] init];
        _moretableView.delegate = self;
        _moretableView.dataSource = self;
        _moretableView.backgroundColor = [UIColor darkGrayColor];
        [self.navigationController.view addSubview:_moretableView];
        _moretableView.sd_layout
        .topSpaceToView(self.navigationController.navigationBar, 0)
        .rightEqualToView(self.navigationController.view)
        .widthIs(150)
        .heightIs(64);
        clickmore = NO;
    }else{
       [_moretableView removeFromSuperview];
        clickmore = YES;
    }
}


#pragma mark - 搜索框的代理方法
//点击搜索框时显示搜索记录
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //把底部加载的按钮隐藏掉
    self.tableView.tableFooterView.hidden = YES;
    //self.search.tag一开始没有设置值默认为0
    if(!self.search.tag){
        isinlist = 0;
        //获取沙盒文件里面的collect.plist路径
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
        NSString *filepath = [path stringByAppendingPathComponent:@"search.plist"];
        if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
            isinsearch = 0;
        }else{
            NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filepath];
            //isinsearch表示显示搜索记录
            isinsearch = 1;
            _searchArray = array;
            [self.tableView reloadData];
        }
    }
}
//搜索按钮点击时实现的方法
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.tableView.transform = CGAffineTransformMakeTranslation(0,0);
    //isinsearch是用来判断tableView是否显示搜索记录的
    isinsearch = 0;
    NSString *str = searchBar.text;
    //将字符串str里面的大写字母都转换为小写字母
    str = [self changetoLower:str];
    NSMutableArray *array = [NSMutableArray array];
    //先把数组里面的东西清空
    [self.textArray removeAllObjects];
    if(str!=nil&&searchBar.text.length>0){
        for(int i=0;i<self.statusFramesArray.count;i++){
            statusFrame *statusF = self.statusFramesArray[i];
            NSString *text = statusF.status.text;
            NSString *pinyin = [self transformToPinyin:text];
            //NSDiacriticInsensitiveSearch不区分大小写比较
            if([pinyin rangeOfString:str options:NSDiacriticInsensitiveSearch].length>0){
                [array addObject:statusF];
                [self.searchdetailArray addObject:self.jsonArray[i]];
            }
        }
        _textArray = array;
    }
    
    //判断textArray数组是否为空
    if(_textArray != nil && ![_textArray isKindOfClass:[NSNull class]] && _textArray.count !=0)
    {
        //告诉tableView要显示搜索结果的数据
        //isinlist表示是要显示搜索结果
        isinlist = 1;
    }else{
        //提示没有搜索到相关数据
        //设置弹窗
        //UIAlertControllerStyleAlert 在视图中间弹出提示框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有找到相关的微博，请重新搜索" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *oAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        //把提示框按钮添加到提示控制器上
        [alertController addAction:oAction];
        //让提示框可以显示
        [self presentViewController:alertController animated:YES completion:nil];
       
        //显示搜索记录
        //设置 isinsearch 和 isinlist 的值是为了让tableView显示搜索记录
        isinsearch = 1;
        isinlist = 0;
        //设置self.search.tag是为了判断要显示搜索记录
        self.search.tag = 0;
        self.tableView.transform = CGAffineTransformMakeTranslation(0, 35);
    }
    self.tableView.tableFooterView.hidden = YES;
    //刷新列表，更新显示的数据
    [self.tableView reloadData];
    //把搜索记录写进plist文件
    [self savesearchplist];
}
//cancel点击退出搜索框
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //设置弹窗
    //UIAlertControllerStyleAlert 在视图中间弹出提示框
    //self.search.tag用来判断是否显示搜索记录（1表示不显示）
    self.search.tag = 1;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"hey！kk177-" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *oAction = [UIAlertAction actionWithTitle:@"退出键盘" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //因为无论是点击搜索按钮还是点击cancel按钮都有跑searchBarTextDidBeginEditing这个方法，所以设置search.tag为1.那么就不会显示搜索记录
        self.search.tag = 1;
        [self.search endEditing:YES];
    }];
    UIAlertAction *tAction = [UIAlertAction actionWithTitle:@"结束搜索" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        isinlist = 0;
        isinsearch = 0;
        self.search.tag = 0;
        //把搜索框隐藏在navigationBar的后面
        [self.navigationController.view insertSubview:self->_search belowSubview:self.navigationController.navigationBar];
        
        //添加约束
        self->_search.sd_layout
        .topSpaceToView(self.navigationController.view, [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height-35)
        .bottomEqualToView(self.navigationController.navigationBar)
        .leftEqualToView(self.navigationController.navigationBar)
        .rightEqualToView(self.navigationController.navigationBar)
        .heightIs(35);
        [self.search endEditing:YES];
        [self.tableView reloadData];
        self.tableView.tableFooterView.hidden = NO;
    }];
    //把提示框按钮添加到提示控制器上
    [alertController addAction:oAction];
    [alertController addAction:tAction];
    //让提示框可以显示
    [self presentViewController:alertController animated:YES completion:nil];
}
//删除搜索记录
-(void)deletedata:(UIButton *)btn
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"search.plist"];
    //btn.tag是指当前数据的下标
    [self.searchArray removeObject:self.searchArray[btn.tag]];
    [self.searchArray writeToFile:filepath atomically:YES];
    self.searchArray = [NSMutableArray arrayWithContentsOfFile:filepath];;
    isinsearch = 1;
    [self.tableView reloadData];
}
//把搜索记录写进plist文件
-(void)savesearchplist
{
    NSString *str = self.search.text;
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"search.plist"];
    NSMutableArray *dataArray = [NSMutableArray array];
    if ([NSMutableArray arrayWithContentsOfFile:filepath]==nil) {
        NSArray *kArr = [NSArray array];
        BOOL ret = [kArr writeToFile:filepath atomically:YES];
        if (ret) {
            //获取collect.plist文件里面原有的数据
            dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
        }
        else{
            NSLog(@"创建plist失败了");
        }
        
    }
    else{
        //获取collect.plist文件里面原有的数据
        dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    if (dataArray!= nil && ![dataArray isKindOfClass:[NSNull class]] && dataArray.count != 0){
        BOOL flag = NO;
        //判断数组里面是否已经存了str
        for(int i =0;i<dataArray.count;i++){
            NSString *searchstr = dataArray[i];
            if([searchstr isEqualToString:str]){
                flag = YES;
            }
        }
        if(!flag){
            //将搜索记录添加到数组的最前面
            NSInteger index = 0;
            [dataArray insertObject:str atIndex:index];
        }
    }else{//本来从plist获取的数据就是空的.那么就直接将数据写进数组里面
        NSInteger index = 0;
        [dataArray insertObject:str atIndex:index];
    }
    //把数组重新写入文件
    BOOL flag =[dataArray writeToFile:filepath atomically:YES];
    if(flag){
        NSLog(@"写入成功");
    }
}
//模糊搜索的实现
//将汉字转变为拼音
- (NSString *)transformToPinyin:(NSString *)searchtext
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:searchtext];
    //将汉字转变为拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转变后的str每个字是旁白呢是有空格分开的
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [NSMutableString new];
    int count = 0;
    //这是把汉字的拼音全部拼接起来
    for (int  i = 0; i < pinyinArray.count; i++)
    {
        for(int i = 0; i < pinyinArray.count;i++)
        {
            if (i == count) {
                [allString appendString:@"#"];
            }
            [allString appendFormat:@"%@",pinyinArray[i]];
        }
        [allString appendString:@","];
        count ++;
    }
    NSMutableString *initialStr = [NSMutableString new];
    //这是把汉字的首字母拼接起来
    for (NSString *s in pinyinArray)
    {
        if (s.length > 0)
        {
            [initialStr appendString:  [s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",searchtext];
    return allString;
}
//将大写字母转变为小写字母
-(NSString *)changetoLower:(NSString *)str
{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='A'&&[str characterAtIndex:i]<='Z') {
            char  temp=[str characterAtIndex:i]+32;
            NSRange range=NSMakeRange(i, 1);
            str=[str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%c",temp]];
        }
    }
    return str;
}

#pragma mark - 定时器实现
//点击定时器按钮后调用的方法
-(void)begintimeUp
{
    //设置弹窗
    //UIAlertControllerStyleAlert 在视图中间弹出提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"开启定时更新新闻功能?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"每隔1分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        if(self.timer){
            //停止定时器
            [self.timer invalidate];
            //停止定时器之后将定时器清空，释放内存
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(NStimerup) userInfo:nil repeats:YES];
    }];
    UIAlertAction *fiveAction = [UIAlertAction actionWithTitle:@"每隔5分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        if(self.timer){
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(NStimerup) userInfo:nil repeats:YES];
    }];
    UIAlertAction *fifAction = [UIAlertAction actionWithTitle:@"每隔15分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        if(self.timer){
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:900.0 target:self selector:@selector(NStimerup) userInfo:nil repeats:YES];
    }];
    UIAlertAction *canceltimeAction = [UIAlertAction actionWithTitle:@"关闭定时器功能" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [self.timer invalidate];
        self.timer = nil;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //把提示框按钮添加到提示控制器上
    [alertController addAction:oneAction];
    [alertController addAction:fiveAction];
    [alertController addAction:fifAction];
    [alertController addAction:canceltimeAction];
    [alertController addAction:cancelAction];
    //让提示框可以显示
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 开启定时器后调用的方法
-(void)NStimerup
{
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [self reFreshstatus:control];
}


#pragma mark - tableView的代理方法
//组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //isinsearch表示显示搜索记录
    //isinlist表示显示微博的cell数据
    if(tableView.tag==1){
        if(isinsearch == 1){
            return self.searchArray.count;
        }else{
            if(isinlist){
                return self.textArray.count;
            }else{
                return self.statusFramesArray.count;
            }
        }
    }else{
        return 2;
    }
}
//每行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag==1){
        vbcell *cell = [[vbcell alloc] init];
        searchCell *cell1 = [[searchCell alloc] init];
        if(isinsearch==1){
            //显示搜索记录
            cell1 = [searchCell cellWithsearchtableView:tableView];
            cell1.textLabel.text = self.searchArray[indexPath.row];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *image = [UIImage imageNamed:@"chacha"];
            btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            btn.tag = indexPath.row;
            [btn setBackgroundImage:image forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(deletedata:) forControlEvents:UIControlEventTouchUpInside];
            cell1.accessoryView = btn;
            //取消点击的阴影效果
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell1;
        }else{
            cell = [vbcell cellWithtableView:tableView];
            if(isinlist){
                //显示搜索结果
                cell.statusFrame = self.textArray[indexPath.row];
            }else{
                if (_isclick) {
                    if (self.statusFramesArray != nil && ![self.statusFramesArray isKindOfClass:[NSNull class]] && self.statusFramesArray.count != 0){
                        //显示原始微博数据
                        cell.statusFrame = self.statusFramesArray[indexPath.row];
                    }else{
                        cell.statusFrame = self.tempArray[indexPath.row];
                    }
                }else{
                   
                    //显示原始微博数据
                    cell.statusFrame = self.statusFramesArray[indexPath.row];
                }
            }
            //取消点击的阴影效果
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cellindex = indexPath.row;
            return cell;
        }
    }else{
        //显示更多按钮下的tableView
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = [UIColor grayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        //设置cell的点击没有阴影效果
        cell.selectionStyle = UITableViewCellAccessoryNone;
        if(indexPath.row == 0){
            cell.imageView.image = [UIImage imageNamed:@"dingshiqi"];
            cell.textLabel.text = @"定时器";
        }else{
            cell.imageView.image = [UIImage imageNamed:@"sousuo"];
            cell.textLabel.text = @"搜索";
        }
        return cell;
    }
}
//每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==1){
        if(isinsearch == 1){
            NSString *str = self.searchArray[indexPath.row];
            //计算高度
            NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:17.f ]};
            CGFloat cellheight = [str boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, 1000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.height;
            return cellheight;
        }else{
            if(isinlist){
//                frame = self.textArray[indexPath.row];
//                return frame.cellHeight;
                return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.frame.size.width tableView:tableView];
            }else{
//                frame = self.statusFramesArray[indexPath.row];
//                return frame.cellHeight;
                return [self cellHeightForIndexPath:indexPath cellContentViewWidth:self.view.frame.size.width tableView:tableView];
            }
        }
    }else{
        return 30;
    }
}
//点击每行的响应事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==1){
        if(!isinsearch){
            detailCell *detail = [[detailCell alloc] init];
            //隐藏tabBar
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detail animated:YES];
            //退出时重现tabbar
            self.hidesBottomBarWhenPushed = NO;
            if(isinlist){
                //这个是经过搜索后过滤出来的数据
                dict = self.searchdetailArray[indexPath.row];
            }else{
                //这个是原始的微博数据
                dict = self.jsonArray[indexPath.row];
            }
        }
        //如果点击更多没有取消的时候先把更多这个tableView移除掉
        [_moretableView removeFromSuperview];
    }else{
        if (indexPath.row==1) {
            [self.search sd_resetNewLayout];
            [self.view addSubview:self.search];
            self->_search.sd_layout
            .topSpaceToView(self.navigationController.navigationBar,0)
            .leftEqualToView(self.navigationController.navigationBar)
            .rightEqualToView(self.navigationController.navigationBar)
            .heightIs(35);
            //点击之后把moretableView移除掉
             [_moretableView removeFromSuperview];
        }else{
            [self begintimeUp];
            //点击之后把moretableView移除掉
            [_moretableView removeFromSuperview];
        }
    }
   
}

//旋转屏幕时刷新tableView
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.tableView reloadData];
}

@end


