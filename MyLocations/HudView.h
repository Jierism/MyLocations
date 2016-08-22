//
//  HudView.h
//  MyLocations
//
//  Created by  Jierism on 16/8/11.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

@property(strong,nonatomic)NSString *text;

+(instancetype)hudInView:(UIView *)view animated:(BOOL)animated;


@end
