//
//  searchCell.m
//  weibo
//
//  Created by MacBook pro on 2020/5/27.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import "searchCell.h"

@implementation searchCell

//创建cell
+(instancetype)cellWithsearchtableView:(UITableView *)tableView
{
    static NSString *cellID = @"searchID";
    searchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[searchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
