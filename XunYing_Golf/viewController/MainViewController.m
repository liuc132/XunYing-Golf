//
//  MainViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/7.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "MainViewController.h"
#import "XunYingPre.h"
#import "HttpTools.h"
#import "UIColor+UICon.h"

@interface MainViewController ()<UIActionSheetDelegate,UITabBarControllerDelegate>

@property(strong, nonatomic)UIBarButtonItem *rightButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBarBack.png"] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor HexString:@"454545"];
    
}
//#pragma -mark navBack
//-(void)navBack
//{
//    NSLog(@"enter navBack");
//    [self.navigationController popViewControllerAnimated:YES];
//}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //
    self.tabBarController.selectedIndex = 2;
    
//    NSThread *heartBeatThread = [[NSThread alloc] initWithTarget:self selector:@selector(timelySend) object:nil];
//    [heartBeatThread start];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}
#pragma -mark viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
}

//
//-(void)taskChoose
//{
//    NSLog(@"taskChoose");
//    UIActionSheet *taskSheetSelect = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"补洞" otherButtonTitles:@"跳洞", nil];
//    [taskSheetSelect showInView:self.view];
//    
//}
//
//
//-(BOOL)shouldAutorotate{
//    return YES;
//}
//
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}
////
//-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
//{
//    NSLog(@"tag:%ld",(long)item.tag);
//    switch (item.tag) {
//        case 0:
//            
//            
//            break;
//            
//        case 1:
////            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"事件选择" style:UIBarButtonItemStylePlain target:self action:@selector(taskChoose)];
//            
//            break;
//            
//        case 2:
//            
//            
//            break;
//            //
//        case 3:
//            
//            
//            break;
//            //
//        case 4:
//            
//            
//            break;
//            //
//        case 5:
//            NSLog(@"more");
//            //[self performSegueWithIdentifier:@"showMoreInterfaces" sender:nil];
//            
//            break;
//        default:
//            break;
//    }
//    
//}
//
////
//-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    NSLog(@"Current controller is:%lu",(unsigned long)tabBarController.selectedIndex);
//    
//    
//}
//
//
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
