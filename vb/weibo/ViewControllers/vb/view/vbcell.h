//
//  vbcell.h
//  weibo
//
//  Created by MacBook pro on 2020/5/16.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class statusFrame;
@interface vbcell : UITableViewCell

@property (nonatomic, strong) statusFrame *statusFrame;

//微博头像的内存缓存//
@property (nonatomic, strong) NSMutableDictionary *icondict;

+(instancetype)cellWithtableView:(UITableView *)tableView;

@end
