//
//  PlayProcessViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/23.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "PlayProcessViewController.h"
#import "XunYingPre.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"


@interface PlayProcessViewController ()<UIAlertViewDelegate>


@property (strong, nonatomic) DBCon *lcDbcon;
@property (strong, nonatomic) DataTable *groupInfo;
@property (strong, nonatomic) DataTable *cusGroInfEmp;
@property (strong, nonatomic) DataTable *holePlanInfo;
@property (strong, nonatomic) DataTable *holesInfo;

@property (strong, nonatomic) NSArray   *holePositionArray;
@property (nonatomic)         NSInteger theSelectNum;
@property (strong, nonatomic) NSArray   *holeStateArray;


@property (strong, nonatomic) IBOutlet UIScrollView *playProcessScrollView;

@property (strong, nonatomic) IBOutlet UILabel *displayHoleNumber;
@property (strong, nonatomic) IBOutlet UILabel *displayHoleSubName;
@property (strong, nonatomic) IBOutlet UILabel *holeGroup;
@property (strong, nonatomic) IBOutlet UILabel *golfCourse;
@property (strong, nonatomic) IBOutlet UILabel *currentHoleTime;
@property (strong, nonatomic) IBOutlet UILabel *holePosition;
@property (strong, nonatomic) IBOutlet UILabel *standardTime;

//
@property (strong, nonatomic) IBOutlet UIButton *hole1;
@property (strong, nonatomic) IBOutlet UIButton *hole2;
@property (strong, nonatomic) IBOutlet UIButton *hole3;
@property (strong, nonatomic) IBOutlet UIButton *hole4;
@property (strong, nonatomic) IBOutlet UIButton *hole5;
@property (strong, nonatomic) IBOutlet UIButton *hole6;
@property (strong, nonatomic) IBOutlet UIButton *hole7;
@property (strong, nonatomic) IBOutlet UIButton *hole8;
@property (strong, nonatomic) IBOutlet UIButton *hole9;
@property (strong, nonatomic) IBOutlet UIButton *hole10;
@property (strong, nonatomic) IBOutlet UIButton *hole11;
@property (strong, nonatomic) IBOutlet UIButton *hole12;
@property (strong, nonatomic) IBOutlet UIButton *hole13;
@property (strong, nonatomic) IBOutlet UIButton *hole14;
@property (strong, nonatomic) IBOutlet UIButton *hole15;
@property (strong, nonatomic) IBOutlet UIButton *hole16;
@property (strong, nonatomic) IBOutlet UIButton *hole17;
@property (strong, nonatomic) IBOutlet UIButton *hole18;


- (IBAction)eachHoleState:(UIButton *)sender;
- (IBAction)refreshCurrentState:(UIBarButtonItem *)sender;


@end


@implementation PlayProcessViewController

-(void)viewDidLoad
{
    //
    __weak typeof(self) weakSelf = self;
    //
    [super viewDidLoad];
    //setting scroll View
    self.playProcessScrollView.directionalLockEnabled = YES;
    self.playProcessScrollView.alwaysBounceVertical = YES;
    self.playProcessScrollView.scrollEnabled = YES;
    self.playProcessScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.playProcessScrollView.showsVerticalScrollIndicator = YES;
    self.playProcessScrollView.showsHorizontalScrollIndicator = NO;
    self.playProcessScrollView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    //alloc and init
    self.lcDbcon = [[DBCon alloc] init];
    self.groupInfo = [[DataTable alloc] init];
    self.cusGroInfEmp = [[DataTable alloc] init];
    self.holePlanInfo = [[DataTable alloc] init];
    self.holesInfo    = [[DataTable alloc] init];
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf GetPlayProcess];
        
    });
    //添加通知：当请求成功之后，进行页面数据的刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadRefreshSuccess:) name:@"refreshSuccess" object:nil];
    //
    self.holePositionArray = [[NSArray alloc] initWithObjects:@"发球台",@"球道",@"果岭", nil];
    self.holeStateArray    = [[NSArray alloc] initWithObjects:@"正常",@"被完成",@"被跳过",@"被挂起",@"非法跳过",@"补打",@"补打完成",@"被补打",@"被预定", nil];
    
    
}
#pragma -mark observer
- (void)hadRefreshSuccess:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    NSLog(@"info:%@",sender.userInfo);
    //
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
//    self.holesInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holeInf"];
    NSLog(@"groupInfo:%@",self.groupInfo.Rows);
    //将相应的数据显示出来
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        if ([weakSelf.groupInfo.Rows count]) {
            //显示球洞组
            weakSelf.holeGroup.text = self.groupInfo.Rows[0][@"hgcod"];
            
        }
        
    });
    //
    if ([sender.userInfo[@"hasRefreshed"] intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cusGroInfEmp = [weakSelf.lcDbcon ExecDataTable:@"select *from tbl_CusGroInf"];
                weakSelf.holePlanInfo = [weakSelf.lcDbcon ExecDataTable:@"select *from tbl_holePlanInfo"];
                //将相应的有用信息显示到当前界面中
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.cusGroInfEmp.Rows count] && [weakSelf.holePlanInfo.Rows count]) {
                        NSString *curHoleCode = weakSelf.cusGroInfEmp.Rows[0][@"nowholcod"];
                        NSArray *allgHolePlanArray = weakSelf.holePlanInfo.Rows;
                        for (NSDictionary *eachHolePlan in allgHolePlanArray) {
                            if ([eachHolePlan[@"holcod"] isEqualToString:curHoleCode]) {
                                //球洞号显示
                                weakSelf.displayHoleNumber.text = eachHolePlan[@"holnum"];
                                 //当前球洞的标准耗时,计算出结果来
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSInteger totalSeconds = [eachHolePlan[@"stadur"] integerValue];
                                    NSInteger hour = totalSeconds/3600;
                                    NSInteger min  = (totalSeconds%3600)/60;
                                    if (hour > 0) {
                                        weakSelf.standardTime.text  = [NSString stringWithFormat:@"%ld时%ld分",hour,min];
                                    }
                                    else
                                        weakSelf.standardTime.text  = [NSString stringWithFormat:@"%ld分",min];
                                });
                                break;
                            }
                        }
                        //显示当前球洞耗时
                        NSInteger curPlayTime = [weakSelf.cusGroInfEmp.Rows[0][@"pladur"] integerValue];
                        NSInteger hour  = curPlayTime/3600;
                        NSInteger min = (curPlayTime%3600)/60;
                        NSInteger second = curPlayTime%60;
                        if (hour > 0) {
                            weakSelf.currentHoleTime.text = [NSString stringWithFormat:@"%ld小时%ld分%ld秒",hour,min
                                                             ,second];
                        }
                        else if (min > 0) {
                            weakSelf.currentHoleTime.text = [NSString stringWithFormat:@"%ld分%ld秒",min,second];
                        }
                        else{
                            weakSelf.currentHoleTime.text = [NSString stringWithFormat:@"%ld秒",second];
                        }
                        //查询球洞别名并显示
                        NSString *_curHoleCode = weakSelf.cusGroInfEmp.Rows[0][@"nowholcod"];
                        NSArray *allHolesInfoArray = weakSelf.holesInfo.Rows;
                        for (NSDictionary *eachHole in allHolesInfoArray) {
                            if ([eachHole[@"holcod"] isEqualToString:_curHoleCode]) {
                                weakSelf.displayHoleSubName.text = eachHole[@"holnam"];
                                break;
                            }
                        }
                        //显示球洞位置@"发球台",@"球道",@"果岭"
                        NSString *curHolePosStr = [[NSString alloc] init];//当前所在球洞的位置
                        switch ([weakSelf.cusGroInfEmp.Rows[0][@"nowblocks"] intValue]) {
                                //发球台
                            case 1:
                                curHolePosStr = weakSelf.holePositionArray[0];
                                break;
                                //球道
                            case 2:
                                curHolePosStr = weakSelf.holePositionArray[1];
                                break;
                                //果岭
                            case 3:
                                curHolePosStr = weakSelf.holePositionArray[2];
                                break;
                            default:
                                break;
                        }
                        //
                        weakSelf.holePosition.text = curHolePosStr;
                        
                    }
                    
                });
            });
    }
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma -mark viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
//    __weak typeof(self) weakSelf = self;
    //read some data for request(check the database)
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
    self.holesInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holeInf"];
//    NSLog(@"groupInfo:%@",self.groupInfo.Rows);
//    //将相应的数据显示出来
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self.holesInfo.Rows count]) {
//            //显示球洞别名
//            weakSelf.displayHoleSubName.text = self.holesInfo.Rows[0][@"holnam"];
//            
//        }
//        //
//        if ([self.groupInfo.Rows count]) {
//            //显示球洞组
//            weakSelf.holeGroup.text = self.groupInfo.Rows[0][@"hgcod"];
//            
//        }
//        
//        
//    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"enter viewDidAppear");
    
    
}
#pragma -mark GetPlayProcess
- (void)GetPlayProcess
{
    __weak typeof(self) weakSelf = self;
    //construct request parameter
    if (![self.groupInfo.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取数据异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    NSMutableDictionary *refreshParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.groupInfo.Rows[0][@"grocod"],@"grocod", nil];
    //start request
    [HttpTools getHttp:GetPlayProcessURL forParams:refreshParam success:^(NSData *nsData){
        NSLog(@"success refresh");
        NSDictionary *latestDataDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        if ([latestDataDic[@"Code"] intValue] > 0) {
            //delete the old data
            [weakSelf.lcDbcon ExecNonQuery:@"delete from tbl_CusGroInf"];
            [weakSelf.lcDbcon ExecNonQuery:@"delete from tbl_holePlanInfo"];
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                //客户组对象
                NSMutableArray *cusGroInfPart = [[NSMutableArray alloc] initWithObjects:latestDataDic[@"Msg"][@"appGroupE"][@"grocod"],latestDataDic[@"Msg"][@"appGroupE"][@"grosta"],latestDataDic[@"Msg"][@"appGroupE"][@"nextgrodistime"],latestDataDic[@"Msg"][@"appGroupE"][@"nowblocks"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholcod"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholnum"],latestDataDic[@"Msg"][@"appGroupE"][@"pladur"],latestDataDic[@"Msg"][@"appGroupE"][@"stahol"],latestDataDic[@"Msg"][@"appGroupE"][@"statim"],latestDataDic[@"Msg"][@"appGroupE"][@"stddur"], nil];
                //tbl_CusGroInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text)
                [self.lcDbcon ExecNonQuery:@"insert into tbl_CusGroInf(grocod,grosta,nextgrodistime,nowblocks,nowholcod,nowholnum,pladur,stahol,statim,stddur) values(?,?,?,?,?,?,?,?,?,?)" forParameter:cusGroInfPart];
                //球洞规划组对象
                NSArray *allGroHoleList = latestDataDic[@"Msg"][@"groholelist"];
                for (NSDictionary *eachHoleInf in allGroHoleList) {
                    NSMutableArray *eachHoleInfParam = [[NSMutableArray alloc] initWithObjects:eachHoleInf[@"ghcod"],eachHoleInf[@"ghind"],eachHoleInf[@"ghsta"],eachHoleInf[@"grocod"],eachHoleInf[@"gronum"],eachHoleInf[@"holcod"],eachHoleInf[@"holnum"],eachHoleInf[@"pintim"],eachHoleInf[@"pladur"],eachHoleInf[@"poutim"],eachHoleInf[@"rintim"],eachHoleInf[@"routim"],eachHoleInf[@"stadur"], nil];
                    //tbl_holePlanInfo(ghcod text,ghind text,ghsta text,grocod text,gronum text,holcod text,holnum text,pintim text,pladur text,poutim text,rintim text,routim text,stadur text)
                    [weakSelf.lcDbcon ExecNonQuery:@"insert into tbl_holePlanInfo(ghcod,ghind,ghsta,grocod,gronum,holcod,holnum,pintim,pladur,poutim,rintim,routim,stadur) values(?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInfParam];
                }
                //通知数据已经更新了
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSuccess" object:nil userInfo:@{@"hasRefreshed":@"1"}];
                
            });
        }
        
    }failure:^(NSError *err){
        NSLog(@"refresh failled and err:%@",err);
        
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    __weak typeof(self) weakSelf = self;
    
    if (alertView.tag == 1) {
        //
        switch (buttonIndex) {
            case 0:
                
                break;
                //
            case 1:
                if (![self.holePlanInfo.Rows count]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                    return;
                }
                //组建参数
                NSMutableDictionary *makeHoleCompleteParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.groupInfo.Rows[0][@"grocod"],@"grocod",self.holePlanInfo.Rows[self.theSelectNum - 1][@"holcod"],@"holecode", nil];
                
                //发送更改请求
                [HttpTools getHttp:MakeHoleCompleteStateURL forParams:makeHoleCompleteParam success:^(NSData *nsData){
                    NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
                    NSLog(@"recDic Msg:%@",recDic[@"Msg"]);
                    //
                    if ([recDic[@"Code"] intValue] > 0) {
                        NSLog(@"正常");
                        
                        
                    }
                    
                    else if ([recDic[@"Code"] intValue] == -3) {
                        NSLog(@"发生错误");
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该球洞已经被完成了，不能进行此操作" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [alert show];
                    }
                    
                    
                    
                }failure:^(NSError *err){
                    NSLog(@"request failed");
                }];
                
                
                break;
        }
        
    }
    
}


- (IBAction)eachHoleState:(UIButton *)sender {
    NSLog(@"enter eachHoleState,button.Tag:%ld;button.title:%@",(long)sender.tag,sender.titleLabel.text);
    //
    self.theSelectNum = sender.tag + 1;
    //查询数据库
    self.holePlanInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holePlanInfo"];
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
    //
    if (![self.holePlanInfo.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    
    //
    NSString *curSelectHoleName = [NSString stringWithFormat:@"%ld号球洞",sender.tag + 1];//当前所在球洞提示
    //
    NSInteger holeNum = [self.holePlanInfo.Rows[sender.tag][@"ghsta"] integerValue];
    NSString  *planInTime = self.holePlanInfo.Rows[sender.tag][@"pintim"];
    planInTime = [planInTime substringFromIndex:11];
    NSInteger totalSeconds = [self.holePlanInfo.Rows[sender.tag][@"stadur"] integerValue];
    NSInteger hour = totalSeconds/3600;
    NSInteger min  = (totalSeconds%3600)/60;
    NSInteger second = totalSeconds%60;
    NSString  *standardTime = [[NSString alloc] init];
    if (hour > 0) {
        standardTime = [NSString stringWithFormat:@"%ld时%ld分%ld秒",(long)hour,(long)min,(long)second];
    }
    else if(min > 0)
    {
        standardTime = [NSString stringWithFormat:@"%ld分%ld秒",(long)min,(long)second];
    }
    else
    {
        standardTime = [NSString stringWithFormat:@"%ld秒",(long)second];
    }
    NSString *planOutTime = self.holePlanInfo.Rows[sender.tag][@"poutim"];
    planOutTime = [NSString stringWithFormat:@"%@",[planOutTime substringFromIndex:11]];
    
    NSString *subMsg = [NSString stringWithFormat:@" 打球状态   %@ \n计划进入时间   %@\n   标准耗时   %@\n计划离开时间   %@",self.holeStateArray[holeNum],planInTime,standardTime,planOutTime];
    //
    UIAlertView *changeHoleStateAlert = [[UIAlertView alloc] initWithTitle:curSelectHoleName message:subMsg delegate:self cancelButtonTitle:@" 取 消 " otherButtonTitles:@"改为被完成", nil];
    changeHoleStateAlert.tag = 1;//到时候改成1
    [changeHoleStateAlert show];
}

- (IBAction)refreshCurrentState:(UIBarButtonItem *)sender {
    NSLog(@"refresh Current");
    [self GetPlayProcess];
    
}
@end
