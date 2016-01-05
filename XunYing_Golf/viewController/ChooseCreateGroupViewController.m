//
//  ChooseCreateGroupViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/18.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "ChooseCreateGroupViewController.h"
#import "UIColor+UICon.h"
#import "HttpTools.h"
#import "DataTable.h"
#import "DBCon.h"
#import "XunYingPre.h"
#import "HeartBeatAndDetectState.h"
#import "AppDelegate.h"
#import "QRCodeReaderViewController.h"
#import "ActivityIndicatorView.h"
#import "WaitToPlayTableViewController.h"
#import "GetRequestIPAddress.h"

extern unsigned char ucCusCounts;
extern unsigned char ucHolePosition;


@interface ChooseCreateGroupViewController ()<QRCodeReaderDelegate>


@property (strong, nonatomic) DBCon *LogDbcon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *inputlogCaddy;
@property (strong, nonatomic) DataTable *logEmp;
@property (strong, nonatomic) DataTable *cusNumbers;
@property (strong, nonatomic) NSMutableDictionary *checkCreatGroupState;

@property (strong, nonatomic) NSDictionary *loggedPersonInf;
@property BOOL backOrNext;  //yes:next   no:back default we go to the next interface

@property (strong, nonatomic) QRCodeReaderViewController *QRCodeReader;
@property (strong, nonatomic) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic)         NSInteger cusCount;
@property (nonatomic)         BOOL      QRCodeWay;
@property (strong, nonatomic) NSArray   *QRcusCard;

- (IBAction)backToLogInFace:(UIBarButtonItem *)sender;
- (IBAction)MannualCreateGrp:(UIButton *)sender;
- (IBAction)QRCodeCreateGrp:(UIButton *)sender;



@end

@implementation ChooseCreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.LogDbcon   = [[DBCon alloc] init];
    self.logPerson  = [[DataTable alloc] init];
    self.logEmp     = [[DataTable alloc] init];
    self.cusNumbers = [[DataTable alloc] init];
    self.inputlogCaddy = [[DataTable alloc] init];
    //
    self.QRCodeWay  = NO;
    //
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBarBack.png"] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor HexString:@"454545"];
    
    self.backOrNext = YES;
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whereToGo:) name:@"whereToGo" object:nil];
    //
    self.QRCodeReader = [[QRCodeReaderViewController alloc] initWithCancelButtonTitle:@"取消"];
    self.QRCodeReader.modalPresentationStyle = UIModalPresentationFormSheet;
//    self.QRCodeReader = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消"];
    self.QRCodeReader.delegate = self;
    //
    //init activityIndicatorView
    self.activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.activityIndicatorView.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.activityIndicatorView.layer.cornerRadius = 20;
    //先隐藏，同时停止动画
    [self.activityIndicatorView hideIndicator];
    
    
}
#pragma -mark where interface to go
-(void)whereToGo:(NSNotification *)sender
{
    NSLog(@"enter where to go");
    //when get the notification ,then remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //decide which interface to go according to the sender whoes object is NSNotification
    if ([sender.userInfo[@"allowDown"] isEqualToString:@"1"]) {
//        [self.activityIndicatorView stopAnimating];
//        self.activityIndicatorView.hidden = YES;
        //执行跳转程序，此时判断的是已经创建了组
        [self performSegueWithIdentifier:@"ToMainMapView1" sender:nil];
    }
    else if([sender.userInfo[@"waitToAllow"] isEqualToString:@"1"])
    {
//        [self.activityIndicatorView stopAnimating];
//        self.activityIndicatorView.hidden = YES;
        [self performSegueWithIdentifier:@"shouldWaitToAllow1" sender:nil];
    }
    else
    {
//        [self performSegueWithIdentifier:@"mannualCreatGrp" sender:nil];
    }
    
}

#pragma -mark navBack
-(void)navBack
{
    NSLog(@"enter navBack");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.logPerson = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
    self.logEmp    = [self.LogDbcon ExecDataTable:@"select *from tbl_logPerson"];
    self.inputlogCaddy = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    //
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self.logPerson.Rows count] && !self.backOrNext) {
//            NSMutableArray *reConstructLogPersonInf = [[NSMutableArray alloc] initWithObjects:self.loggedPersonInf[@"user"],self.loggedPersonInf[@"password"],@"0", nil];
//            //[self.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
//            [self.LogDbcon ExecNonQuery:@"INSERT INTO tbl_NamePassword(user,password,logOutOrNot) VALUES(?,?,?)" forParameter:reConstructLogPersonInf];
//        }
//        NSLog(@"did disappear");
//
//        self.logPerson = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
//        NSLog(@"finish and logPerson:%@",self.logPerson);
//        
//    });
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToLogInFace:(UIBarButtonItem *)sender {
    
    
    self.backOrNext = NO;
    //
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.logPerson = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
//        if ([self.logPerson.Rows count]) {
//            self.loggedPersonInf = [[NSDictionary alloc] initWithObjectsAndKeys:self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"user"],@"user",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"password"],@"password", nil];
//            [self.LogDbcon ExecNonQuery:@"delete from tbl_NamePassword"];
//        }
//        NSLog(@"backToLogIn");
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //[self dismissViewControllerAnimated:YES completion:nil];
//            [self performSegueWithIdentifier:@"backToLogInSegue" sender:nil];
//        });
//        
//    });
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"backToLogInSegue" sender:nil];
    });
}

- (IBAction)MannualCreateGrp:(UIButton *)sender {
    NSLog(@"enter mannualCreateGrp");
    self.backOrNext = YES;
    //check current state
    self.checkCreatGroupState = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"user"],@"username",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"password"],@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
    //
    __weak ChooseCreateGroupViewController *weakSelf = self;
    //
    NSString *downFieldURLStr;
    downFieldURLStr = [GetRequestIPAddress getDecideCreateGrpAndDownFieldURL];
    
    //request
    [HttpTools getHttp:downFieldURLStr forParams:self.checkCreatGroupState success:^(NSData *nsData){
        //
        ChooseCreateGroupViewController *strongSelf = weakSelf;
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
            [self.LogDbcon ExecDataTable:@"delete from tbl_groupInf"];
            [self.LogDbcon ExecDataTable:@"delete from tbl_holeInf"];
            //
            NSArray *holeInf = [[NSArray alloc]initWithObjects:@"forecasttime",@"gronum",@"holcod",@"holcue",@"holfla",@"holgro",@"holind",@"hollen",@"holnam",@"holnum",@"holspe",@"holsta",@"nowgroups",@"stan1",@"stan2",@"stan3",@"stan4",@"usestatus",@"x",@"y", nil];
            NSMutableArray *holesInf = [[NSMutableArray alloc] init];
            NSLog(@"count:%ld",[recDic[@"Msg"][@"holes"] count]);
            NSArray *holesArray = recDic[@"Msg"][@"holes"];
            
            //            NSDictionary *holeDic = [[NSDictionary alloc] init];
            
            NSMutableArray *mutableHolesArray = [[NSMutableArray alloc] init];
            for (unsigned char i = 0; i < [holesArray count]; i++) {
                [mutableHolesArray addObject:holesArray[i]];
            }
            //
            for(unsigned int j = 0; j < [mutableHolesArray count];j++)
            {
                NSMutableArray *eachHoleInf = [[NSMutableArray alloc] init];//[[NSMutableArray alloc]initWithObjects:@"", nil];
                for(unsigned int i = 0; i < [holeInf count];i++)
                {
                    [eachHoleInf addObject:mutableHolesArray[j][holeInf[i]]];
                    //                        NSLog(@"out %@:%@",holeInf[i],eachHoleInf[i]);
                }
                //将数据加载到创建的数据库中
                [strongSelf.LogDbcon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInf];
                
                [holesInf addObject:eachHoleInf];
            }
            //
//            DataTable *table;// = [[DataTable alloc] init];
//            table = [strongSelf.LogDbcon ExecDataTable:@"select *from tbl_holeInf"];
            //
//            NSString *groupValue = [recDic[@"Msg"] objectForKey:@"group"];
//            if([(NSNull *)groupValue isEqual: @"null"])//
//            {
//                //[strongSelf performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
//                [str logIn];
//            }
//            else//
            {
                //                ucCusCounts = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                //                NSString *curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
                //此处的数据还没有传递到需要的地方去
//                self.customerCount = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
//                self.curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
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
                
//                if(recDic[@"Msg"][@"group"])
                if([recDic[@"Msg"][@"group"] isEmpty])
                {
                    NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                    //将数据加载到创建的数据库中
                    [strongSelf.LogDbcon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                    //组建获取到的组信息的数组
                    NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"groind"],recDic[@"Msg"][@"group"][@"grolev"],recDic[@"Msg"][@"group"][@"gronum"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"hgcod"],recDic[@"Msg"][@"group"][@"onlinestatus"], nil];
                    //将数据加载到创建的数据库中
                    //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                    [strongSelf.LogDbcon ExecNonQuery:@"insert into  tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus)values(?,?,?,?,?,?,?)" forParameter:groupInfArray];
                    //
//                    DataTable *table = [[DataTable alloc] init];
//                    
//                    table = [strongSelf.LogDbcon ExecDataTable:@"select *from tbl_groupInf"];
//                    NSLog(@"table:%@",table);
                    //
                    HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                    [HeartBeatAndDetectState disableHeartBeat];//disable heartBeat
                    if(![heartBeat checkState])
                    {
                        [heartBeat initHeartBeat];//启动心跳服务
                    }
//                    strongSelf.haveGroupNotDown = YES;
                    
                }
                else
                {
                    [self performSegueWithIdentifier:@"mannualCreatGrp" sender:nil];
                }
                
            }
        }
        
    }failure:^(NSError *err){
        NSLog(@"request failled");
        
        
    }];
    
}

- (IBAction)QRCodeCreateGrp:(UIButton *)sender {
    NSLog(@"开始扫描二维码");
    __weak typeof(self) weakSelf = self;
    //tbl_CustomerNumbers
    self.cusNumbers = [self.LogDbcon ExecDataTable:@"select *from tbl_CustomerNumbers"];
    //
    [self.QRCodeReader setCompletionWithBlock:^(NSString *resultAsString){
        NSLog(@"result:%@",resultAsString);
        [weakSelf.QRCodeReader dismissViewControllerAnimated:YES completion:nil];
        //定义球车，球童，消费卡号的字符数组
        NSString *cusCards = [[NSString alloc] init];
        NSString *caddies  = [[NSString alloc] init];
        NSString *carts    = [[NSString alloc] init];
        //将获取到的参数给拆分出来 第一个元素为组编号，第二个元素为组类别（151211确认目前都选择为all），第三个元素为消费卡号，球童，球车的信息，具体见相应的说明文档“上邦高尔夫原有系统与巡鹰球场调度系统数据对接”
        NSArray *QRCodeReadResult = [resultAsString componentsSeparatedByString:@";"];//拆分接收到的数据
        //拆分到消费卡号，球童，球车信息出来(可能是多个组合的信息)
        NSString *cusCadCartsStr = [NSString stringWithFormat:@"%@",QRCodeReadResult[2]];
        NSArray *allCadCartsArray = [cusCadCartsStr componentsSeparatedByString:@"&"];
        for (NSString *eachCadCart in allCadCartsArray) {
            
            NSLog(@"eacgCadCart:%@",eachCadCart);
            NSArray *separateParam = [eachCadCart componentsSeparatedByString:@"_"];
            NSLog(@"separateParam:%@ intValue:%d cuscardsBool:%d",separateParam,[separateParam[0] intValue],[cusCards isEqualToString:@""]);
            cusCards = [cusCards stringByAppendingString:([cusCards isEqualToString:@""] && ([separateParam[0] intValue] != -1))?separateParam[0]:[NSString stringWithFormat:@"_%@",separateParam[0]]];
            caddies = [caddies stringByAppendingString:([caddies isEqualToString:@""] && ([separateParam[1] intValue] != -1))?separateParam[1]:[NSString stringWithFormat:@"_%@",separateParam[1]]];
            carts = [carts stringByAppendingString:([carts isEqualToString:@""] && ([separateParam[2] intValue] != -1))?separateParam[2]:[NSString stringWithFormat:@"_%@",separateParam[2]]];
        }
        NSArray *caddiesArray = [caddies componentsSeparatedByString:@"_"];
        BOOL hasTheLogCaddy;
        hasTheLogCaddy = NO;
        NSString *logCaddyNum;
        logCaddyNum = [NSString stringWithFormat:@"%@",self.inputlogCaddy.Rows[0][@"user"]];
        //
        for (NSString *eachCaddy in caddiesArray) {
            if ([eachCaddy isEqualToString:logCaddyNum]) {
                hasTheLogCaddy = YES;
            }
        }
        if (!hasTheLogCaddy) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该组中无此球童" message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
//        NSLog(@"%@",QRCodeReadResult);
//        NSLog(@"%@  %@  %@",QRCodeReadResult[0],QRCodeReadResult[1],QRCodeReadResult[2]);
//        NSLog(@"cusCards:%@ caddies:%@ carts:%@",cusCards,caddies,carts);
        //二维码扫描得到的所有消费卡号
        NSArray *allCusCards = [cusCards componentsSeparatedByString:@"_"];
        weakSelf.QRcusCard = [[NSArray alloc] initWithArray:allCusCards];
        
        
        NSMutableArray *allCuscards = [[NSMutableArray alloc] initWithObjects:allCusCards, nil];
        NSLog(@"allcuscards:%@",allCuscards);
//        [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_CustomerNumbers(first,second,third,fourth) values(?,?,?,?)" forParameter:allCuscards];
//        DataTable *table = [[DataTable alloc] init];
//        table = [weakSelf.LogDbcon ExecDataTable:@"select *from tbl_CustomerNumbers"];
        
        weakSelf.cusCount = [allCusCards count];
        weakSelf.QRCodeWay = YES;
        //组装请求的数据
        NSMutableDictionary *createGrpParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",QRCodeReadResult[0],@"gronum",cusCards,@"cus",@"all",@"hole",caddies,@"cad",carts,@"car",weakSelf.logEmp.Rows[[weakSelf.logEmp.Rows count] - 1][@"number"],@"cadShow",weakSelf.logEmp.Rows[[weakSelf.logEmp.Rows count] - 1][@"code"],@"user", nil];
        //
        NSString *createGrpURLStr;
        createGrpURLStr = [GetRequestIPAddress getcreateGroupURL];
        //请求接口（建组下场的接口），并进行相应的跳转
        [HttpTools getHttp:createGrpURLStr forParams:createGrpParam success:^(NSData *nsData){
            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"recDic:%@",recDic);
            //
            if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
            {
                NSLog(@"程序异常");
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:0]])
            {
                NSLog(@"建组失败");
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
            {
                NSLog(@"已有球组，建组失败");
            }
            else
            {
                [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_taskInfo"];
                [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_CustomersInfo"];
                [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_selectCart"];
                [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_groupInf"];
                [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_addCaddy"];
                //
                NSLog(@"grpcod:%@  ;groind:%@  ;grolev:%@  ;gronum:%@  ;grosta:%@",recDic[@"Msg"][@"grocod"],recDic[@"Msg"][@"groind"],recDic[@"Msg"][@"grolev"],recDic[@"Msg"][@"gronum"],recDic[@"Msg"][@"grosta"]);
                //组建获取到的组信息的数组
                NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"grocod"],recDic[@"Msg"][@"groind"],recDic[@"Msg"][@"grolev"],recDic[@"Msg"][@"gronum"],recDic[@"Msg"][@"grosta"],recDic[@"Msg"][@"hgcod"],recDic[@"Msg"][@"onlinestatus"], nil];
                //将数据加载到创建的数据库中
                //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                
                [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus)values(?,?,?,?,?,?,?)" forParameter:groupInfArray];
                
                NSLog(@"successfully create group and the recDic:%@  code:%@",recDic[@"Msg"],recDic[@"code"]);
                //获取到登录小组的所有客户的信息
                NSArray *allCustomers = recDic[@"Msg"][@"cuss"];
                for (NSDictionary *eachCus in allCustomers) {
                    NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                    [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                }
                //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                NSArray *allSelectedCartsArray = recDic[@"Msg"][@"cars"];
                for (NSDictionary *eachCart in allSelectedCartsArray) {
                    NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                    [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                }
                //
                //保存添加的球童的信息 tbl_addCaddy(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
                NSArray *allSelectedCaddiesArray = recDic[@"Msg"][@"cads"];
                for (NSDictionary *eachCaddy in allSelectedCaddiesArray) {
                    NSMutableArray *selectedCaddy = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
                    [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_addCaddy(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:selectedCaddy];
                }
//                DataTable *table11;// = [[DataTable alloc] init];
//                table11 = [weakSelf.LogDbcon ExecDataTable:@"select *from tbl_selectCart"];
                //建组成功之后，进入心跳处理类中，开始心跳功能
                HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                if (![heartBeat checkState]) {
                    [heartBeat initHeartBeat];//1、开启心跳功能
                }
                //跳转页面
                [weakSelf performSegueWithIdentifier:@"QRCodeToWait" sender:nil];
                //执行通知
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *QRCodeNotice = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)weakSelf.cusCount],@"customerCount",@"十八洞",@"holetype", nil];
                    NSLog(@"%@",QRCodeNotice);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"QRCodeResult" object:nil userInfo:QRCodeNotice];
                });
                
            }
            
        }failure:^(NSError *err){
            NSLog(@"request failed");
            
        }];
    }];
    //
    [self presentViewController:self.QRCodeReader animated:YES completion:nil];
}
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WaitToPlayTableViewController *waitToPlay = segue.destinationViewController;
    //
    if (self.QRCodeWay) {
        self.QRCodeWay = NO;
        waitToPlay.holeType = @"十八洞";
        waitToPlay.customerCounts = self.cusCount;
        waitToPlay.QRCodeEnable = YES;
        waitToPlay.cusCardArray = self.QRcusCard;
    }
    
}


@end
