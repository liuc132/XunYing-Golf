//
//  MendHoleViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "MendHoleViewController.h"
#import "HttpTools.h"
#import "DataTable.h"
#import "DBCon.h"
#import "XunYingPre.h"
#import "TaskDetailViewController.h"
#import "UIColor+UICon.h"

#define NotNeedMendColor    @"cacaca"//gray
#define NeedMendColor       @"f74c30"//red

@interface MendHoleViewController ()


@property (strong, nonatomic) IBOutlet UIScrollView *mendHoleScrollView;

@property (strong, nonatomic) IBOutlet UILabel *requestMendUser;
@property (strong, nonatomic) IBOutlet UILabel *hole1;
@property (strong, nonatomic) IBOutlet UILabel *hole2;
@property (strong, nonatomic) IBOutlet UILabel *hole3;
@property (strong, nonatomic) IBOutlet UILabel *hole4;
@property (strong, nonatomic) IBOutlet UILabel *hole5;
@property (strong, nonatomic) IBOutlet UILabel *hole6;
@property (strong, nonatomic) IBOutlet UILabel *hole7;
@property (strong, nonatomic) IBOutlet UILabel *hole8;
@property (strong, nonatomic) IBOutlet UILabel *hole9;
@property (strong, nonatomic) IBOutlet UILabel *hole10;
@property (strong, nonatomic) IBOutlet UILabel *hole11;
@property (strong, nonatomic) IBOutlet UILabel *hole12;
@property (strong, nonatomic) IBOutlet UILabel *hole13;
@property (strong, nonatomic) IBOutlet UILabel *hole14;
@property (strong, nonatomic) IBOutlet UILabel *hole15;
@property (strong, nonatomic) IBOutlet UILabel *hole16;
@property (strong, nonatomic) IBOutlet UILabel *hole17;
@property (strong, nonatomic) IBOutlet UILabel *hole18;

- (IBAction)requestMendHole:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mendHoleNavBack;
- (IBAction)mendHoleNavBack:(UIBarButtonItem *)sender;



@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *holesInf;
@property (strong, nonatomic) DataTable *mendHoleResult;
@property (strong, nonatomic) DBCon     *lcDBCon;
@property (strong, nonatomic) NSMutableArray *needMendHoles;
@property (strong, nonatomic) NSDictionary *eventInfoDic;
@property (strong, nonatomic) NSMutableArray   *needMendHoleInfoArray;

@end

@implementation MendHoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init
    self.lcDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.holesInf  = [[DataTable alloc] init];
    self.mendHoleResult = [[DataTable alloc] init];
    
    //在本地数据库中查询数据
    self.logPerson = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.holesInf  = [self.lcDBCon ExecDataTable:@"select *from tbl_holeInf"];
    //测试用，初始化数据
    self.needMendHoles = [[NSMutableArray alloc] init];
    //
    self.mendHoleScrollView.scrollEnabled = YES;
    self.mendHoleScrollView.directionalLockEnabled = YES;
    self.mendHoleScrollView.alwaysBounceVertical = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"mendHole" object:nil];
    //将所有球洞状态切换成未选
    [self initAllHoleColor];
}

- (void)initAllHoleColor
{
    self.hole1.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole2.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole3.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole4.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole5.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole6.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole7.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole8.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole9.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole10.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole11.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole12.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole13.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole14.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole15.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole16.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole17.backgroundColor = [UIColor HexString:NotNeedMendColor];
    self.hole18.backgroundColor = [UIColor HexString:NotNeedMendColor];
}

- (void)getEventFromHeart:(NSNotification *)sender
{
    self.eventInfoDic = sender.userInfo;
    NSLog(@"ChangeCart info:%@ and eventInfoDic:%@",sender.userInfo,self.eventInfoDic);
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    __weak typeof(self) weakSelf = self;
    
    if ([self.logPerson.Rows count]) {
        self.requestMendUser.text = [NSString stringWithFormat:@"%@ %@",self.logPerson.Rows[0][@"number"],self.logPerson.Rows[0][@"name"]];
    }
    //清除掉所有的数据
    self.needMendHoleInfoArray = [[NSMutableArray alloc] init];
    //
    NSMutableDictionary *getNeedMendHoleParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid", nil];
    //在此进行读取当前的需要补打的球洞的信息
    [HttpTools getHttp:GetNeedMendHoleURL forParams:getNeedMendHoleParam success:^(NSData *nsData){
        NSDictionary *needMendHoleDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"needMend:%@",needMendHoleDic);
        //
        if ([needMendHoleDic[@"Code"] intValue] > 0) {
            NSArray *allNeedMend = needMendHoleDic[@"Msg"];
            for (NSDictionary *eachNeedMendInfo in allNeedMend) {
                NSMutableDictionary *getNeedInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:eachNeedMendInfo[@"holcod"],@"holcod",eachNeedMendInfo[@"holnum"],@"holnum", nil];
                [weakSelf.needMendHoleInfoArray addObject:getNeedInfo];
            }
            //调用颜色显示方法来根据相应的各个球洞的状态显示出来
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshHoleStateDis];
            });
            
        }
        else if ([needMendHoleDic[@"Code"] intValue] == -5)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有需要补打的球洞" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            //同时执行跳转程序
            [weakSelf performSegueWithIdentifier:@"toTaskDetail" sender:nil];
        }
        
        
    }failure:^(NSError *err){
        NSLog(@"getMendHole Failed");
        
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshHoleStateDis
{
    for (NSDictionary *eachNeedMend in self.needMendHoleInfoArray) {
        //需要补打的球洞添加
        [self.needMendHoles addObject:eachNeedMend[@"holcod"]];
        //切换显示颜色
        switch ([eachNeedMend[@"holnum"] intValue]) {
            case 1:
                self.hole1.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 2:
                self.hole2.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 3:
                self.hole3.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 4:
                self.hole4.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 5:
                self.hole5.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 6:
                self.hole6.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 7:
                self.hole7.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 8:
                self.hole8.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 9:
                self.hole9.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 10:
                self.hole10.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 11:
                self.hole11.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 12:
                self.hole12.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 13:
                self.hole13.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 14:
                self.hole14.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 15:
                self.hole15.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 16:
                self.hole16.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 17:
                self.hole17.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            case 18:
                self.hole18.backgroundColor = [UIColor HexString:NeedMendColor];
                break;
            default:
                break;
        }
    }
}

- (IBAction)requestMendHole:(UIButton *)sender {
    NSLog(@"requestMendHole");
    //通过代理，读取到总共跳过了哪些球洞，NSMutableArray类型的数据来存储数据
    NSString *mendHoles = [[NSString alloc] init];
//    NSMutableArray *theseHoles = [[NSMutableArray alloc] init];
    if([self.needMendHoles count] > 1)
    {
        //先添加第一个
        mendHoles = [NSString stringWithFormat:@"%@",self.needMendHoles[0]];
        //将剩余的添加进来
        for (unsigned char i = 1; i < [self.needMendHoles count]; i++) {
            mendHoles = [mendHoles stringByAppendingString:[NSString stringWithFormat:@",%@",self.needMendHoles[i]]];
        }
        
    }
    else
    {
        mendHoles = [NSString stringWithFormat:@"%@",self.needMendHoles[0]];//self.holesInf.Rows[[self.needMendHoles.firstObject intValue]][@"holnum"];
    }
    NSLog(@"mendHoles:%@",mendHoles);
    //组建补洞参数
    NSMutableDictionary *mendHoleParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.logPerson.Rows[0][@"code"],@"code",mendHoles,@"mencods", nil];
    //toMoreMain1
    __weak MendHoleViewController *weakSelf = self;
    //start request
    [HttpTools getHttp:MendHoleURL forParams:mendHoleParam success:^(NSData *nsData){
        MendHoleViewController *strongSelf = weakSelf;
        NSDictionary *recDictionary = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        
        NSLog(@"returnMsg:%@",recDictionary[@"Msg"]);
        
        //
        if ([recDictionary[@"Code"] intValue]> 0) {
            NSDictionary *allMsg = recDictionary[@"Msg"];
            //tbl_taskMendHoleInfo(evecod text,everea text,result text,evesta text,subtim text,mendHoleNum text)
//            NSMutableArray *mendHoleBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],allMsg[@"everes"][@"everea"],allMsg[@"everes"][@"result"],allMsg[@"evesta"],allMsg[@"subtim"],@"", nil];
//            [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_taskMendHoleInfo(evecod,everea,result,evesta,subtim,mendHoleNum) values(?,?,?,?,?,?)" forParameter:mendHoleBackInfo];
//
            NSMutableArray *changeCaddyBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],@"4",allMsg[@"evesta"],allMsg[@"subtim"],allMsg[@"everes"][@"result"],allMsg[@"everes"][@"everea"],allMsg[@"hantim"],weakSelf.logPerson.Rows[0][@"code"],@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
            [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_taskInfo(evecod,evetyp,evesta,subtim,result,everea,hantim,oldCaddyCode,newCaddyCode,oldCartCode,newCartCode,jumpHoleCode,toHoleCode,reqBackTime,reHoleCode,mendHoleCode,ratifyHoleCode,ratifyinTime,selectedHoleCode) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:changeCaddyBackInfo];
            
            [strongSelf performSegueWithIdentifier:@"toTaskDetail" sender:nil];
        }
        else if([recDictionary[@"Code"] intValue] == -5)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"正常球洞还未完成，不能补洞" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            //
            [strongSelf performSegueWithIdentifier:@"toTaskDetail" sender:nil];
        }
        
        
        
    }failure:^(NSError *err){
        NSLog(@"fail request mend");
        
        
    }];
    
    
}
- (IBAction)mendHoleNavBack:(UIBarButtonItem *)sender {
    //
//    [self performSegueWithIdentifier:@"toMoreMain1" sender:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//将相应的信息传到相应的界面中
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    __weak typeof(self) weakSelf = self;
    TaskDetailViewController *taskViewController = segue.destinationViewController;
    taskViewController.taskTypeName = @"补洞详情";
    taskViewController.taskStatus   = @"待处理";
    //查询数据库
    self.mendHoleResult = [self.lcDBCon ExecDataTable:@"select *from tbl_taskMendHoleInfo"];
    //
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([weakSelf.mendHoleResult.Rows count]) {
            NSString *resultStr = [[NSString alloc] init];
            switch ([weakSelf.mendHoleResult.Rows[0][@"result"] intValue]) {
                case 0:
                    resultStr = @"待处理";
                    break;
                case 1:
                    resultStr = @"同意";
                    break;
                case 2:
                    resultStr = @"不同意";
                    break;
                default:
                    break;
            }
            taskViewController.whichInterfaceFrom = 1;
            
            taskViewController.taskStatus = resultStr;
            taskViewController.taskRequestPerson = [NSString stringWithFormat:@"%@ %@",weakSelf.logPerson.Rows[0][@"number"],weakSelf.logPerson.Rows[0][@"name"]];
            NSString *subtime = weakSelf.mendHoleResult.Rows[[weakSelf.mendHoleResult.Rows count] - 1][@"subtim"];
            taskViewController.taskRequstTime = [subtime substringFromIndex:11];
            taskViewController.taskDetailName = @"待补打球洞";
            taskViewController.taskMendHoleNum = @"";
        }
        
    });
    
    
}


@end
