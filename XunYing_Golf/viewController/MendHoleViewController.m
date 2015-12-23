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
@property (strong, nonatomic) DBCon     *lcDBCon;
@property (strong, nonatomic) NSMutableArray *needMendHoles;
@property (strong, nonatomic) NSDictionary *eventInfoDic;

@end

@implementation MendHoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init
    self.lcDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.holesInf  = [[DataTable alloc] init];
    //在本地数据库中查询数据
    self.logPerson = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.holesInf  = [self.lcDBCon ExecDataTable:@"select *from tbl_holeInf"];
    //测试用，初始化数据
    self.needMendHoles = [[NSMutableArray alloc] initWithObjects:@"2",@"9",@"11", nil];
    //
    self.mendHoleScrollView.scrollEnabled = YES;
    self.mendHoleScrollView.directionalLockEnabled = YES;
    self.mendHoleScrollView.alwaysBounceVertical = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"mendHole" object:nil];
    
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
    if ([self.logPerson.Rows count]) {
        self.requestMendUser.text = [NSString stringWithFormat:@"%@ %@",self.logPerson.Rows[0][@"number"],self.logPerson.Rows[0][@"name"]];
    }
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

- (IBAction)requestMendHole:(UIButton *)sender {
    NSLog(@"requestMendHole");
    //通过代理，读取到总共跳过了哪些球洞，NSMutableArray类型的数据来存储数据
    NSString *mendHoles = [[NSString alloc] init];
    NSMutableArray *theseHoles = [[NSMutableArray alloc] init];
    if([self.needMendHoles count] > 1)
    {
        for(unsigned char i = 0;i < [self.needMendHoles count];i++)
        {
            NSLog(@"%d",[self.needMendHoles[i] intValue]);
            [theseHoles addObject:self.holesInf.Rows[[self.needMendHoles[i] intValue]][@"holcod"]];
        }
        mendHoles = [NSString stringWithFormat:@"%@",theseHoles[0]];//先添加第一个到字符中
        //之后将剩下的给添加进去（带有逗号","）
        for (unsigned char j = 1; j < [theseHoles count]; j++) {
            mendHoles = [mendHoles stringByAppendingString:[NSString stringWithFormat:@",%@",theseHoles[j]]];
        }
    }
    else
    {
        mendHoles = self.holesInf.Rows[[self.needMendHoles.firstObject intValue]][@"holcod"];
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
        if (recDictionary[@"Code"] > 0) {
            NSDictionary *allMsg = recDictionary[@"Msg"];
            
            
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
    TaskDetailViewController *taskViewController = segue.destinationViewController;
    taskViewController.taskTypeName = @"补洞详情";
    
}


@end
