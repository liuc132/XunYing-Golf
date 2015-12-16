//
//  CurTaskCenterTableViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "CurTaskCenterTableViewController.h"
#import "XunYingPre.h"
#import "KxMenu.h"
#import "HttpTools.h"

@interface CurTaskCenterTableViewController ()<UIGestureRecognizerDelegate>


@property (strong, nonatomic) IBOutlet UIView *displayNoTask;



- (IBAction)selectTask:(UIBarButtonItem *)sender;


@end

@implementation CurTaskCenterTableViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //
//    [self displayNoTaskView];
    
    
}

#pragma -mark displayNoTaskView
-(void)displayNoTaskView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.navigationController.navigationBar.frame.size.height
    self.displayNoTask.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:self.displayNoTask];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listAllTask" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"curTime:%@",self.leaveTime);
    //[self.displayNoTask removeFromSuperview];//该语句可以实现将该uiview给移除掉
    
}


- (IBAction)selectTask:(UIBarButtonItem *)sender {
    //construct Array
    NSArray *menuItems =
    @[[KxMenuItem menuItem:@"换球童" image:[UIImage imageNamed:@"changeCaddy.png"] target:self action:@selector(changeCaddy)],
      [KxMenuItem menuItem:@"换球车" image:[UIImage imageNamed:@"changeCart.png"] target:self action:@selector(changeCart)],
      [KxMenuItem menuItem:@"跳洞" image:[UIImage imageNamed:@"jumpHole.png"] target:self action:@selector(JumpToHoles)],
      [KxMenuItem menuItem:@"补洞" image:[UIImage imageNamed:@"mendHole.png"] target:self action:@selector(MendHoles)],
      [KxMenuItem menuItem:@"离场休息" image:[UIImage imageNamed:@"leaveToRest.png"] target:self action:@selector(leaveToRest)]];
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(ScreenWidth-47, self.navigationController.navigationBar.frame.size.height, 30, 30)
                 menuItems:menuItems];
    
    
}
#pragma -mark JumpHoles
-(void)JumpToHoles
{
    NSLog(@"跳洞");
    //执行页面跳转代码
    [self performSegueWithIdentifier:@"ToJumpHole" sender:nil];
}

#pragma -mark MendHoles
-(void)MendHoles
{
    NSLog(@"补洞");
    
    //执行跳转程序
    [self performSegueWithIdentifier:@"toMendHole" sender:nil];
}
#pragma -mark changeCaddy
-(void)changeCaddy
{
    NSLog(@"change Caddy");
    //执行跳转程序
    [self performSegueWithIdentifier:@"toChangeCaddy" sender:nil];
}
#pragma -mark changeCart
-(void)changeCart
{
    NSLog(@"change Cart");
    [self performSegueWithIdentifier:@"toChangeCart" sender:nil];
}
#pragma -mark leaveToRest
-(void)leaveToRest
{
    NSLog(@"leave to rest");
    [self performSegueWithIdentifier:@"toLeaveToRest" sender:nil];                                                                                                                                                                                                                                                                                                   
}


@end
