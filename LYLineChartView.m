//
//  LineChartView.m
//  MDSeller
//
//  Created by Lee on 2017/3/16.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import "LYLineChartView.h"

#define kLeftEmptySpace   44

#define kRightEmptySpace   25

#define kRedLineHeight 174

@interface LYLineChartView()

@property (nonatomic, strong) NSArray *sourceArr;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) NSMutableArray *pointArr;

@property (nonatomic, strong) NSArray *times;

@property (nonatomic, strong) UIView *redLine;

@end

@implementation LYLineChartView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self Config];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self Config];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self Config];
    }
    return self;
}

- (void)Config
{
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
}

- (void)setDataSourceWithArray:(NSArray *)sourceArr times:(NSArray*)times drawStyle:(LineChartDrawStyle)stlye;
{
    _sourceArr = sourceArr;

    _times = times;
    
    [self getPoingArr];
}

//背景网格
- (void)drawBackLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    [[UIColor lightGrayColor] set];
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0f);  //线宽
    CGFloat lineX, lineY;
    //多条横线 目前固定6条
    NSInteger count = self.times.count - 1;
    for (int i = 0; i < count; i++) {
        lineX = kLeftEmptySpace;
        lineY = self.frame.size.height / (count - 1) * i;
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, lineX, lineY);//起点坐标
        
        lineX = self.frame.size.width  - kRightEmptySpace;
        CGContextAddLineToPoint(context, lineX, lineY);   //终点坐标
        CGContextStrokePath(context);
        
    }
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.frame.size.height );
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextStrokePath(context);
    
    //多条竖线
    for (int i = 0; i < self.times.count; i++) {
        CGFloat width = (self.frame.size.width - kLeftEmptySpace - kRightEmptySpace)/(self.times.count - 1);
        lineX = kLeftEmptySpace + width*i;
        lineY = 0;
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, lineX, lineY);//起点坐标
        
        lineY = self.frame.size.height ;
        CGContextAddLineToPoint(context, lineX, lineY);//终点坐标
        
        CGContextStrokePath(context);
    }
}

- (void)getPoingArr
{
    //获取两个数组中最大的值
    CGFloat maxValue = 0.0;
    
    for (NSInteger i = 0; i < _sourceArr.count; i ++) {
        CGFloat singleArrMaxValue = [[_sourceArr[i] valueForKeyPath:@"@max.floatValue"] floatValue];
        if (singleArrMaxValue > maxValue) {
            maxValue = singleArrMaxValue;
        }
    }
    
    //数据转换成点
    CGFloat pointX;
    CGFloat pointY;
    for (NSInteger i = 0; i < _sourceArr.count; i ++) {
        NSArray *arr = _sourceArr[i];
        NSMutableArray *littlePointArr = [NSMutableArray array];
        CGFloat timeSpace = (self.frame.size.width - kLeftEmptySpace - kRightEmptySpace) / (arr.count - 1);
        for (NSInteger i = 0; i < arr.count; i++) {
            CGFloat num = [arr[i] floatValue];
            CGFloat percent;
            if (maxValue == 0) {
                percent = 1;
            }else{
            percent = 1 - num / maxValue;
            }
            pointX = kLeftEmptySpace + timeSpace * i;
            pointY = self.frame.size.height * percent;
            CGPoint pt = CGPointMake(pointX, pointY);
            [littlePointArr addObject:[NSValue valueWithCGPoint:pt]];
        }
        [self.pointArr addObject:littlePointArr];
    }
    
    /*
     数据转换完毕 绘制XY轴
     */
    [self setY:maxValue];
    [self drawTimes];
    
}


- (void)drawTimes
{
    for (NSInteger i = 0; i < self.times.count; i ++) {
        CGFloat timeLabelWidth = (self.frame.size.width - kLeftEmptySpace - kRightEmptySpace) / (self.times.count - 1);
        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(kLeftEmptySpace - timeLabelWidth / 2 + timeLabelWidth * i, self.frame.size.height, timeLabelWidth, 25)];
        lb.textColor = [UIColor blackColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.font = [UIFont systemFontOfSize:10];
        lb.text = _times[i];
        [self addSubview:lb];
    }
}

- (void)setY:(CGFloat)maxY;
{
    if (_pointArr.count <= 0) {
        return;
    }
    NSInteger count = 5;
    CGFloat Y = 0;
    for (NSInteger i = 0; i < count; i ++) {
        Y = self.frame.size.height / count * i;
        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, Y, kLeftEmptySpace, 20)];
        lb.center = CGPointMake(lb.center.x, Y);

        if (maxY < 1) {
            lb.text = [NSString stringWithFormat:@"%.2f",maxY / count * (count - i)];
        }else{
            lb.text = [NSString stringWithFormat:@"%.0f",maxY / count * (count - i)];
        }
        lb.textColor = [UIColor blackColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.font = [UIFont systemFontOfSize:10];
        [self addSubview:lb];
    }
}

- (void)drawRect:(CGRect)rect{
    [self drawBackLines];

    for (NSInteger i = 0; i < self.pointArr.count; i ++) {
        [self drawWithPoints:self.pointArr[i] withNumber :i];
    }
}

- (void)drawWithPoints:(NSArray *)arr withNumber:(NSInteger )num
{
    UIColor *backColor1;
    UIColor *backColor2;
    UIColor *pointColor;
    if (num == 0) {
        backColor1 = [UIColor colorWithRed:(232/255.0) green:(187/255.0) blue:(185/255.0) alpha:0.7];
        pointColor = [UIColor redColor];
    }else if (num == 1) {
        backColor1 = [UIColor colorWithRed:(178/255.0) green:(224/255.0) blue:(242/255.0) alpha:0.7];
        pointColor = [UIColor blueColor];
    }else{
        backColor1 = [UIColor colorWithRed:(022/255.0) green:(201/255.0) blue:(160/255.0) alpha:0.7];
        pointColor = [UIColor greenColor];
    }
        backColor2 = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:0.3];
    
    
    //取得起始点
    CGPoint p1 = [[arr objectAtIndex:0] CGPointValue];
    
    //直线的连线
    UIBezierPath *beizer = [UIBezierPath bezierPath];
    [beizer moveToPoint:p1];
    
    //遮罩层的形状
    UIBezierPath *bezier1 = [UIBezierPath bezierPath];
    bezier1.lineCapStyle = kCGLineCapRound;
    bezier1.lineJoinStyle = kCGLineJoinMiter;
    [bezier1 moveToPoint:p1];
    
    for (int i = 0;i<arr.count;i++ ) {
        CGPoint point = [[arr objectAtIndex:i] CGPointValue];
        
        //动态加点
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 6, 6)];
        view.center = point;
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 3;
        view.layer.borderWidth = 1.0f;
        view.userInteractionEnabled = NO;
        view.layer.borderColor = pointColor.CGColor;
        view.backgroundColor = [UIColor whiteColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2/arr.count *i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addSubview:view];
        });
        if (i != 0) {
            //直线连接
//                [beizer addLineToPoint:point];
//
//                [bezier1 addLineToPoint:point];
            
            //曲线连接
            CGPoint prePoint = [[arr objectAtIndex:i-1] CGPointValue];
            CGPoint nowPoint = [[arr objectAtIndex:i] CGPointValue];
            
            [beizer addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
            
            [bezier1 addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
            
            
            if (i == arr.count-1) {
                [beizer moveToPoint:point];//添加连线
                _lastPoint = point;
            }
        }
    }
    
    CGFloat bgViewHeight = self.frame.size.height;
    
    //获取最后一个点的X值
    CGFloat lastPointX = _lastPoint.x;
    
    //最后一个点对应的X轴的值
    
    CGPoint lastPointX1 = CGPointMake(lastPointX, bgViewHeight);
    
    [bezier1 addLineToPoint:lastPointX1];
    
    //回到原点
    
    [bezier1 addLineToPoint:CGPointMake(p1.x, bgViewHeight)];
    
    [bezier1 addLineToPoint:p1];
    
    //遮罩层
    CAShapeLayer *shadeLayer = [CAShapeLayer layer];
    shadeLayer.path = bezier1.CGPath;
    shadeLayer.fillColor = [UIColor greenColor].CGColor;
    
    
    //渐变图层
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(5, 0, 0,self.frame.size.height);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.cornerRadius = 5;
    gradientLayer.masksToBounds = YES;
    NSArray *colors = [NSArray arrayWithObjects:(id)backColor1.CGColor, backColor2.CGColor, nil];
    gradientLayer.colors = colors;
    gradientLayer.locations = @[@(0.5f)];

    
    CALayer *baseLayer = [CALayer layer];
    
    
//    [baseLayer addSublayer:gradientLayer];
    [baseLayer setMask:shadeLayer];
    
    [self.layer addSublayer:baseLayer];
    
    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds";
    anmi1.duration = 2.2;
    anmi1.toValue = [NSValue valueWithCGRect:CGRectMake(5, 0, 2*_lastPoint.x, self.frame.size.height)];
    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi1.fillMode = kCAFillModeForwards;
    anmi1.autoreverses = NO;
    anmi1.removedOnCompletion = NO;
    
    [gradientLayer addAnimation:anmi1 forKey:@"bounds"];
    
    
    //*****************添加动画连线******************//
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = beizer.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = pointColor.CGColor;
    shapeLayer.lineWidth = 1;
    [self.layer addSublayer:shapeLayer];
    
    
    CABasicAnimation *anmi = [CABasicAnimation animation];
    anmi.keyPath = @"strokeEnd";
    anmi.fromValue = [NSNumber numberWithFloat:0];
    anmi.toValue = [NSNumber numberWithFloat:1.0f];
    anmi.duration = 2;
    anmi.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi.autoreverses = NO;
    
    [shapeLayer addAnimation:anmi forKey:@"stroke"];
    
    
    //竖线放最上面
    [self addSubview:self.redLine];
 
}

- (void)showRedLineWithX:(CGFloat)x
{
    
    if (x < kLeftEmptySpace) {
        x = kLeftEmptySpace;
    }
    if (x > self.frame.size.width - kRightEmptySpace) {
        x = self.frame.size.width - kRightEmptySpace;
    }
    
    CGFloat minDisTance = self.frame.size.width;
    CGFloat moveToPt = 0;
    NSArray *arr = [_pointArr firstObject];
    for (NSInteger i = 0; i < arr.count; i++) {
        CGPoint pt = [arr[i] CGPointValue];
        if (fabs(pt.x - x) < minDisTance) {
            minDisTance = fabs(pt.x - x);
            moveToPt = pt.x;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rec = self.redLine.frame;
        rec.origin.x = moveToPt;
        self.redLine.frame = rec;
    }];
    
}

#pragma mark   ---点击事件---
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event touchesForView:self] anyObject];
    CGPoint point = [touch locationInView:self];
    int x = point.x;
    int y = point.y;
    NSLog(@"touch (x, y) is (%d, %d)", x, y);
    [self showRedLineWithX:x];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event touchesForView:self] anyObject];
    CGPoint point = [touch locationInView:self];
    int x = point.x;
    int y = point.y;
    NSLog(@"touch (x, y) is (%d, %d)", x, y);
    [self showRedLineWithX:x];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (UIView *)redLine
{
    if (!_redLine) {
        _redLine = [[UIView alloc]initWithFrame:CGRectMake(kLeftEmptySpace, 0, 1, self.frame.size.height)];
        _redLine.backgroundColor = [UIColor redColor];
    }
    return _redLine;
}

- (NSMutableArray *)pointArr
{
    if (!_pointArr) {
        _pointArr = [NSMutableArray array];
    }
    return _pointArr;
}


@end

