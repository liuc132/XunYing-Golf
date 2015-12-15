//
//  TaskComViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/11.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "TaskComViewController.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"
#import "CellFrameModel.h"

//职员在系统中的状态
typedef enum empStatus{
    empOffline,
    empOnline
}empStatus;
//职位类别
typedef enum jobType{
    allJob,         //全部岗位
    manager,        //管理员
    dispatch,       //调度
    tourField,      //巡场
    caddy,          //球童
    reception,      //前台
    restaurant      //餐厅
}jobType;



@interface TaskComViewController ()
{
    NSArray *_employeesData;
}


@property (strong, nonatomic) DBCon *comDbCon;
@property (strong, nonatomic) DataTable *empInfo;
//从数据库中读取数据，相应的数据组装在一个dictionary中
@property (strong, nonatomic) NSMutableArray *employeesArray;


//
@property (strong, nonatomic) IBOutlet UISegmentedControl *msgDisWay;

//
- (IBAction)msgDisWays:(UISegmentedControl *)sender;



@end




@implementation TaskComViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    __weak typeof(self) weakSelf = self;
    //
    self.allEmpCommunicate.dataSource = self;
    self.allEmpCommunicate.delegate   = self;
    //初始化
    self.comDbCon = [[DBCon alloc] init];
    self.empInfo  = [[DataTable alloc] init];
    self.employeesArray = [[NSMutableArray alloc] init];
    //
    //dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.empInfo = [weakSelf.comDbCon ExecDataTable:@"select *from tbl_EmployeeInf"];
        NSLog(@"empInfo:%@",weakSelf.empInfo.Rows);
        //
        if ([weakSelf.empInfo.Rows count]) {
            NSArray *allempsInfo = weakSelf.empInfo.Rows;
            for (NSDictionary *eachEmp in allempsInfo) {
                //包含friends（array），name（string），online（number）
                NSDictionary *eachItemEmp = [[NSDictionary alloc] init];
                //这里还要分各个职位进行参数的添加 所有职位，管理员，巡场
                NSMutableArray *partInfoEmp = [[NSMutableArray alloc] init];
                //再次查询一次以便将friends给生成
                for (NSDictionary *eachEmp1 in allempsInfo) {
                    NSString *iconStr = [[NSString alloc] init];
                    iconStr = [NSString stringWithFormat:@"%@",([eachEmp1[@"online"] boolValue]?@"online":@"offline")];
                    
                    NSDictionary *eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp1[@"empnum"],@"intro",eachEmp1[@"empnam"],@"name",@"0",@"vip", nil];
                    [partInfoEmp addObject:eachEmpPartInfo];
                }
                //
                NSString *sectionName = [[NSString alloc] init];
                switch ([eachEmp[@"empjob"] intValue]) {
                    case allJob:
                        sectionName = @"所有岗位";
                        break;
                    case manager:
                        sectionName = @"管理员";
                        break;
                    case dispatch:
                        sectionName = @"调度";
                        break;
                    case tourField:
                        sectionName = @"巡场";
                        break;
                    case reception:
                        sectionName = @"前台";
                        break;
                    case restaurant:
                        sectionName = @"餐厅";
                        break;
                        
                    default:
                        break;
                }
                //
                eachItemEmp = [[NSDictionary alloc] initWithObjectsAndKeys:partInfoEmp,@"friends",sectionName,@"name",eachEmp[@"online"],@"online", nil];
                //
                [weakSelf.employeesArray addObject:eachItemEmp];
            }
            NSLog(@"all emps:%@",weakSelf.employeesArray);
            
        }
        
    //});
    
    
    
    
    //load data
    
    
}





#pragma -mark numberOfRowsInSection
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    return cell;
}

- (IBAction)msgDisWays:(UISegmentedControl *)sender {
    
    
    
}
@end
