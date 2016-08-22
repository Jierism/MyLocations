//
//  MyTabBarController.m
//  MyLocations
//
//  Created by  Jierism on 16/8/16.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import "MyTabBarController.h"

@implementation MyTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.tintColor=[UIColor yellowColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}
@end
