//
//  sendViewController.m
//  weibo
//
//  Created by kkkak on 2020/5/4.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "sendViewController.h"
#import "postView.h"
#import "myViewController.h"
#import "placeholderview.h"
#import "picView.h"
#import "frameload.h"
#import "postphotosView.h"
#import "AFNetworking.h"
#import "SDAutoLayout.h"

@interface sendViewController ()<UITextViewDelegate,picViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
//TextView设置的占位字
@property (nonatomic, strong) placeholderview *textView;
//发微博时存放图片的view
@property (nonatomic, strong) UIView *photoView;
//用来判断发图片还是发文字
@property (nonatomic,assign) BOOL sendphoto;
//用来存储要发送的图片
@property (nonatomic, weak) UIImage *postImage;
//把图片的链接存起来
@property (nonatomic, copy) NSString *picstr;
//显示图片的view
@property (nonatomic, weak) postphotosView *postimageV;
//把添加的图片装进数组里面
@property (nonatomic, strong) NSMutableArray *photosArray;

@end

@implementation sendViewController

//懒加载装有图片数据的数组
- (NSMutableArray *)photosArray
{
    if(!_photosArray){
        self.photosArray= [[NSMutableArray alloc] init];
    }
    return _photosArray;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景view的颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    //初始化导航条和textView
    [self setUpnavandtextV];
    
    //初始化发图片的键盘上的UIView
    [self setUppicV];
    
    //初始化添加图片的view
    [self setUpphotoV];

    //文本内容改变时监听通知(动态设置发送按钮的使用)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textchange) name:UITextViewTextDidChangeNotification object:_textView];
}

#pragma mark - 初始化导航条和textView
-(void)setUpnavandtextV
{
    //设置导航栏的内容
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:0 target:self action:@selector(post)];
    
    //一开始textView没有东西设置不可点击发送按钮
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //设置编辑内容的文本
    self.textView = [[placeholderview alloc] init];
    //textView在垂直方向上永远可以拖拽
    _textView.alwaysBounceVertical = YES;
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = @"分享新鲜事...";
    _textView.placeColor = [UIColor grayColor];
    _textView.font = [UIFont systemFontOfSize:20.0f];
    
    //能输入文本的控件成为第一响应者就会立刻弹出键盘
    [_textView becomeFirstResponder];
    [self.view addSubview:self.textView];
    
    //添加约束
    _textView.sd_layout
    .topEqualToView(self.view)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(200);
}

#pragma mark - 初始化textView上的显示图片的View
-(void)setUpphotoV
{
    postphotosView *photosV = [[postphotosView alloc] init];
    photosV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:photosV];
    _postimageV = photosV;
    
    //添加约束
    photosV.sd_layout
    .topSpaceToView(self.view, 200)
    .leftSpaceToView(self.view, 0)
    .widthIs([UIScreen mainScreen].bounds.size.width)
    .heightIs(300);
    
}

#pragma mark - 初始化键盘上方的点击发送图片的按钮
-(void)setUppicV
{
    //自己创建一个view（这里我用的是自己定义的picView，换成UIView那些也是一样的)
    picView *picV = [[picView alloc] init];
    picV.frame = CGRectMake(0, 0, self.textView.bounds.size.width, 35);
    picV.delegate = self;
    //inputAccessoryView这个是设置填充键盘顶部的内容
    //设置在textView是因为键盘是textView叫出的
    self.textView.inputAccessoryView= picV;
}

#pragma mark - 实现系统相册的代理方法
-(void)clickpicView:(UIButton *)btn
{
    //拿到获取相册的权限
    //UIImagePickerController是iOS系统提供的和系统的相册和相机交互的一个类,可以用来获取相册的照片,也可以调用系统的相机拍摄照片或者视频
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        UIImagePickerController *pic = [[UIImagePickerController alloc] init];
        pic.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pic.delegate = self;
        [self presentViewController:pic animated:YES completion:nil];
    }
}
//点击相片后会跑这个方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //_sendphoto用来判断发微博是带有图片的
     _sendphoto = YES;
    //拿到图片会就销毁之前的控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    //info中就是包含你在相册里面选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //显示添加的图片
    [_postimageV addimageV:image];
    //把添加的图片保存到数组里面
    //因为要保存要plist文件所以要先把它转变为string类型
    //这是将image转成字符串，然后存进plist文件里
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    //NSDataBase64Encoding64CharacterLineLength：每64个字符插入\r或\n
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self.photosArray addObject:encodedImageStr];
}

#pragma mark - 监听发送按钮是否可以点击
-(void)textchange
{
    self.navigationItem.rightBarButtonItem.enabled = self.textView.hasText;
}

#pragma mark - 发布文章
-(void)post
{
    //设置弹窗
    //UIAlertControllerStyleAlert 在视图中间弹出提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定发布?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //添加取消按钮
    //默认的取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //添加确定按钮
    //默认的确定按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //如果点击了相册的图片，那么_sendphoto就会是YES
        if(!self->_sendphoto){
            [self writetoFile];
            [self writetoVb];
        }else{
            [self writetoFile];
            //清了显示图片的view
            [self.postimageV removeFromSuperview];
        }
        //发布通知(告诉个人主页的控制器要刷新数据)
        NSNotification *post = [NSNotification notificationWithName:@"didpost" object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:post];

        //清空原来文本内容
        self.textView.text = nil;
        
        //回到个人主页的控制器
        [self.navigationController popViewControllerAnimated:YES];
    }];
    //把提示框按钮添加到提示控制器上
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    //让提示框可以显示
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITextView的代理方法
//textView拖拽时退下键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textView endEditing:YES];
}

#pragma mark - 把信息写进plist文件
//把文本内容写进plist文件
-(void)writetoFile
{
    //获取沙盒文件里面的collect.plist路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES)[0];
    NSString *filepath = [path stringByAppendingPathComponent:@"datacollect.plist"];
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
            NSLog(@"创建collect.plist失败了");
        }
        
    }
    else{
        //获取collect.plist文件里面原有的数据
        dataArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    }
    //设置要加入列表的数据（把字典添加到数组里面)
    NSMutableArray *collectArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    //计算输入的文本内容的高度
    //NSStringDrawingUsesLineFragmentOrigin： 多行文本使用该参数
    //NSStringDrawingUsesFontLeading: 使用行距计算行高(行距=行间距+字体高度)
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:17.f ]};
    CGRect cellheight = [self.textView.text boundingRectWithSize:CGSizeMake(self.textView.frame.size.width-20,MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    //index是用来到时候判断当前cell的index(点赞评论转发用到)
    int index = (int)dataArray.count;
    NSNumber *kindex = [NSNumber numberWithInt:index];
    //设置字典里面的数据
    [dict setObject:kindex forKey:@"index"];
    [dict setObject:self.textView.text forKey:@"text"];
    [dict setObject:@0 forKey:@"clapSum"];
    [dict setObject:@0 forKey:@"commentSum"];
    [dict setObject:@0 forKey:@"forwardSum"];
    //cell的整体高度
    if(_sendphoto){
        //根据图片数量计算放图片的view的高度
        //35是工具条的高度 20是预留多一点的高度
        CGFloat high = [self photosSIzetocount:(int)self.photosArray.count];
        NSNumber *number = [NSNumber numberWithInt:(int)cellheight.size.height+35+20+high];
        [dict setObject:number forKey:@"cellHeight"];
    }else{
        NSNumber *number = [NSNumber numberWithInt:(int)cellheight.size.height+35+20];
        [dict setObject:number forKey:@"cellHeight"];
    }
    //图片的数据
    if(_sendphoto){
        [dict setObject:self.photosArray forKey:@"photo"];
        [dict setObject:@1 forKey:@"hasphoto"];
    }
    [collectArray addObject:dict];
    //将最新的微博数据添加到总数组的最前面
    NSRange range = NSMakeRange(0, collectArray.count);
    NSIndexSet *nsindex = [NSIndexSet indexSetWithIndexesInRange:range];
    [dataArray insertObjects:collectArray atIndexes:nsindex];
    //把数组重新写入文件
    BOOL flag =[dataArray writeToFile:filepath atomically:YES];
    if(flag){
        //self->_sendphot设置为NO表示这次发微博不管有没有图片也不会影响下一次发微博时的判断
        self->_sendphoto= NO;
        NSLog(@"写入成功");
    }
}
//发表文字去微博
-(void)writetoVb
{
    //创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //拼接
    NSString *newstr = [NSString stringWithFormat:@"%@ http://www.mob.com",self.textView.text];
    NSDictionary *dict = @{
                           @"access_token":@"2.00rEQ4BGf5ulTCa0681d9d29h6xTwB",
                           @"status":newstr
                           };
    

//    第一个参数（POST）：NSString类型的请求路径，AFN内部会自动将该路径包装为一个url并创建请求对象
//    第二个参数（parameters）：请求参数，以字典的方式传递，AFN内部会判断当前是POST请求还是GET请求，以选择直接拼接还是转换为NSData放到请求体中传递
//    第三个参数（progress）：请求的进度回掉
//    第四个参数（success）：请求成功回调Block
//    第五个参数（responseObject）：返回的数据
    
    //发送POST请求
    [manager POST:@"https://api.weibo.com/2/statuses/share.json" parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"发送成功");
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败");
          }];
}

#pragma mark - 根据微博的图片数量计算imageView的宽和高
-(CGFloat)photosSIzetocount:(int)count
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
    return photosH;
}

@end
