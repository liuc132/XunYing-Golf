//
//  JumpHoleViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/13.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "JumpHoleViewController.h"
#import "HttpTools.h"
#import "XunYingPre.h"
#import "UIColor+UICon.h"
#import "DataTable.h"
#import "DBCon.h"
#import "TaskDetailViewController.h"

#define CurrentHole     @"5ccd73"
#define SelectedHole    @"f74c30"
#define NoSelectedHole  @"cacaca"
#define EitghteenHoles  18

@interface JumpHoleViewController ()

@property (strong, nonatomic) DBCon *locDBCon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *grpInf;
@property (strong, nonatomic) DataTable *curLocInfo;
@property (strong, nonatomic) DataTable *jumpHoleResult;

@property (nonatomic) NSInteger selectedJumpNum;
@property (nonatomic) BOOL      whetherSelectHole;

@property (strong, nonatomic) UIButton *theOldSelectedBtn;
@property (strong, nonatomic) NSDictionary *eventInfoDic;



@property (strong, nonatomic) IBOutlet UIScrollView *jumpHoleScrollView;

@property (strong, nonatomic) IBOutlet UILabel *requestPerson;
@property (strong, nonatomic) IBOutlet UILabel *curHoleNum;
@property (strong, nonatomic) IBOutlet UILabel *jumpHoleNum;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *jumpHoleBack;


- (IBAction)whichHole:(UIButton *)sender;

- (IBAction)jumpHoleNavBack:(UIBarButtonItem *)sender;

- (IBAction)requestToJumpHole:(UIButton *)sender;

@end

@implementation JumpHoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init locDBCon,userInf,grpInf
    self.locDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.grpInf = [[DataTable alloc] init];
    self.curLocInfo = [[DataTable alloc] init];
    self.jumpHoleResult = [[DataTable alloc] init];
    //
    self.whetherSelectHole = NO;
    self.jumpHoleNum.text  = nil;
    //查询申请跳洞的登录人的信息，以及所创建的组信息
    self.logPerson = [self.locDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.grpInf = [self.locDBCon ExecDataTable:@"select *from tbl_holeInf"];
    self.curLocInfo = [self.locDBCon ExecDataTable:@"select *from tbl_locHole"];
    //
    self.jumpHoleScrollView.scrollEnabled = YES;
    self.jumpHoleScrollView.alwaysBounceVertical = YES;
    self.jumpHoleScrollView.directionalLockEnabled = YES;
    
    NSLog(@"finish check out all the data");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"jumpHole" object:nil];
    
}

- (void)getEventFromHeart:(NSNotification *)sender
{
    self.eventInfoDic = sender.userInfo;
    NSLog(@"ChangeCart info:%@ and eventInfoDic:%@",sender.userInfo,self.eventInfoDic);
    
    
}

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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    //将申请人等信息给显示到相应位置
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.logPerson.Rows count]) {
            weakSelf.requestPerson.text = [NSString stringWithFormat:@"%@ %@",weakSelf.logPerson.Rows[0][@"number"],self.logPerson.Rows[0][@"name"]];
        }
        //将当前所在的球洞位置的球洞号显示出来 tbl_locHole(holcod text,holnum text)
        if ([weakSelf.curLocInfo.Rows count]) {
            weakSelf.curHoleNum.text = weakSelf.curLocInfo.Rows[[weakSelf.curLocInfo.Rows count] - 1][@"holnum"];
        }
        
    });
    
}

-(void)settingBackGoundColor:(UIButton *)theOldBtn
{
    [theOldBtn setBackgroundColor:[UIColor HexString:NoSelectedHole]];
}

- (IBAction)whichHole:(UIButton *)sender {
    static unsigned char ucOldSelectedHole = 20;
    
    if(ucOldSelectedHole != sender.tag)
    {
        //将之前选择的按键颜色给改变一下;初始的时候选择跳过的球洞在当前所在的球洞
        [self settingBackGoundColor:self.theOldSelectedBtn];
        
        //记录下之前所选择的球洞按键
        self.theOldSelectedBtn = sender;
        //
        NSLog(@"oldSelectedBtn.tag:%ld",(long)self.theOldSelectedBtn.tag);
        //
        self.jumpHoleNum.text = [NSString stringWithFormat:@"%ld",(long)sender.tag];
        //
        self.selectedJumpNum = sender.tag - 1;
        //设置被选择上的球洞好的背景色为已选状态
        [sender setBackgroundColor:[UIColor HexString:SelectedHole]];
        //确认已经选过了
        self.whetherSelectHole = YES;
    }
    
}

- (IBAction)jumpHoleNavBack:(UIBarButtonItem *)sender {
    NSLog(@"返回当前事务主页面");
    //
//    [self performSegueWithIdentifier:@"toMoreMain" sender:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)requestToJumpHole:(UIButton *)sender {
    
    __weak JumpHoleViewController *weakSelf = self;
    //判断是否已经选好了要跳过的球洞
    if (!self.whetherSelectHole) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择跳过的球洞" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    self.whetherSelectHole = NO;
    //组建跳动请求参数
    NSMutableDictionary *jumpHoleParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.logPerson.Rows[0][@"code"],@"code",self.grpInf.Rows[self.selectedJumpNum][@"holcod"],@"aplcod", nil];
    //start request
    [HttpTools getHttp:JumpHoleURL forParams:jumpHoleParam success:^(NSData *nsData){
        JumpHoleViewController *strongSelf = weakSelf;
        NSLog(@"JumpHole request success");
        
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"code:%@  msg:%@",recDic[@"Code"],recDic[@"Msg"]);
        //
        if ([recDic[@"Code"] intValue] > 0) {
            NSDictionary *allMsg = recDic[@"Msg"];
            //tbl_taskJumpHoleInfo(evecod text,everea text,result text,evesta text,jumpHoleCode text,jumpHoleNum text,toHoleCode,toHoleNum text,subtim text)
//            NSMutableArray *jumpHoleBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],allMsg[@"everes"][@"everea"],allMsg[@"everes"][@"result"],allMsg[@"evesta"],weakSelf.grpInf.Rows[weakSelf.selectedJumpNum][@"holcod"],weakSelf.grpInf.Rows[weakSelf.selectedJumpNum][@"holenum"],@"",@"",allMsg[@"subtim"], nil];
//            [weakSelf.locDBCon ExecNonQuery:@"insert into tbl_taskJumpHoleInfo(evecod,everea,result,evesta,jumpHoleCode,jumpHoleNum,toHoleCode,toHoleNum,subtim) values(?,?,?,?,?,?,?,?,?)" forParameter:jumpHoleBackInfo];
            //
            NSMutableArray *changeCaddyBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],@"3",allMsg[@"evesta"],allMsg[@"subtim"],allMsg[@"everes"][@"result"],allMsg[@"everes"][@"everea"],allMsg[@"hantim"],@"",@"",@"",@"",weakSelf.grpInf.Rows[weakSelf.selectedJumpNum][@"holcod"],@"",@"",@"",@"",@"",@"",@"", nil];
            [weakSelf.locDBCon ExecNonQuery:@"insert into tbl_taskInfo(evecod,evetyp,evesta,subtim,result,everea,hantim,oldCaddyCode,newCaddyCode,oldCartCode,newCartCode,jumpHoleCode,toHoleCode,reqBackTime,reHoleCode,mendHoleCode,ratifyHoleCode,ratifyinTime,selectedHoleCode) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:changeCaddyBackInfo];
            
            //执行跳转
            [strongSelf performSegueWithIdentifier:@"toTaskDetail" sender:nil];
        }
        
    }failure:^(NSError *err){
        NSLog(@"JumpHole request fail");
        
        
    }];
    
}
//将相应的信息传到相应的界面中
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    __weak typeof(self) weakSelf = self;
    TaskDetailViewController *taskViewController = segue.destinationViewController;
    taskViewController.taskTypeName = @"跳洞详情";
    //查询数据库
    self.jumpHoleResult = [self.locDBCon ExecDataTable:@"select *from tbl_taskInfo"];
    //
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([weakSelf.jumpHoleResult.Rows count]) {
            NSString *resultStr = [[NSString alloc] init];
            switch ([weakSelf.jumpHoleResult.Rows[0][@"result"] intValue]) {
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
            NSString *subtime = weakSelf.jumpHoleResult.Rows[[weakSelf.jumpHoleResult.Rows count] - 1][@"subtim"];
            taskViewController.taskRequstTime = [subtime substringFromIndex:11];
            taskViewController.taskDetailName = @"跳过球洞";
            //
            NSString *willJumpHoleCode = [NSString stringWithFormat:@"%@",weakSelf.jumpHoleResult.Rows[[weakSelf.jumpHoleResult.Rows count] - 1][@"jumpHoleCode"]];
            NSArray *allHoleArray = self.grpInf.Rows;
            for (NSDictionary *eachHole in allHoleArray) {
                if ([eachHole[@"holcod"] isEqualToString:willJumpHoleCode]) {
                    taskViewController.taskJumpHoleNum = [NSString stringWithFormat:@"%@",eachHole[@"holenum"]];
                }
                
            }
            
        }
        
        
    });
    
}


@end
