//
//  LogInViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/7.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "LogInViewController.h"
#import "DBCon.h"
#import "HttpTools.h"
#import "ActivityIndicatorView.h"
#import "UIColor+UICon.h"
#import "ViewController.h"
#import "MainViewController.h"
#import "Reachability.h"
#import "HeartBeatAndDetectState.h"
#import "passValueLogInDelegate.h"
#import "AppDelegate.h"
//#import "WaitToPlayTableViewController.h"
extern BOOL allowDownCourt;

@interface LogInViewController ()<UIGestureRecognizerDelegate,UIAlertViewDelegate>

//@property(strong, nonatomic) ActivityIndicatorView *activityView;
@property(nonatomic) BOOL forgetCode;
@property(nonatomic) BOOL remCode;

@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) Reachability *wifiReachability;
@property (strong, nonatomic) Reachability *hostReachability;
@property (nonatomic) NetworkStatus curNetworkStatus;
@property (strong, nonatomic) UIAlertView *forceLogInAlert;
@property (strong, nonatomic) NSMutableDictionary *logInParams;
@property(strong, nonatomic)NSMutableDictionary *checkCreatGroupState;

@property(strong, nonatomic)UIActivityIndicatorView *activityIndicatorView;

//
@property(strong, nonatomic)DBCon *dbCon;
@property (strong, nonatomic) DataTable *logInPerson;
@property (strong, nonatomic) DataTable *logPersonInf;

@property (strong, nonatomic) IBOutlet UITextView *account;
@property (strong, nonatomic) IBOutlet UITextView *password;
@property (nonatomic) BOOL haveGroupNotDown;


- (IBAction)logInButton:(UIButton *)sender;
- (IBAction)forgetPassword:(UIButton *)sender;




@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"enter Login viewcontroller");
    [AppDelegate storyBoardAutoLay:self.view];
    
    
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap:)];
    self.tap.delegate = self;
    [self.view addGestureRecognizer:self.tap];
    
    //init activityIndicatorView
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.activityIndicatorView.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.activityIndicatorView.layer.cornerRadius = 20;
    
    [self.view addSubview:self.activityIndicatorView];
    
    self.activityIndicatorView.hidden = YES;
    
    //init and alloc dbCon
    self.dbCon = [[DBCon alloc] init];
    //添加网络状态监测初始化设置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentNetworkState:) name:kReachabilityChangedNotification object:nil];
    
//    NSString *remoteHostName = @"www.apple.com";
//    NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
//    self.remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
//    
//    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
//    [self.hostReachability startNotifier];
//    [self updateInterfaceWithReachability:self.hostReachability];
    
    NSString *remoteHostName = @"http://192.168.1.119:8081/XYGolfManage";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    //
    self.logInPerson = [[DataTable alloc] init];
    self.logPersonInf = [[DataTable alloc] init];
    //
    self.logPersonInf = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    NSLog(@"logPersonInf:%@",self.logInPerson);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canDownCourt:) name:@"allowDown" object:nil];
}

-(void)canDownCourt:(NSNotification *)sender
{
    NSLog(@"sender:%@",sender);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    if ([sender.userInfo[@"allowDown"] isEqualToString:@"1"]) {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        //执行跳转程序，此时判断的是已经创建了组
        [self performSegueWithIdentifier:@"ToMainMapView" sender:nil];
    }
    else if([sender.userInfo[@"waitToAllow"] isEqualToString:@"1"])
    {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        [self performSegueWithIdentifier:@"shouldWaitToAllow" sender:nil];
    }
    //若没有退出则直接跳转到建组方式的界面（手动，二维码等）
    else if([self.logInPerson.Rows count]) {
        [self checkCurStateOnServer];
        if([self.logInPerson.Rows[[self.logInPerson.Rows count] - 1][@"logOutOrNot"] boolValue])
        {
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            //
            [self performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
        }
    }

}

//
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"allowDown"]) {
//        NSLog(@"object:%@",object);
//    }
//}

#pragma -mark currentNetworkState
-(void)currentNetworkState:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    //
    [self checkNetworkState:curReach];
}
#pragma -mark checkNetworkState
-(void)checkNetworkState:(Reachability *)reachability
{
    NSLog(@"reachability:%@",reachability);
    //wifi state
    Reachability *wifiState = [Reachability reachabilityForLocalWiFi];
    //监测手机上能否上网络（wifi/3G/2.5G）
    Reachability *connectState = [Reachability reachabilityForInternetConnection];
    //判断网络状态
    if([wifiState currentReachabilityStatus] != NotReachable)
    {
        NSLog(@"连接上了WI-FI");
        self.curNetworkStatus = ReachableViaWiFi;
    }
    else if([connectState currentReachabilityStatus] != NotReachable)
    {
        NSLog(@"使用自己的手机上的蜂窝网络进行上网");
        self.curNetworkStatus = ReachableViaWWAN;
    }
    else
    {
        NSLog(@"没有网络");
        self.curNetworkStatus = NotReachable;
    }
}
#pragma -mark updateInterfaceWithReachability
-(NetworkStatus)updateInterfaceWithReachability:(Reachability *)curReach
{
    self.curNetworkStatus = [curReach currentReachabilityStatus];
    
    return self.curNetworkStatus;
}


-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//-(NSInteger)application

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //
    [self.view removeGestureRecognizer:self.tap];
    //
    NSLog(@"holeType:%@  holeCount:%ld",self.curHoleName,(long)self.customerCount);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //research the logPerson's information
    self.logInPerson = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    if([self.logInPerson.Rows count])
    {
        self.account.text = self.logInPerson.Rows[[self.logInPerson.Rows count] - 1][@"user"];
        self.password.text = self.logInPerson.Rows[[self.logInPerson.Rows count] -1][@"password"];
        //检查当前的状态
        [self checkCurStateOnServer];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    //
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addGestureRecognizer:self.tap];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBarHidden = NO;
}


/**
 *  忘记密码
 *
 *  @param sender 对应的按键信息
 */
- (IBAction)forgetPassword:(UIButton *)sender {
    NSLog(@"forgetPassword");
    //
    if(!self.forgetCode){
        self.forgetCode = YES;
        //change image
        [sender setImage:[UIImage imageNamed:@"logInUnselected.png"] forState:UIControlStateNormal];
    }
    else{
        self.forgetCode = NO;
        //change image
        [sender setImage:[UIImage imageNamed:@"logInSelected.png"] forState:UIControlStateNormal];
    }
}

#pragma -mark getCaddyCartInf
-(void)getCaddyCartInf
{
    NSLog(@"enter getCaddyCartInf");
    __weak typeof(self) wealSelf = self;
    //删除保存在内存中的以前的数据
    //前九洞，后九洞，十八洞
    [self.dbCon ExecNonQuery:@"delete from tbl_threeTypeHoleInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_cartInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_threeTypeHoleInf"];
    //start request
    [HttpTools getHttp:CaddyCartInfURL forParams:nil success:^(NSData *nsData){
        NSLog(@"successfully request");
        NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"caddy count:%ld",[receiveDic[@"Msg"][@"caddys"] count]);
        //获取到当前的球车
        NSArray *allCarts = receiveDic[@"Msg"][@"carts"];
//        NSDictionary *oneCart = [[NSDictionary alloc] init];
        for (NSDictionary *eachCart in allCarts) {
            NSMutableArray *eachCartParam = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
            //tbl_cartInf(carcod text,carnum text,carsea text)
            [wealSelf.dbCon ExecNonQuery:@"insert into tbl_cartInf(carcod,carnum,carsea) values(?,?,?)" forParameter:eachCartParam];
        }
        //保存所有可用球童的信息
        NSArray *allCaddies = receiveDic[@"Msg"][@"caddys"];
        for (NSDictionary *eachCaddy in allCaddies) {
            NSMutableArray *eachCaddyParam = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
            //tbl_caddyInf(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
            [self.dbCon ExecNonQuery:@"insert into tbl_caddyInf(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:eachCaddyParam];
        }
        
        //保存三种类型的球洞的参数
        NSArray *allHoles = receiveDic[@"Msg"][@"holes"];
        for (NSDictionary *eachTypeHole in allHoles) {
            NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachTypeHole[@"pdcod"],eachTypeHole[@"pdind"],eachTypeHole[@"pdnam"],eachTypeHole[@"pdpcod"],eachTypeHole[@"pdtag"],eachTypeHole[@"pdtcod"], nil];
            [self.dbCon ExecNonQuery:@"insert into tbl_threeTypeHoleInf(pdcod,pdind,pdnam,pdpcod,pdtag,pdtcod) values(?,?,?,?,?,?)" forParameter:eachHoleParam];
        }
        //执行查询数据库中的参数的例子
        //    DataTable *table = [[DataTable alloc] init];
        //    table = [dbCon ExecDataTable:@"select *from tbl_logPerson"];
        //    NSLog(@"Table.Rows[0]:%@",table.Rows[0][@"code"]);
        DataTable *threeHolesInf = [[DataTable alloc]init];
        threeHolesInf = [self.dbCon ExecDataTable:@"select *from tbl_threeTypeHoleInf"];
        //NSLog(@"top9:%@\n down9:%@\n all:%@",threeHolesInf.Rows[0],threeHolesInf.Rows[1],threeHolesInf.Rows[2]);
        NSLog(@"holeInf:%@",threeHolesInf);
        //NSLog(@"end store the three holes information");
        
        
        
    }failure:^(NSError *err){
        NSLog(@"caddyCartInf request failed");
        
    }];
}
#pragma -mark getCustomInf
-(void)getCustomInf
{
    NSLog(@"enter getCustomInf");
    __weak typeof(self) weakSelf = self;
    
    //delete the old data in the database
    [self.dbCon ExecNonQuery:@"delete from tbl_CustomerNumbers"];
    
    
    //start request
    [HttpTools getHttp:CustomInfURL forParams:nil success:^(NSData *nsData){
        NSLog(@"request successfully");
        NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        //
        NSString *cusNumberString = [[NSString alloc] init];
        cusNumberString = receiveDic[@"Msg"];
        NSArray *cusNumberArray = [cusNumberString componentsSeparatedByString:@";"];//拆分接收到的数据
        //将数据加载到创建的数据库中
        //first text,second text,third text,fourth text
        [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_CustomerNumbers(first,second,third,fourth) VALUES(?,?,?,?)" forParameter:(NSMutableArray *)cusNumberArray];
        
    }failure:^(NSError *err){
        NSLog(@"request fail");
        
    }];
}


-(void)backgroundTap:(id)sender
{
    //NSLog(@"enter backgroundTap");
    [self.account resignFirstResponder];
    [self.password resignFirstResponder];
}
#pragma -mark forceLogInAlert
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak LogInViewController *weakSelf = self;
    //
    if(alertView.tag == 1)
    {
        switch (buttonIndex) {
            case 0:
                NSLog(@"取消强制登录");
                
                break;
            case 1:
                NSLog(@"执行强制登录");
                //调用强制登录接口
                //修改强制登录的参数为1
                [self.logInParams setObject:@"1" forKey:@"forceLogin"];
                //调用接口进行传参数
                [HttpTools getHttp:loginURL forParams:self.logInParams success:^(NSData *nsData){
                    NSLog(@"成功强制登录");
                    //
                    NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
                    NSLog(@"msg:%@",recDic[@"Msg"]);
                    //创建登录人信息数组
                    //1sex cadShowNum 1empcod 1empnam 1empnum 1empjob
                    //code text,job text,name text,number text,sex text,caddyLogIn text
                    NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                    //将数据加载到创建的数据库中
                    [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                    //
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //进入建组界面，发送获取参数（球童，球车，球场的球洞），之后发送
                        [weakSelf getCaddyCartInf];
                        //获取客户信息
                        [weakSelf getCustomInf];
                        //关闭activityIndicator
                        [weakSelf.activityIndicatorView stopAnimating];
                        weakSelf.activityIndicatorView.hidden = YES;
                        //
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(recDic[@"Msg"][@"group"] == NULL)
                                [weakSelf performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
                            else
                            {
                                [weakSelf performSegueWithIdentifier:@"directToWaitingDown" sender:nil];
                            }
                            
                        });
                        
                    });
                    
                }failure:^(NSError *err){
                    NSLog(@"强制登录失败");
                    
                }];
                
                break;

        }
    }
    
}

//-(void)loadView
//{
//    [super loadView];
//    CGRect rect = [[UIScreen mainScreen] applicationFrame];
//    UIView *view = [[UIView alloc] initWithFrame:rect];
//    view.backgroundColor = self.view.backgroundColor;
//    self.view = view;
//}

#pragma -mark logInButton
-(void)logIn
{
    NSLog(@"enter login");
    //    [self performSegueWithIdentifier:@"jumpToCreateGroup" sender:self];
    
    //    [self.activityView showIndicator];
    
    //    DBCon *dbCon = [DBCon instance];
    //update data when first logIn
    [self.dbCon ExecNonQuery:@"delete from tbl_logInBackInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_logPerson"];
    [self.dbCon ExecNonQuery:@"delete from tbl_holeInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_EmployeeInf"];
    
    //start request from the server
    NSLog(@"username:%@,password:%@",self.account.text,self.password.text);
    
    
    if(self.curNetworkStatus == NotReachable)
    {
        UIAlertView *networkUnreachableAlert = [[UIAlertView alloc] initWithTitle:@"网络连接异常" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [networkUnreachableAlert show];
    }
    //
    else if(([self.account.text isEqual: @""]) || ([self.password.text isEqual: @""]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入用户名及密码" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    }
    else{
        __weak LogInViewController *weakSelf = self;
        //
//        [self.activityIndicatorView startAnimating];
//        self.activityIndicatorView.hidden = NO;
        //判读输入帐号
        if(![self.logInPerson.Rows count])
        {
            //构建登录人参数，并且将数据给存储到内存中
            NSMutableArray *logInPersonInf = [[NSMutableArray alloc] initWithObjects:self.account.text,self.password.text,@"1", nil];
            [self.dbCon ExecNonQuery:@"insert into tbl_NamePassword(user,password,logOutOrNot) values(?,?,?)" forParameter:logInPersonInf];
        }
        else
        {
            BOOL whetherAdd;
            whetherAdd = NO;
            for(unsigned char i = 0;i < [self.logInPerson.Rows count];i++)
            {
                if(self.logInPerson.Rows[i][@"user"] != self.account.text)
                {
                    whetherAdd = YES;
                }
                else if (![self.logInPerson.Rows[i][@"logOutOrNot"] boolValue])
                {
                    whetherAdd = YES;
                }
                else //有相同的出现时，立马推出查询循环
                {
                    whetherAdd = NO;
                    break;
                }
            }
            //通过查询比较发现没有相同的账号在，故此添加帐号
            if(whetherAdd)
            {
                //构建登录人参数，并且将数据给存储到内存中
                NSMutableArray *logInPersonInf = [[NSMutableArray alloc] initWithObjects:self.account.text,self.password.text,@"1", nil];
                [self.dbCon ExecNonQuery:@"insert into tbl_NamePassword(user,password,logOutOrNot) values(?,?,?)" forParameter:logInPersonInf];
            }
        }
        [self.dbCon ExecNonQuery:@"delete from tbl_NamePassword where user = 036"];
        
        //构建登录参数
        self.logInParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.account.text,@"username",self.password.text,@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
        
        //
        [HttpTools getHttp:loginURL forParams:self.logInParams success:^(NSData *nsData){
            LogInViewController *strongSelf = weakSelf;
            NSLog(@"success login");
            //
            self.logInPerson = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
            //store data from server
            NSDictionary *reDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            //handle error
            NSLog(@"Code:%@",reDic[@"Code"]);
            NSLog(@"message is:%@",reDic[@"Msg"]);
            
            strongSelf.forceLogInAlert = [[UIAlertView alloc]initWithTitle:@"是否强制登录" message:nil delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            strongSelf.forceLogInAlert.tag = 1;
            
            if([reDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
            {
                NSLog(@"fail");
                return ;
            }
            else if([reDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-2]])
                NSLog(@"parameter is null");
            else if ([reDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
                NSLog(@"The Mid id illegal");
            else if ([reDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]])
            {
                NSLog(@"message is:%@",reDic[@"Msg"]);
                //是否强制登录，显示
                [strongSelf.forceLogInAlert show];
            }
            else if ([reDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:1]]){
                NSDictionary *recDictionary = [[NSDictionary alloc] initWithDictionary:reDic[@"Msg"]];
                
                //创建登录人信息数组
                //1sex cadShowNum 1empcod 1empnam 1empnum 1empjob
                //code text,job text,name text,number text,sex text,caddyLogIn text
                NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDictionary[@"logemp"][@"empcod"],recDictionary[@"logemp"][@"empjob"],recDictionary[@"logemp"][@"empnam"],recDictionary[@"logemp"][@"empnum"],recDictionary[@"logemp"][@"empsex"],recDictionary[@"logemp"][@"cadShowNum"], nil];
                //将数据加载到创建的数据库中
                [self.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                
                //执行查询功能
                DataTable *table = [[DataTable alloc] init];
                table = [self.dbCon ExecDataTable:@"select *from tbl_logPerson"];
                NSLog(@"Table.Rows[0]:%@",table.Rows[0][@"code"]);
                
                //获取到球洞信息，并将相应的信息保存到内存中
                NSArray *allHolesInfo = recDictionary[@"holes"];
                for (NSDictionary *eachHole in allHolesInfo) {
                    NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
                }
                
//                DataTable *table11 = [[DataTable alloc] init];
//                table11 = [weakSelf.dbCon ExecDataTable:@"select *from tbl_holeInf"];
                //获取到所有职员的信息
                dispatch_async(dispatch_get_main_queue(), ^{
                    //获取到所有球员的数组
                    NSArray *allEmployee = recDictionary[@"emps"];
                    for (NSDictionary *eachEmployee in allEmployee) {
                        NSMutableArray *eachEmpParam = [[NSMutableArray alloc] initWithObjects:eachEmployee[@"empcod"],eachEmployee[@"empjob"],eachEmployee[@"empnam"],eachEmployee[@"empnum"],eachEmployee[@"empsex"],eachEmployee[@"loctime"],eachEmployee[@"online"],eachEmployee[@"x"],eachEmployee[@"y"], nil];
                        [weakSelf.dbCon ExecNonQuery:@"insert into tbl_EmployeeInf(empcod,empjob,empnam,empnum,empsex,loctime,online,x,y) values(?,?,?,?,?,?,?,?,?)" forParameter:eachEmpParam];
                    }
//                    DataTable *table11 = [[DataTable alloc] init];
//                    table11 = [weakSelf.dbCon ExecDataTable:@"select *from tbl_EmployeeInf"];
//                    NSLog(@"table11:%@",table11.Rows);
                });
                
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    //进入建组界面，发送获取参数（球童，球车，球场的球洞），之后发送
                    [strongSelf getCaddyCartInf];
                    //获取客户信息
                    [strongSelf getCustomInf];
                    //关闭activityIndicator
                    [self.activityIndicatorView stopAnimating];
                    self.activityIndicatorView.hidden = YES;
                    //
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //执行跳转
                        [strongSelf performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
                    });
                });
                
            }
            
            
        }failure:^(NSError *err){
            NSLog(@"fail login");
            //            [self.activityView hideIndicator];
            //            [self.activityView removeFromSuperview];
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求超时" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alert show];
            
            
            
        }];
    }
}

-(void)checkCurStateOnServer
{
    [self.activityIndicatorView startAnimating];
    self.activityIndicatorView.hidden = NO;
    //
    self.haveGroupNotDown = NO;
    //
    [self.dbCon ExecNonQuery:@"delete from tbl_logPerson"];
    //构建判断是否可以建组参数
    if (![self.logInPerson.Rows count]) {
        [self logIn];
        return;
    }
    self.checkCreatGroupState = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.logPersonInf.Rows[[self.logPersonInf.Rows count] - 1][@"user"],@"username",self.logPersonInf.Rows[[self.logPersonInf.Rows count] - 1][@"password"],@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
    //
    __weak LogInViewController *weakSelf = self;
    //request
    [HttpTools getHttp:DecideCreateGrpAndDownField forParams:self.checkCreatGroupState success:^(NSData *nsData){
        //
        LogInViewController *strongSelf = weakSelf;
        NSLog(@"request successfully");
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"code:%@\n msg:%@",recDic[@"Code"],recDic[@"Msg"]);
        NSLog(@"124");
        //
        if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
        {
            
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-2]])
        {
            
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
        {
            
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]])
        {
            
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            [self.dbCon ExecDataTable:@"delete from tbl_groupInf"];
            [self.dbCon ExecDataTable:@"delete from tbl_holeInf"];
            [self.dbCon ExecDataTable:@"delete from tbl_CustomersInfo"];
            //
            //获取到球洞信息，并将相应的信息保存到内存中
            NSArray *allHolesInfo = recDic[@"holes"];
            for (NSDictionary *eachHole in allHolesInfo) {
                NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
            }
            //
            NSString *groupValue = [recDic[@"Msg"] objectForKey:@"group"];
            if([(NSNull *)groupValue isEqual: @"null"])//
            {
                [self logIn];
            }
            else//
            {
                [self.dbCon ExecDataTable:@"delete from tbl_selectCart"];
                //获取到登录小组的所有客户的信息
                NSArray *allCustomers = recDic[@"Msg"][@"group"][@"cuss"];
                for (NSDictionary *eachCus in allCustomers) {
                    NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                }
                //将所选择的球车的信息保存下来
                //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                NSArray *allSelectedCartsArray = recDic[@"Msg"][@"group"][@"cars"];
                for (NSDictionary *eachCart in allSelectedCartsArray) {
                    NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                    [strongSelf.dbCon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                }
                //此处的数据还没有传递到需要的地方去
                self.customerCount = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                self.curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
                //
                //                if ([curHoleName isEqualToString:@"上九洞"]) {
                //                    ucHolePosition = 0;
                //                }
                //                else if([curHoleName isEqualToString:@"下九洞"])
                //                {
                //                    ucHolePosition = 1;
                //                }
                //                else if([curHoleName isEqualToString:@"十八洞"])
                //                {
                //                    ucHolePosition = 2;
                //                }
                
                
                if(recDic[@"Msg"][@"group"][@"grocod"] != nil)
                {
                    NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                    //将数据加载到创建的数据库中
                    [strongSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                    //组建获取到的组信息的数组
                    NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"groind"],recDic[@"Msg"][@"group"][@"grolev"],recDic[@"Msg"][@"group"][@"gronum"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"hgcod"],recDic[@"Msg"][@"group"][@"onlinestatus"], nil];
                    //将数据加载到创建的数据库中
                    //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                    [strongSelf.dbCon ExecNonQuery:@"insert into  tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus)values(?,?,?,?,?,?,?)" forParameter:groupInfArray];
                    //
                    DataTable *table = [[DataTable alloc] init];
                    
                    table = [strongSelf.dbCon ExecDataTable:@"select *from tbl_groupInf"];
                    NSLog(@"table:%@",table);
                    //
                    HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                    [HeartBeatAndDetectState disableHeartBeat];//disable heartBeat
                    if(![heartBeat checkState])
                    {
                        [heartBeat initHeartBeat];//启动心跳服务
                    }
                    strongSelf.haveGroupNotDown = YES;
                    //获取到球洞信息，并将相应的信息保存到内存中
                    NSArray *allHolesInfo = recDic[@"Msg"][@"holes"];
                    for (NSDictionary *eachHole in allHolesInfo) {
                        NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                        [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
                    }
                    //
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf getCaddyCartInf];
                        [weakSelf getCustomInf];
                    });
                    
                }
                
            }
        }
        
    }failure:^(NSError *err){
        NSLog(@"request failled");
        
        
    }];
}


#pragma -mark logInButton
- (IBAction)logInButton:(UIButton *)sender {
    //登录时判断当前的状态
#ifdef testChangeInterface
    [self performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
#else
    [self checkCurStateOnServer];
#endif
}




@end
