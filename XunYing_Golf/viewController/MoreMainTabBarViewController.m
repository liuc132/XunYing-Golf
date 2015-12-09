//
//  MoreMainViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "MoreMainTabBarViewController.h"

@interface MoreMainTabBarViewController ()


@property (strong, nonatomic) IBOutlet UITabBar *moreMainTabBar;

@end


@implementation MoreMainTabBarViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"enter MoreMainTabBarViewController");
    self.selectedIndex = 1;
    
}
//
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    [self.tabBarController setSelectedIndex:1];
    NSLog(@"tab bar Selected Index:%lu",self.tabBarController.selectedIndex);
}


@end
