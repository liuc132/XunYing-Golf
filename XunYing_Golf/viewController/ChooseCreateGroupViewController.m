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

extern unsigned char ucCusCounts;
extern unsigned char ucHolePosition;


@interface ChooseCreateGroupViewController ()<QRCodeReaderDelegate>


@property (strong, nonatomic) DBCon *LogDbcon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) NSMutableDictionary *checkCreatGroupState;

@property (strong, nonatomic) NSDictionary *loggedPersonInf;
@property BOOL backOrNext;  //yes:next   no:back default we go to the next interface

@property (strong, nonatomic) QRCodeReaderViewController *QRCodeReader;
//@property (strong, nonatomic) 


- (IBAction)backToLogInFace:(UIBarButtonItem *)sender;
- (IBAction)MannualCreateGrp:(UIButton *)sender;
- (IBAction)QRCodeCreateGrp:(UIButton *)sender;



@end

@implementation ChooseCreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.LogDbcon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    //
    [AppDelegate storyBoardAutoLay:self.view];
    //
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBarBack.png"] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor HexString:@"454545"];
    
    self.backOrNext = YES;
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whereToGo:) name:@"whereToGo" object:nil];
    //
    self.QRCodeReader = [[QRCodeReaderViewController alloc] init];
    self.QRCodeReader.modalPresentationStyle = UIModalPresentationFormSheet;
    self.QRCodeReader.delegate = self;
    
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
        [self performSegueWithIdentifier:@"mannualCreatGrp" sender:nil];
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
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.logPerson.Rows count] && !self.backOrNext) {
            NSMutableArray *reConstructLogPersonInf = [[NSMutableArray alloc] initWithObjects:self.loggedPersonInf[@"user"],self.loggedPersonInf[@"password"],@"0", nil];
            //[self.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
            [self.LogDbcon ExecNonQuery:@"INSERT INTO tbl_NamePassword(user,password,logOutOrNot) VALUES(?,?,?)" forParameter:reConstructLogPersonInf];
        }
        NSLog(@"did disappear");

        self.logPerson = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
        NSLog(@"finish and logPerson:%@",self.logPerson);
        
    });
    
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logPerson = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
        if ([self.logPerson.Rows count]) {
            self.loggedPersonInf = [[NSDictionary alloc] initWithObjectsAndKeys:self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"user"],@"user",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"password"],@"password", nil];
            [self.LogDbcon ExecNonQuery:@"delete from tbl_NamePassword"];
        }
        NSLog(@"backToLogIn");
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)MannualCreateGrp:(UIButton *)sender {
    NSLog(@"enter mannualCreateGrp");
    self.backOrNext = YES;
    //check current state
    self.checkCreatGroupState = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"user"],@"username",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"password"],@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
    //
    __weak ChooseCreateGroupViewController *weakSelf = self;
    //request
    [HttpTools getHttp:DecideCreateGrpAndDownField forParams:self.checkCreatGroupState success:^(NSData *nsData){
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
            DataTable *table = [[DataTable alloc] init];
            table = [strongSelf.LogDbcon ExecDataTable:@"select *from tbl_holeInf"];
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
                    DataTable *table = [[DataTable alloc] init];
                    
                    table = [strongSelf.LogDbcon ExecDataTable:@"select *from tbl_groupInf"];
                    NSLog(@"table:%@",table);
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

    [self.QRCodeReader setCompletionWithBlock:^(NSString *resultAsString){
        [weakSelf.QRCodeReader dismissViewControllerAnimated:YES completion:nil];
    }];
    //
    [self presentViewController:self.QRCodeReader animated:YES completion:nil];
}
#pragma -mark QRCodeReader
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    NSLog(@"getResult:%@",result);
}


@end
