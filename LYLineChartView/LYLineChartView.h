//
//  LineChartView.h
//  MDSeller
//
//  Created by Lee on 2017/3/16.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 折线图样式

 - DrawStlyeDefult: 默认直线
 - DrawStlyeCruve: 曲线
 */

typedef NS_ENUM(NSInteger,LineChartDrawStyle) {
    DrawStlyeDefult = 0,
    
    DrawStlyeCruve = 1
    
};

@interface LYLineChartView : UIView


/**
 初始化后给配置

 @param sourceArr 数据源（可传入多维数组 内部自动转换）
 @param times 时间标签
 @param stlye 折线／曲线
 @param hasCover 是否有遮罩
 */
- (void)setDataSourceWithArray:(NSArray *)sourceArr times:(NSArray*)times drawStyle:(LineChartDrawStyle)stlye hasCover:(BOOL)hasCover;

@end

