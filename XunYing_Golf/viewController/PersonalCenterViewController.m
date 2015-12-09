//
//  PersonalCenterViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "XunYingPre.h"
#import "UIColor+UICon.h"
#import "LogInViewController.h"
#import "HttpTools.h"
#import "DataTable.h"
#import "DBCon.h"


@interface PersonalCenterViewController ()

@property (strong, nonatomic) DBCon *_dbCon;
@property (strong, nonatomic) DataTable *userInf;
@property (strong, nonatomic) NSMutableDictionary *logOutDicParam;

- (IBAction)logOutHandle:(UIBarButtonItem *)sender;

@end

@implementation PersonalCenterViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    NSLog(@"enter personalCenter");
    
    self.tableView.tableHeaderView.backgroundColor = [UIColor HexString:@"eeeeee"];
    //alloc and init dbCon and Userinf
    self._dbCon = [[DBCon alloc] init];
    self.userInf = [[DataTable alloc] init];
    //查询登录人参数
    self.userInf = [self._dbCon ExecDataTable:@"select *from tbl_logPerson"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma -mark numberOfSectionsInTableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma -mark numberOfRowsInSection
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setTableFooterView:[[UIView alloc]init]];
    //
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    //
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"编号";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.userInf.Rows[0][@"number"]];//@"095";
            
            
            
            break;
        case 1:
            cell.textLabel.text = @"姓名";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.userInf.Rows[0][@"name"]];//@"高超";
            
            break;
        case 2:
            cell.textLabel.text = @"性别";
            cell.detailTextLabel.text = self.userInf.Rows[0][@"sex"]?@"男":@"女";
            
            break;
        case 3:
            cell.textLabel.text = @"岗位";
            cell.detailTextLabel.text = [self.userInf.Rows[0][@"job"] isEqualToString:@"4"]?@"球童":@"巡场";
            
            
            break;
        case 4:
            cell.textLabel.text = @"当前平板";
            cell.detailTextLabel.text = MIDCODE;
            
            break;
        case 5:
            cell.textLabel.text = @"心跳间隔时间";
            cell.detailTextLabel.text = @"10秒";
            
            break;
        default:
            break;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

#pragma --mark viewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonaCenter" forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    return cell;
}




- (IBAction)logOutHandle:(UIBarButtonItem *)sender {
    NSLog(@"enter logOutHandle");
    //[[NSMutableDictionary alloc] initWithObjectsAndKeys:TESTMIDCODE,@"mid",self.account.text,@"username",self.password.text,@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil]
    
    self.logOutDicParam = [[NSMutableDictionary alloc]initWithObjectsAndKeys:MIDCODE,@"mid",self.userInf.Rows[0][@"user"],@"username",self.userInf.Rows[0][@"password"],@"pwd",@"0",@"panmull", nil];
    //request
    [HttpTools getHttp:LogOutURL forParams:self.logOutDicParam success:^(NSData *nsData){
        NSLog(@"request success");
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"code:%@ msg:%@",recDic[@"Code"],recDic[@"Msg"]);
        
        
    }failure:^(NSError *err){
        NSLog(@"request failled");
        
        
    }];
    
    
    [self performSegueWithIdentifier:@"backToLogInterface" sender:nil];
    
}
@end
