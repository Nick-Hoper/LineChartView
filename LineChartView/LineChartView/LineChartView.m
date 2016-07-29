//
//  LineChartView.m
//  LineChartView
//
//  Created by test on 16/7/28.
//  Copyright © 2016年 test. All rights reserved.
//

#import "LineChartView.h"


typedef void(^itemClickedBlock)(NSArray *index);

@interface LineChartView()
{
    CALayer *linesLayer;
    //选择的第几个点
    int selectedButton;
    //选择的点的数值
    int selectedValue;
    CGContextRef context;
}
@property (nonatomic, copy) itemClickedBlock clickedBlock;
@property (nonatomic, strong) UIView *popView;
@property (nonatomic, strong) UILabel *disLabel;
@end

@implementation LineChartView

@synthesize array;

@synthesize hInterval,vInterval;

//因为需要动态改变纵坐标，需要增加设置
@synthesize starValue,endValue;

@synthesize hDesc,vDesc;

@synthesize maxHeight,maxWidth;

@synthesize verticalNameCalled;

-(void)dealloc
{
    _popView = nil;
    _disLabel = nil;
    _clickedBlock = nil;
    linesLayer = nil;
    selectedButton = 0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        selectedButton = 0;
        selectedValue = 0;
      
        //初始化
        linesLayer = [[CALayer alloc] init];
        linesLayer.masksToBounds = YES;
        linesLayer.contentsGravity = kCAGravityLeft;
        linesLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        [self.layer addSublayer:linesLayer];
        
        //PopView
        UIImage *image = [UIImage imageNamed:@"input"];
        _popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [_popView setBackgroundColor:[UIColor clearColor]];
        //添加背景图片
        CGRect viewFrame = CGRectZero;
        viewFrame.size = image.size;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewFrame];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setImage:image];
        [_popView addSubview:imageView];
        //添加文字
        viewFrame.origin.x = 0;
        viewFrame.origin.y = 0;
        viewFrame.size = CGSizeMake(image.size.width, 20);
        _disLabel = [[UILabel alloc]initWithFrame:viewFrame];
        [_disLabel setBackgroundColor:[UIColor clearColor]];
        [_disLabel setNumberOfLines:1.f];
        [_disLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_disLabel setTextAlignment:NSTextAlignmentCenter];
        [_popView addSubview:_disLabel];
        //隐藏
        [_popView setHidden:YES];
        [self addSubview:_popView];
    }
    return self;
}

#define ZeroPoint CGPointMake(hInterval,maxHeight-vDesc)
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self setClearsContextBeforeDrawing: YES];
    
    context = UIGraphicsGetCurrentContext();
    //
    CGContextSetLineJoin(context, kCGLineJoinRound);
    //
    CGContextSetLineCap(context, kCGLineCapRound);
    //
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGFloat lengths[] = {2,2};//先画4个点再画2个点
    
    CGContextSetLineDash(context,0, lengths,2);//注意2(count)的值等于lengths数组的长度
    
    //最大的尺寸()
    float y = maxHeight;
    //起始坐标
    CGPoint startPoint;
    //终点坐标
    CGPoint endPoint;
    
    float newInterval;
    NSNumber *a=[NSNumber numberWithFloat:60.0];
    NSNumber *b=[NSNumber numberWithFloat:endValue];
    
    //加5倍单位让纵坐标间隔为5
    if ([a compare:b]==NSOrderedAscending||[a compare:b]==NSOrderedSame) {
        newInterval = vInterval*5.f;
    }
    else
    {
        newInterval = vInterval;
    }
    
    //垂直的点和水平的线
    for (int i = 0; i< vDesc.count ; i++)
    {
        startPoint = CGPointMake(hInterval * 2,y);
        endPoint = CGPointMake(hInterval * 2 + hInterval * hDesc.count,y);
        y -= newInterval;
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 0.5f);
    int x= hInterval;
    //绘制水平坐标轴和垂直的线
    for (int i = 0; i < hDesc.count ; i++)
    {
        //起始坐标和终点坐标
        startPoint = CGPointMake(hInterval * 1.4 + i * hInterval,maxHeight);
        endPoint = CGPointMake(hInterval * 1.4 + i * hInterval, y + vInterval / 2.f);
        //水平坐标的数据
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i * hInterval, maxHeight, hInterval, 30)];
        [label setCenter:CGPointMake(startPoint.x, maxHeight + vInterval / 2.f + 10)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor lightGrayColor]];
        label.numberOfLines = 1;
        [label setFont:[UIFont systemFontOfSize:11.f]];
        label.adjustsFontSizeToFitWidth = YES;
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        if(i > [hDesc count])
            NSLog(@"111");
        [label setText:[hDesc objectAtIndex:i]];
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        
        x += hInterval;
        CGContextStrokePath(context);
    }
    //滑内容的按钮
    CGContextSetLineDash(context,0, lengths,0);//注意2(count)的值等于lengths数组的长度
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1.5f);
    //绘图
    for (int i = 0; i < [array count]; i++)
    {
        if(i > [array count])
            NSLog(@"111");
        float aa = [[array objectAtIndex:i] floatValue];
        
        CGPoint goPoint = CGPointMake(hInterval * 1.4 + i * hInterval, maxHeight - (aa - starValue) * vInterval);
        
        if (i != 0)
        {
            CGContextAddLineToPoint(context, goPoint.x, goPoint.y);
        }
        else
        {
            CGContextMoveToPoint(context, goPoint.x, goPoint.y);
        }
        
        //添加触摸点
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        [button setFrame:CGRectMake(0, 0, 18, 18)];
        [button.layer setMasksToBounds:YES];
        button.layer.cornerRadius = button.frame.size.width / 2.f;
        [button setCenter:goPoint];
        [button setTag:i + 1];
        //点击事件
        [self addSubview:button];
    }
    CGContextStrokePath(context);
}

//设置数据
-(void)setDataArray:(NSMutableArray *)mutuArray
{
    self.array = mutuArray;
    [self setNeedsDisplay];
}

- (void)setPointClickedBlock:(void (^)(NSArray *index))block
{
    if (block != nil)
        self.clickedBlock = block;
}

//点击事件
#pragma mark - Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint thisPoint = [[touches anyObject] locationInView:self];
    
    
    
    //判断极限值
    if(thisPoint.y < maxHeight - (endValue - starValue) * vInterval)
        thisPoint.y = maxHeight - (endValue - starValue) * vInterval;
    //判断点击的是点上面的坐标
    BOOL isSelectedPoint = NO;
    NSLog(@"thisPoint.x = %f, thisPoint.y = %f", thisPoint.x, thisPoint.y);
    //判断位置
    for (int i = 0; i < [array count]; i++) {
        //点的判断
        if(thisPoint.x >= hInterval * 1.4 + i * hInterval - 17.f && thisPoint.x <= hInterval * 1.4 + i * hInterval + 10.f && thisPoint.y >= maxHeight - 15.f * vInterval && thisPoint.y <= (maxHeight + 10))
        {
            selectedButton = i + 1;
            isSelectedPoint = YES;
            if(i > [array count])
                NSLog(@"111");
            break;
        }
    }
    //不在点上
    if(!isSelectedPoint)
    {
        return;
    }
    else
    {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        for (UIButton *tmpButton in [self subviews]) {
            if(tmpButton.tag == selectedButton && selectedButton != 0)
            {
                //终点坐标
                float tmpFloat;
                if(thisPoint.y > maxHeight)
                    tmpFloat = maxHeight;
                else if (thisPoint.y < maxHeight - starValue * vInterval)
                    tmpFloat = maxHeight - starValue * vInterval;
                else
                    tmpFloat = thisPoint.y;
                [tmpButton removeFromSuperview];
                //判断选择的第几个点
                int tmpInt = (int)((maxHeight - tmpFloat) / vInterval) + starValue;
                //隐藏
                [_popView setHidden:NO];
                //设置标签的坐标
                CGRect viewFrame = CGRectZero;
                viewFrame.origin.x = hInterval * 1.4 + (selectedButton - 1) * hInterval;
                viewFrame.origin.y = maxHeight - (tmpInt - starValue) * vInterval;
                [_popView setCenter:CGPointMake(viewFrame.origin.x, viewFrame.origin.y - _popView.frame.size.height / 2.f - 9)];
                //设置显示的值
                [_disLabel setText:[NSString stringWithFormat:@"%d%@",tmpInt,@"°"]];
                //现在的点赋值
                selectedValue = tmpInt;
                if((selectedButton - 1) > [array count])
                    NSLog(@"111");
                [array replaceObjectAtIndex:(selectedButton - 1) withObject:[NSNumber numberWithInt:tmpInt]];
                
                [self setNeedsDisplay];
            }
        }
        [CATransaction commit];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint thisPoint = [[touches anyObject] locationInView:self];
    //判断极限值
    if(thisPoint.y < maxHeight - (endValue - starValue) * vInterval)
        thisPoint.y = maxHeight - (endValue - starValue) * vInterval;
    
    //后来的点
    float tmpFloat;
    if(thisPoint.y > maxHeight)
        tmpFloat = maxHeight;
    else if (thisPoint.y < maxHeight - starValue * vInterval)
        tmpFloat = maxHeight - starValue * vInterval;
    else
        tmpFloat = thisPoint.y;
    //设置标签的坐标
    [_popView setCenter:CGPointMake(_popView.center.x, tmpFloat - _popView.frame.size.height / 2.f - 9)];
    //隐藏
    [_popView setHidden:NO];
    //比较后来的点和原来的点的坐标
    if(tmpFloat == selectedValue)
        return;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    //判断位置
    for (UIButton *tmpButton in [self subviews]) {
        if(tmpButton.tag == selectedButton && selectedButton != 0)
        {
            [tmpButton removeFromSuperview];
            //判断选择的第几个点
            int tmpInt = (int)((maxHeight - tmpFloat) / vInterval) + starValue;
            //设置显示的值
            [_disLabel setText:[NSString stringWithFormat:@"%d%@",tmpInt, @"°"]];
            //现在的点赋值
            selectedValue = tmpInt;
            if((selectedButton - 1) > [array count])
                NSLog(@"111");
            [array replaceObjectAtIndex:(selectedButton - 1) withObject:[NSNumber numberWithInt:tmpInt]];
            
            [self setNeedsDisplay];
        }
    }
    [CATransaction commit];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint thisPoint = [[touches anyObject] locationInView:self];
    //判断极限值
    if(thisPoint.y < maxHeight - (endValue - starValue) * vInterval)
        thisPoint.y = maxHeight - (endValue - starValue) * vInterval;
    //设置
    if((selectedButton - 1) < [array count] && (selectedButton - 1) > 0)
    {
        //隐藏
        [_popView setHidden:NO];
        float tempVaule = [[array objectAtIndex:(selectedButton - 1)] floatValue];
        //设置标签的坐标
        CGRect viewFrame = CGRectZero;
        viewFrame.origin.x = hInterval * 1.4 + (selectedButton - 1) * hInterval;
        viewFrame.origin.y = maxHeight - (tempVaule - starValue) * vInterval;
        [_popView setCenter:CGPointMake(viewFrame.origin.x, viewFrame.origin.y - _popView.frame.size.height / 2.f - 9)];
    }
    
    //初始化
    selectedButton = 0;
    //回调函数
    self.clickedBlock(array);
}
@end

