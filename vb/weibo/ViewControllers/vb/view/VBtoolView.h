//
//  VBtoolView.h
//  weibo
//
//  Created by MacBook pro on 2020/5/19.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class statuses;
@interface VBtoolView : UIView
@property(nonatomic, strong) statuses *status;
//封装工具条
+(instancetype)toolView;
@end
