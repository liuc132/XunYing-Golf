//
//  LeaveRestViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/24.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "LeaveRestViewController.h"
#import "CurTaskCenterTableViewController.h"
#import "DataTable.h"
#import "DBCon.h"

@interface LeaveRestViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSArray *hourString;
    NSArray *minString;
    NSString *separateString;
}


@property (strong, nonatomic) DBCon *lcDBCon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) NSDictionary *eventInfoDic;


@property (strong, nonatomic) IBOutlet UILabel *requestPerson;
@property (strong, nonatomic) IBOutlet UILabel *currentHole;
@property (strong, nonatomic) IBOutlet UIPickerView *selectTime;



- (IBAction)recoverTimeComfirm:(UIButton *)sender;
- (IBAction)backToMain:(UIBarButtonItem *)sender;

@end

@implementation LeaveRestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectTime.delegate = self;
    //
    //
    self.lcDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    //
    hourString = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
    minString = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"];
    separateString = @":";
    //查询申请人的信息
    self.logPerson = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    //init a notificationcenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"leaveToRest" object:nil];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    if ([self.logPerson.Rows count]) {
        self.requestPerson.text = [NSString stringWithFormat:@"%@ %@",self.logPerson.Rows[0][@"number"],self.logPerson.Rows[0][@"name"]];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CurTaskCenterTableViewController *curTaskMainView = segue.destinationViewController;
    curTaskMainView.leaveTime = @"2015-10-9 15:12:40";
}


- (IBAction)recoverTimeComfirm:(UIButton *)sender {
    
}

- (IBAction)backToMain:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger _row;
    
    switch (component) {
        case 0:
            _row = [hourString count];
            break;
            
        case 1:
            _row = 1;
            break;
            
        case 2:
            _row = [minString count];
            break;
        default:
            break;
    }
    
    return _row;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    NSLog(@"curselect:",)
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnSting;
    switch (component) {
        case 0:
            returnSting = [hourString objectAtIndex:row];
            break;
        case 1:
            returnSting = separateString;
            break;
        case 2:
            returnSting = [minString objectAtIndex:row];
            break;
        default:
            break;
    }
    //
    return returnSting;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 40.0;
}

@end
