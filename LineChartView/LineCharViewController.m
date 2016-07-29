//
//  LineCharViewController.m
//  LineChartView
//
//  Created by test on 16/7/28.
//  Copyright © 2016年 test. All rights reserved.
//

#import "LineCharViewController.h"
#import "LineChartView.h"

#import <UIKit/UIKit.h>
#define IsiOS7Later                         !( [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

@interface LineCharViewController ()


//温度值数组
@property (nonatomic, strong) NSMutableArray *tempArray;

//曲线
@property (nonatomic, strong) LineChartView *lineChartView;

//提示视图，主要用于提示自定义曲线时提示
@property (nonatomic, strong) UIButton *hiddenButton;

//曲线容器
@property (nonatomic,strong) UIScrollView *detailScrollView;

@end

@implementation LineCharViewController

- (void)viewDidLoad {
   
    
    [super viewDidLoad];
 
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //创建一个导航栏
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    //创建一个导航栏集合
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"温度曲线设置"];
   
    //设置背景颜色为天蓝色
    [navBar setBarTintColor:[UIColor colorWithRed:0.164 green:0.657 blue:0.915 alpha:1.000]];
    
    //设置导航栏的内容
    [navItem setTitle:@"温度曲线设置"];
    
    //把导航栏集合添加到导航栏中，设置动画关闭
    [navBar pushNavigationItem:navItem animated:NO];
    
    //将标题栏中的内容全部添加到主视图当中
    [self.view addSubview:navBar];


    //坐标
    CGRect viewFrame = CGRectZero;
 
    //初始化数组大小
    _tempArray = [[NSMutableArray alloc] initWithCapacity:24];
   
    _detailScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(35, 68, self.view.frame.size.width, self.view.frame.size.height - (IsiOS7Later ? 40 : 0) - 100)];
    [_detailScrollView setContentSize:CGSizeMake(self.view.bounds.size.width*3-80, self.view.frame.size.height - (IsiOS7Later ? 40 : 0) - 100)];
    [_detailScrollView setShowsVerticalScrollIndicator:NO];
    [_detailScrollView setShowsHorizontalScrollIndicator:NO];
    [_detailScrollView setAlwaysBounceVertical:NO];
    [_detailScrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_detailScrollView];
    
    
    //隐藏视图
    _hiddenButton = [[UIButton alloc] initWithFrame:_detailScrollView.frame];
    [_hiddenButton setBackgroundColor:[UIColor clearColor]];
    [_hiddenButton addTarget:self action:@selector(tipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hiddenButton];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"btn_bg@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x = (self.view.frame.size.width - image.size.width) / 2.f;
    viewFrame.origin.y =  _detailScrollView.frame.size.height + _detailScrollView.frame.origin.y;
    viewFrame.size = CGSizeMake(70, 70);
    UIButton *resetButton = [[UIButton alloc] initWithFrame:viewFrame];
    [resetButton setBackgroundColor:[UIColor clearColor]];
    [resetButton setBackgroundImage:image forState:UIControlStateNormal];
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [resetButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [resetButton.titleLabel setNumberOfLines:1.f];
    [resetButton setTag:1];
    [resetButton addTarget:self action:@selector(resetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
}


//主要用于刷新曲线
-(void)refreshUI:(NSMutableArray *)tempArray
{
    for (UIView *tempView in [_detailScrollView subviews]) {
        [tempView removeFromSuperview];
    }
    
    float tmpHeightValue = self.view.frame.size.height - (IsiOS7Later ? 40 : 0) - 100;
    
    _lineChartView = [[LineChartView alloc] initWithFrame:CGRectMake(-35, 0, self.view.frame.size.width*3, tmpHeightValue)];
    
    //长度
    [_lineChartView setMaxWidth:_lineChartView.frame.size.width*3];
    
    //高度
    float tmpHeight;
    
    tmpHeight = (_lineChartView.frame.size.height - 50) / 31.f;
    [_lineChartView setStarValue:30.0];
    [_lineChartView setEndValue:60.0];
    
    
    //高度
    [_lineChartView setMaxHeight:_lineChartView.frame.size.height - 30];
    
    //垂直线
    [_lineChartView setVInterval:tmpHeight];
    
    //水平线
    [_lineChartView setHInterval:35];
    [_lineChartView setBackgroundColor:[UIColor clearColor]];
    
    //最大数据
    NSMutableArray *xTextArray = [[NSMutableArray alloc] initWithCapacity:24];
    NSMutableArray *vArr = [[NSMutableArray alloc] initWithCapacity:20];
    
    //纵坐标数据
    for (int i = 0; i < 7; i++)
    {
        [vArr addObject:[NSString stringWithFormat:@"%d",30+i*5]];
    }
    
    
    //横坐标数据 数据从8:00 - 23:00
    for(int i = 0 ; i < 24; i++)
    {
        [xTextArray addObject:[NSString stringWithFormat:@"%02d:00",i]];
        
    }
    
    //坐标参数
    [_lineChartView setHDesc:xTextArray];
    [_lineChartView setVDesc:vArr];
    [_lineChartView setArray:tempArray];
    [_detailScrollView addSubview:_lineChartView];
    
    //设置纵坐标,为了能够左右滑动，把纵坐标提到外层，移动时保持纵坐标不变
    float y = tmpHeightValue + 35;
    float newInterval = tmpHeight*5.f;
    
    //垂直的点和水平的线
    for (int i = 0; i< vArr.count ; i++)
    {
        
        //设置纵坐标
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35,newInterval)];
        [label setCenter:CGPointMake(35 / 2.f, y)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor lightGrayColor]];
        
         NSString *string = [vArr objectAtIndex:i];
        [label setText:[NSString stringWithFormat:@"%@%@",[string substringToIndex:2], @"°"]];
        [label setFont:[UIFont systemFontOfSize:13.f]];
        [self.view addSubview:label];
        
        
        //设置
        y -= newInterval;
    }

    
    
    //回传函数
    [_lineChartView setPointClickedBlock:^(NSArray *array) {
        for (int i = 0; i < [array count]; i++) {
            NSLog(@"Temp = %d,%@",i,[array objectAtIndex:i]);
        }
        //保存睡眠数组
        _tempArray = [[NSMutableArray alloc] initWithArray:array];
        
    }];
    
}

//初始化数据
-(void)resetButtonClick:(UIButton *)button
{

    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"  message:@"您是要恢复初始化数据吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 300;
    [alertView show];

}

//提示按钮点击
-(void)tipButtonClick
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"  message:@"您是要自定义曲线吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 400;
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 300)
    {
        if (buttonIndex == 0)// 点击了取消按钮
        {
            
        }
        else // 点击了确定按钮
        {
            [self iniTempArray];
            [self refreshUI:_tempArray];
            _hiddenButton.hidden=NO;
        }
    }
    
    if (alertView.tag == 400)
    {
        if (buttonIndex == 0)// 点击了取消按钮
        {
            _hiddenButton.hidden=NO;
        }
        else // 点击了确定按钮
        {
           _hiddenButton.hidden=YES;
        }
    }

}

//初始化数据
-(void)iniTempArray
{
    //设置默认值
    [_tempArray removeAllObjects];
    
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:40]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:40]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:40]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:40]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:45]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:45]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:45]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:45]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:53]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:57]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:59]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:55]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:45]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:55]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:55]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:45]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:35]]];
    [_tempArray addObject:[NSNumber numberWithInt:[self setTempValue:55]]];
}

//取值范围,防止溢出
-(int)setTempValue:(int)tempValue
{
    int returnInt = tempValue;
    if(tempValue > 60)
    {
        returnInt = 60;
    }
    else if (tempValue < 30)
    {
        returnInt = 30;
    }
    
    return returnInt;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //如果没有温度数组时，就隐藏自定义曲线提示
    if (_tempArray.count<=0) {
        
        _hiddenButton.hidden=YES;
    }
    else
    {
         _hiddenButton.hidden=NO;
    }
    [self refreshUI:_tempArray];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
