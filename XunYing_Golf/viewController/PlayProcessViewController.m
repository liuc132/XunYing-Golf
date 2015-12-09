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


@interface PlayProcessViewController ()


@property (strong, nonatomic) DBCon *lcDbcon;
@property (strong, nonatomic) DataTable *groupInfo;
@property (strong, nonatomic) DataTable *cusGroInfEmp;
@property (strong, nonatomic) DataTable *holePlanInfo;
@property (strong, nonatomic) DataTable *holesInfo;


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
    __weak typeof(self) weakSelf = self;
    //read some data for request(check the database)
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
    self.holesInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holeInf"];
//    NSLog(@"groupInfo:%@",self.groupInfo.Rows);
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.cusGroInfEmp = [weakSelf.lcDbcon ExecDataTable:@"select *from tbl_CusGroInf"];
        weakSelf.holePlanInfo = [weakSelf.lcDbcon ExecDataTable:@"select *from tbl_holePlanInfo"];
        //将相应的有用信息显示到当前界面中
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.cusGroInfEmp.Rows count] && [weakSelf.holePlanInfo.Rows count]) {
                NSString *curHoleCode = weakSelf.cusGroInfEmp.Rows[0][@"grocod"];
                NSArray *allgHolePlanArray = weakSelf.holePlanInfo.Rows;
                for (NSDictionary *eachHolePlan in allgHolePlanArray) {
                    if ([eachHolePlan[@"grocod"] isEqualToString:curHoleCode]) {
                        weakSelf.displayHoleNumber.text = eachHolePlan[@"holnum"];
                        
                        
                    }
                }
                
            }
            
            weakSelf.displayHoleNumber.text = [NSString stringWithFormat:@"%@",weakSelf.cusGroInfEmp.Rows[0][@""]];
//            weakSelf.displayHoleSubName.text = [
        });
    });
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
//        NSLog(@"refreshData:%@",latestDataDic[@"Msg"]);
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
                NSMutableArray *eachHoleInfParam = [[NSMutableArray alloc] initWithObjects:eachHoleInf[@"ghcod"],eachHoleInf[@"ghind"],eachHoleInf[@"ghsta"],eachHoleInf[@"grocod"],eachHoleInf[@"gronum"],eachHoleInf[@"holcod"],eachHoleInf[@"holnum"],eachHoleInf[@"pintim"],eachHoleInf[@"pladur"],eachHoleInf[@"poutim"],eachHoleInf[@"rintim"],eachHoleInf[@"routim"],eachHoleInf[@"stadui"], nil];
                //tbl_holePlanInfo(ghcod text,ghind text,ghsta text,grocod text,gronum text,holcod text,holnum text,pintim text,pladur text,poutim text,rintim text,routim text,stadur text)
                [weakSelf.lcDbcon ExecNonQuery:@"insert into tbl_holePlanInfo(ghcod,ghind,ghsta,grocod,gronum,holcod,holnum,pintim,pladur,poutim,rintim,routim,stadur) values(?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInfParam];
            }
            
        });
        
    }failure:^(NSError *err){
        NSLog(@"refresh failled and err:%@",err);
        
        
    }];
    
}




- (IBAction)eachHoleState:(UIButton *)sender {
    NSLog(@"enter eachHoleState,button.Tag:%ld;button.title:%@",(long)sender.tag,sender.titleLabel.text);
    
}

- (IBAction)refreshCurrentState:(UIBarButtonItem *)sender {
    NSLog(@"refresh Current");
    [self GetPlayProcess];
    
}
@end
