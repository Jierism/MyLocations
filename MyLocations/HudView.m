//
//  HudView.m
//  MyLocations
//
//  Created by  Jierism on 16/8/11.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import "HudView.h"

@implementation HudView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated
{
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    
    // 将hudView添加到view视图上
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;
    
    [hudView showAnimated:animated];
    return hudView;
}

// 绘制hudView
- (void)drawRect:(CGRect)rect
{
    // 定义两个常量，绘制圆角矩形
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    // 绘制矩形的位置
    CGRect boxRect = CGRectMake(round(self.bounds.size.width - boxWidth)/2.0f,
                                round(self.bounds.size.height - boxHeight)/2.0f,
                                boxWidth,
                                boxHeight);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.3f alpha:0.8f]setFill];
    [roundedRect fill];
    
    // 在矩形里绘制图片
    UIImage *image = [UIImage imageNamed:@"Checkmark"];

    CGPoint imagePoint = CGPointMake(self.center.x - roundf(image.size.width/2.0f),
                                     self.center.y - roundf(image.size.height/2.0f) - boxHeight/8.0f);
    [image drawAtPoint:imagePoint];
    
    // 在矩形里添加文字
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]
                                 };
    CGSize texSize = [self.text sizeWithAttributes:attributes];
    
    CGPoint textPoint = CGPointMake(self.center.x - roundf(texSize.width/2.0f),
                                    self.center.y - roundf(texSize.height/2.0f) + boxHeight/4.0f);
    [self.text drawAtPoint:textPoint withAttributes:attributes];
    
}

// hud动画效果
- (void)showAnimated:(BOOL)animated
{
    if (animated) {
        // alpha（透明度）为0，设置为透明
        self.alpha= 0.0f;
        // 视图初始状态是拉伸状态，1.3倍的大小
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView animateWithDuration:0.3 animations:^{
            // 设置为可见
            self.alpha = 1.0f;
            // 由1.3倍大小回复正常大小
            self.transform = CGAffineTransformIdentity;
        }];
    }
}
@end
