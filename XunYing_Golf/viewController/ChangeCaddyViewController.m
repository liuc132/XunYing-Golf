//
//  ChangeCaddyViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/17.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "ChangeCaddyViewController.h"
#import "HttpTools.h"
#import "XunYingPre.h"
#import "DBCon.h"
#import "DataTable.h"
#import "UIColor+UICon.h"

typedef enum ChangeReason{
    CaddyRequest = 21,
    CustomRequest,
    OtherReason = 99
}changeReasonEnum;

#define reasonSelectColor           @"0197d6"
#define reasonUnselectWordColor     @"999999"



@interface ChangeCaddyViewController ()<UIGestureRecognizerDelegate>


@property (strong, nonatomic) IBOutlet UIView *caddyView1;
@property (strong, nonatomic) IBOutlet UILabel *firstChange;
@property (strong, nonatomic) IBOutlet UIView *caddyView2;
@property (strong, nonatomic) IBOutlet UILabel *secondChange;
@property (strong, nonatomic) IBOutlet UIView *caddyView3;
@property (strong, nonatomic) IBOutlet UILabel *thirdChange;
@property (strong, nonatomic) IBOutlet UIView *caddyView4;
@property (strong, nonatomic) IBOutlet UILabel *fourthChange;

@property (strong, nonatomic) IBOutlet UIButton *caddyReason;
@property (strong, nonatomic) IBOutlet UIButton *customRequest;
@property (strong, nonatomic) IBOutlet UIButton *otherReason;


- (IBAction)changeReason:(UIButton *)sender;
- (IBAction)sendRequest:(UIButton *)sender;
- (IBAction)backToMoreMain:(UIBarButtonItem *)sender;

//
@property (strong, nonatomic) DBCon *lcDBCon;
@property (strong, nonatomic) DataTable *requestPerson;
@property (strong, nonatomic) DataTable *groInfo;

@property (nonatomic) NSString *changeReasonStr;
@property (strong, nonatomic) NSDictionary *eventInfoDic;


@end

@implementation ChangeCaddyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"enter change caddy viewDidLoad");
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondListCaddy:)];
//    tapGesture.delegate = self;
//    [self.view addGestureRecognizer:tapGesture];
    //
    self.lcDBCon = [[DBCon alloc] init];
    self.requestPerson = [[DataTable alloc] init];
    self.groInfo       = [[DataTable alloc] init];
    //setting the initial state
    self.changeReasonStr = [NSString stringWithFormat:@"%d",CaddyRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"changeCaddy" object:nil];
    
}

- (void)getEventFromHeart:(NSNotification *)sender
{
    self.eventInfoDic = sender.userInfo;
    NSLog(@"ChangeCart info:%@ and eventInfoDic:%@",sender.userInfo,self.eventInfoDic);
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //查询申请人的信息
    self.requestPerson = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.groInfo       = [self.lcDBCon ExecDataTable:@"select *from tbl_groupInf"];
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        //setting default reason color
        self.caddyReason.backgroundColor = [UIColor HexString:reasonSelectColor];
        self.caddyReason.titleLabel.textColor = [UIColor whiteColor];
        //
        self.customRequest.backgroundColor = [UIColor whiteColor];
        self.customRequest.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
        self.otherReason.backgroundColor = [UIColor whiteColor];
        self.otherReason.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
        //球童显示
        //初始化登录人的信息
        switch ([self.requestPerson.Rows count]) {
                //none
            case 0:
                self.caddyView1.hidden = YES;
                self.caddyView2.hidden = YES;
                self.caddyView3.hidden = YES;
                self.caddyView4.hidden = YES;
                break;
                //one caddy
            case 1:
                self.caddyView2.hidden = YES;
                self.caddyView3.hidden = YES;
                self.caddyView4.hidden = YES;
                //将相应的球童的名字显示出来
                self.firstChange.text = self.requestPerson.Rows[0][@"name"];
                self.firstChange.textColor = [UIColor blackColor];
                
                break;
                //two caddies
            case 2:
                self.caddyView3.hidden = YES;
                self.caddyView4.hidden = YES;
                //将相应的球童的名字显示出来
                self.firstChange.text = self.requestPerson.Rows[0][@"name"];
                self.firstChange.textColor = [UIColor blackColor];
                self.secondChange.text = self.requestPerson.Rows[1][@"name"];
                self.secondChange.textColor = [UIColor blackColor];
                break;
                //three caddies
            case 3:
                self.caddyView4.hidden = YES;
                //将相应的球童的名字显示出来
                self.firstChange.text = self.requestPerson.Rows[0][@"name"];
                self.firstChange.textColor = [UIColor blackColor];
                self.secondChange.text = self.requestPerson.Rows[1][@"name"];
                self.secondChange.textColor = [UIColor blackColor];
                self.thirdChange.text = self.requestPerson.Rows[2][@"name"];
                self.thirdChange.textColor = [UIColor blackColor];
                break;
                //have four caddies
            case 4:
                self.firstChange.text = self.requestPerson.Rows[0][@"name"];
                self.secondChange.text = self.requestPerson.Rows[1][@"name"];
                self.thirdChange.text = self.requestPerson.Rows[2][@"name"];
                self.fourthChange.text = self.requestPerson.Rows[3][@"name"];
                break;
            default:
                break;
        }
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeReason:(UIButton *)sender {
    NSLog(@"change Reason:%@",sender.titleLabel.text);
    //
    __weak typeof(self) weakSelf = self;
    //
    static BOOL firstReason = YES;
    static BOOL secondReason = NO;
    static BOOL thirdReason = NO;
    //临时存储所有的原因
    NSMutableArray *changeReasonArray = [[NSMutableArray alloc] init];
    //为提交更换球童的申请准备数据－替换原因
    NSInteger whichButton;
    whichButton = sender.tag;
    //
    switch (whichButton) {
        case 0:
            firstReason = !firstReason;
            break;
        case 1:
            secondReason = !secondReason;
            break;
        case 2:
            thirdReason = !thirdReason;
            break;
        default:
            break;
    }
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        /*-------解决显示的问题以及讲相应的原因写入一个NSMutableArray中------*/
        //first
        if (firstReason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.caddyReason.backgroundColor = [UIColor HexString:reasonSelectColor];
                weakSelf.caddyReason.titleLabel.textColor = [UIColor whiteColor];
            });
            
            if([changeReasonArray count] < 4)
                [changeReasonArray addObject:[NSString stringWithFormat:@"%d",CaddyRequest]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.caddyReason.backgroundColor = [UIColor whiteColor];
                weakSelf.caddyReason.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
            });
            
            
            for (NSString *otherRea in changeReasonArray) {
                if ([otherRea intValue] == CaddyRequest) {
                    [changeReasonArray removeObject:[NSString stringWithFormat:@"%d",CaddyRequest]];
                }
            }
        }
        //second
        if (secondReason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.customRequest.backgroundColor = [UIColor HexString:reasonSelectColor];
                weakSelf.customRequest.titleLabel.textColor = [UIColor whiteColor];
            });
            
            if([changeReasonArray count] < 4)
                [changeReasonArray addObject:[NSString stringWithFormat:@"%d",CustomRequest]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.customRequest.backgroundColor = [UIColor whiteColor];
                weakSelf.customRequest.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
            });
            
            for (NSString *otherRea in changeReasonArray) {
                if ([otherRea intValue] == CustomRequest) {
                    [changeReasonArray removeObject:[NSString stringWithFormat:@"%d",CustomRequest]];
                }
            }
        }
        //third
        if (thirdReason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.otherReason.backgroundColor = [UIColor HexString:reasonSelectColor];
                weakSelf.otherReason.titleLabel.textColor = [UIColor whiteColor];
            });
            
            if([changeReasonArray count] < 4)
                [changeReasonArray addObject:[NSString stringWithFormat:@"%d",OtherReason]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.otherReason.backgroundColor = [UIColor whiteColor];
                weakSelf.otherReason.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
            });
            
            for (NSString *otherRea in changeReasonArray) {
                if ([otherRea intValue] == OtherReason) {
                    [changeReasonArray removeObject:[NSString stringWithFormat:@"%d",OtherReason]];
                }
            }
        }
        /*-------解决显示的问题------*/
        
        //在最后将相应的原因给组装成一个字符串，作为提交请求时的参数
        switch ([changeReasonArray count]) {
            case 1:
                weakSelf.changeReasonStr = changeReasonArray[0];
                break;
                //
            case 2:
                weakSelf.changeReasonStr = [NSString stringWithFormat:@"%@;%@",changeReasonArray[0],changeReasonArray[1]];
                break;
                //
            case 3:
                weakSelf.changeReasonStr = [NSString stringWithFormat:@"%@;%@;%@",changeReasonArray[0],changeReasonArray[1],changeReasonArray[2]];
                break;
            default:
                weakSelf.changeReasonStr = nil;
                break;
        }
        
        NSLog(@"changeReason:%@",weakSelf.changeReasonStr);
        
        
    });
    
}

- (IBAction)sendRequest:(UIButton *)sender {
    NSLog(@"提交申请");
    __weak typeof(self) weakSelf = self;
    
    NSLog(@"requestPerson:%@",self.requestPerson);
    //判断当前所读取到的数据是否为空，为空则返回（可以给予提示）
    if(![self.requestPerson.Rows count])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"换球车异常" message:@"申请人数据为空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //获取到当前系统的时间，并生成相应的格式
    NSDateFormatter *dateFarmatter = [[NSDateFormatter alloc] init];
    [dateFarmatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *curDateTime = [dateFarmatter stringFromDate:[NSDate date]];
    //构建参数
    NSMutableDictionary *changeCaddyParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.requestPerson.Rows[0][@"code"],@"empcod",self.groInfo.Rows[0][@"grocod"],@"grocod",self.changeReasonStr,@"reason",self.requestPerson.Rows[0][@"code"],@"cadcod",curDateTime,@"subtim", nil];//[[NSDictionary alloc ] initWithObjectsAndKeys:MIDCODE,@"mid", nil];
    
    //进行HTTP请求，并在收到正确的消息之后返回
    [HttpTools getHttp:ChangeCaddyURL forParams:changeCaddyParam success:^(NSData *nsData){
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"recDic:%@ Msg:%@ andCode:%@",recDic,recDic[@"Msg"],recDic[@"Code"]);
        //
        if ([recDic[@"Code"] intValue] > 0) {
            
            
            //执行跳转程序
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        }
        
        
    }failure:^(NSError *err){
        
    }];
}

- (IBAction)backToMoreMain:(UIBarButtonItem *)sender {
//    [self performSegueWithIdentifier:@"toMoreMain2" sender:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
