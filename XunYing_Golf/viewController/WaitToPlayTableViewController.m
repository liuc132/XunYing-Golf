//
//  WaitToPlayTableViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "WaitToPlayTableViewController.h"
//#import "CreateGroupViewController.h"
#import "UIColor+UICon.h"
#import "NSString+FontAwesome.h"
#include "MainViewController.h"
#import "XunYingPre.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"
#import "LogInViewController.h"
#import "AppDelegate.h"
#import "HeartBeatAndDetectState.h"

extern unsigned char ucCusCounts;
extern unsigned char ucHolePosition;
extern BOOL          allowDownCourt;



@interface WaitToPlayTableViewController ()




@property (strong, nonatomic) NSMutableArray *customerCount;
@property (strong, nonatomic) NSMutableArray *caddyCount;
@property (strong, nonatomic) NSMutableArray *carCount;
@property (strong, nonatomic) UILabel *cusName;
@property (strong, nonatomic) UILabel *cusNumber;
@property (strong, nonatomic) UILabel *cusSex;
@property (strong, nonatomic) UILabel *cusLevel;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) DBCon *localDBcon;
@property (strong, nonatomic) DataTable *cusCardNumTable;
@property (strong, nonatomic) DataTable *caddyTable;
@property (strong, nonatomic) DataTable *groupTable;
@property (nonatomic) NSInteger cusCounts;  //选取的客户个数
@property (nonatomic) NSInteger holeName;   //选取的球洞类型
//
@property (strong, nonatomic) NSArray   *cusCardNumArray;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;


@property (strong, nonatomic) IBOutlet UITableView *waitInformationTable;



- (IBAction)cancleDownGround:(UIBarButtonItem *)sender;
- (IBAction)backToCreateInf:(UIBarButtonItem *)sender;


@end

@implementation WaitToPlayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.waitInformationTable.dataSource = self;
    self.waitInformationTable.delegate   = self;
    
    //init and alloc dbcon and datatable
    self.localDBcon = [[DBCon alloc] init];
    self.cusCardNumTable  = [[DataTable alloc] init];
    self.caddyTable = [[DataTable alloc] init];
    self.groupTable = [[DataTable alloc] init];
    //查询球童信息
    self.caddyTable = [self.localDBcon ExecDataTable:@"select *from tbl_logPerson"];
    //
    if (self.QRCodeEnable) {
        self.cusCardNumArray = self.cusCardArray;
    }
    else
    {
        self.cusCardNumTable = [self.localDBcon ExecDataTable:@"select *from tbl_CustomerNumbers"];
        //
        self.cusCardNumArray = [[NSArray alloc] initWithObjects:self.cusCardNumTable.Rows[0][@"first"],self.cusCardNumTable.Rows[0][@"second"],self.cusCardNumTable.Rows[0][@"third"],self.cusCardNumTable.Rows[0][@"fourth"], nil];
    }
    self.groupTable = [self.localDBcon ExecDataTable:@"select *from tbl_groupInf"];
    
    //
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2-100, ScreenHeight/2 - 130, 200, 200)];
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.3];
    //self.activityIndicatorView.alpha = 0.2;
    self.activityIndicatorView.hidden = YES;
    self.activityIndicatorView.layer.cornerRadius = 20.0f;
    //from heart beat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectTheThing:) name:@"readyDown" object:nil];
    //from QRCodeReaderView
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(QRCodeResult:) name:@"QRCodeResult" object:nil];
    
}

#pragma -mark detectTheThing
-(void)detectTheThing:(NSNotification *)sender
{
    NSLog(@"enter detectTheThing");
    //通过通知来接收信息，并进行相应的跳转
    if ([sender.userInfo[@"readyDown"] isEqualToString:@"1"]) {
        //移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //实现页面跳转
        [self performSegueWithIdentifier:@"toMainControlInterface" sender:nil];
    }
    
}

#pragma -mark navBack
-(void)navBack
{
    //NSLog(@"enter navBack");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    NSInteger eachSectionRow;
    
    switch (section) {
        case 0:
            eachSectionRow = self.QRCodeEnable?[self.cusCardNumArray count]:self.customerCounts + 1;
            break;
            
        case 1:
        case 2:
        case 3:
            eachSectionRow = 1;
            break;
        default:
            break;
    }
    
    return eachSectionRow;
}
#pragma -mark tableView:willDisplayCell:forRowAtIndexPath
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
    if(indexPath.section == 0)
    {
        self.cusName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 45, 21)];
        //NSLog(@"index.row:%ld",indexPath.row);
        //后期如果有客户名称则替换成客户登记的实际名称
        self.cusName.text = [NSString stringWithFormat:@"客户%ld",(long)indexPath.row];
        self.cusNumber = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 42, 21)];
        //实际的消费卡号
        NSString *cusNum = [[NSString alloc] init];
        switch (indexPath.row) {
            case 0:
//                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumTable.Rows[0][@"first"]];
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[0]];
                break;
            case 1:
//                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumTable.Rows[0][@"second"]];
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[1]];
                break;
            case 2:
//                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumTable.Rows[0][@"third"]];
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[2]];
                break;
            case 3:
//                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumTable.Rows[0][@"fourth"]];
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[3]];
                break;
                
            default:
                break;
        }
        
        self.cusNumber.text = cusNum;
        self.cusSex = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 120, 10, 42, 21)];
        //实际的客户性别
        self.cusSex.text = @"男";
        self.cusLevel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 48, 10, 42, 21)];
        //是否是会员
        self.cusLevel.text = @"会员";
    }
    //
//    NSString *holeNameString = [[NSString alloc] init];
//    switch (ucHolePosition) {
//        case 0:
//            holeNameString = @"上九洞";
//            break;
//        case 1:
//            holeNameString = @"下九洞";
//            break;
//        case 2:
//            holeNameString = @"十八洞";
//            break;
//            
//        default:
//            break;
//    }
    
    //
    UILabel *holeName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 60, 21)];
    holeName.text = self.holeType;//holeNameString;
    //
    UILabel *caddy = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 100, 21)];
    if ([self.caddyTable.Rows count]) {
        caddy.text = [NSString stringWithFormat:@" %@ %@",self.caddyTable.Rows[0][@"number"],self.caddyTable.Rows[0][@"name"]];
    }
    
    //
    UILabel *carInf = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 21)];
    carInf.text = [NSString stringWithFormat:@" %@ %@",@"095",@"2座"];
    
    
    switch (indexPath.section) {
        //客户组信息列表
        case 0:
            switch (indexPath.row) {
                //第一个客户信息显示
                case 0:
                    [cell addSubview:self.cusName];
                    [cell addSubview:self.cusNumber];
                    [cell addSubview:self.cusSex];
                    [cell addSubview:self.cusLevel];
                    break;
                //第二个客户信息显示
                case 1:
                    [cell addSubview:self.cusName];
                    [cell addSubview:self.cusNumber];
                    [cell addSubview:self.cusSex];
                    [cell addSubview:self.cusLevel];
                    break;
                //第三个客户信息显示
                case 2:
                    [cell addSubview:self.cusName];
                    [cell addSubview:self.cusNumber];
                    [cell addSubview:self.cusSex];
                    [cell addSubview:self.cusLevel];
                    break;
                //第四个客户信息显示
                case 3:
                    [cell addSubview:self.cusName];
                    [cell addSubview:self.cusNumber];
                    [cell addSubview:self.cusSex];
                    [cell addSubview:self.cusLevel];
                    break;

                default:
                    break;
            }
            break;
        //球洞信息
        case 1:
            [cell addSubview:holeName];
            break;
        //球童信息
        case 2:
            [cell addSubview:caddy];
            break;
        //球车
        case 3:
            [cell addSubview:carInf];
            break;
        default:
            break;
    }
    //
    [self.activityIndicatorView startAnimating];
    self.activityIndicatorView.hidden = NO;
}

#pragma --mark heightForHeaderInSection
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
#pragma -mark  titleForHeaderInSection
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = [[NSString alloc]init];
    switch (section) {
        case 0:
            headerTitle = @"  客户";
            break;
            
        case 1:
            headerTitle = @"  球洞";
            break;
            
        case 2:
            headerTitle = @"  球童";
            break;
            
        case 3:
            headerTitle = @"  球车";
            break;
        default:
            break;
    }
    
    return headerTitle;
}
#pragma -mark viewDidDisappear
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

#pragma --mark viewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    if ([self.waitInformationTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.waitInformationTable setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.waitInformationTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.waitInformationTable setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.waitInformationTable dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    [self.view bringSubviewToFront:self.activityIndicatorView];
    return cell;
}
#pragma -mark
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"currentIndexPath.row:%ld;and section:%ld",(long)indexPath.row,(long)indexPath.section);
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancleDownGround:(UIBarButtonItem *)sender {
    NSLog(@"right cancle button");
    //
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"组参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    if(![self.groupTable.Rows count])
    {
        [alert show];
        return;
    }
    NSMutableDictionary *cancleWaiting = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.groupTable.Rows[0][@"grocod"],@"grocod", nil];
    
    //向服务器发送取消下场申请
    [HttpTools getHttp:CancleWaitingGroupURL forParams:cancleWaiting success:^(NSData *nsData){
        NSLog(@"cancle Waiting down group success");
        [self.timer invalidate];
        //
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"recDic:%@ and Msg:%@ Code:%@",recDic,recDic[@"Msg"],recDic[@"Code"]);
        if ([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]]) {
            NSLog(@"delete wait group fail");
        }
        else
            [self dismissViewControllerAnimated:YES completion:nil];
        
    }failure:^(NSError *err){
        NSLog(@"cancle waiting down group fail");
        
        
        
    }];
    
    
    
}

- (IBAction)backToCreateInf:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
