//
//  frameload.h
//  weibo
//
//  Created by MacBook pro on 2020/5/19.
//  Copyright © 2020年 kkkak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface frameload : NSString

-(CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW;
-(CGSize)sizeWithText:(NSString *)text font:(UIFont *)font;
@end
