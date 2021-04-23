//
//  UIView+Extension.h
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat top;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat bottom;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;
@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;


/**
 *  remove all subviews
 */
- (void)mj_removeAllSubviews;


@end
