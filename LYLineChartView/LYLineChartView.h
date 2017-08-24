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


- (void)setDataSourceWithArray:(NSArray *)sourceArr times:(NSArray*)times drawStyle:(LineChartDrawStyle)stlye;

@end

