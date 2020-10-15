//
//  videoPlay.m
//  weibo
//
//  Created by MacBook pro on 2020/7/25.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import "videoPlay.h"
#import <AVKit/AVKit.h>
@interface videoPlay ()

@end

//视频的str
extern NSString *videostr;

@implementation videoPlay

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL* url = [NSURL URLWithString:videostr];
    AVPlayer* player = [[AVPlayer alloc] initWithURL:url];
    AVPlayerViewController* playerController = [[AVPlayerViewController alloc]init];
    playerController.player = player;
    playerController.view.frame = self.view.bounds;
    [self addChildViewController:playerController];
    [self.view addSubview:playerController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
