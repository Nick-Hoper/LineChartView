//
//  LineChartView.h
//  LineChartView
//
//  Created by test on 16/7/28.
//  Copyright © 2016年 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LineChartView : UIView

//横竖轴距离间隔
@property (assign) float hInterval;
@property (assign) float vInterval;

//因为需要动态改变纵坐标，增加开始以及结束纵坐标
@property (assign) float starValue;
@property (assign) float endValue;

//横竖轴显示标签
@property (nonatomic, strong) NSArray *hDesc;
@property (nonatomic, strong) NSArray *vDesc;

//横坐标长度
@property (assign) float maxWidth;
//纵坐标长度
@property (assign) float maxHeight;

//点信息
@property (nonatomic, strong) NSMutableArray *array;

//纵坐标
@property (nonatomic, strong) NSString *verticalNameCalled;

//设置数据
-(void)setDataArray:(NSMutableArray *)mutuArray;

- (void)setPointClickedBlock:(void (^)(NSArray *index))block;
@end


