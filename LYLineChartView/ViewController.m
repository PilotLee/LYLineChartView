//
//  ViewController.m
//  LYLineChartView
//
//  Created by Lee on 2017/8/24.
//  Copyright © 2017年 洋李. All rights reserved.
//

#import "ViewController.h"
#import "LYLineChartView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    LYLineChartView *lineChart = [[LYLineChartView alloc]initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 250)];
    [lineChart setDataSourceWithArray:@[@[@"2",@"3",@"4",@"5",@"6",@"7",@"8"],
                                        @[@"3",@"4",@"2",@"7",@"7",@"4",@"1"],
                                        @[@"4",@"5",@"1",@"1",@"2",@"7",@"8"]] times:@[@"2-1",@"2-2",@"2-3",@"2-4",@"2-5",@"2-6",@"2-7"] drawStyle:DrawStlyeCruve];
    [self.view addSubview:lineChart];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
