//
//  postView.h
//  weibo
//
//  Created by kkkak on 2020/5/8.
//  Copyright © 2020 kkkak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "postModel.h"
#import "myphotosView.h"
@interface postView : UITableViewCell

//快速组装postView
-(postView *)buildpostView: (postModel *)postmodel;
-(postView *)buttonup: (UIButton *)button : (NSNumber *) model;
-(postView *)clapclick:(UIButton *)btn;
@end

