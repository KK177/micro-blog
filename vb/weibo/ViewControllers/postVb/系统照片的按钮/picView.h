//
//  picView.h
//  weibo
//
//  Created by MacBook pro on 2020/5/29.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class picView;

//监听picView里的按钮的点击（成为它的代理）
@protocol picViewDelegate<NSObject>
@optional
-(void)clickpicView:(UIButton *)btn;
@end

@interface picView : UIView
@property (nonatomic,weak)id<picViewDelegate>delegate;

@end
