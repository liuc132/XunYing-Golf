//
//  ChangeCartViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/24.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "ChangeCartViewController.h"
#import "XunYingPre.h"
#import "HttpTools.h"
#import "DBCon.h"
#import "DataTable.h"
#import "UIColor+UICon.h"

typedef enum ChangeReason{
    LowPowerRequest = 11,
    CartBadRequest,
    OtherReason = 99
}changeReasonEnum;

#define reasonSelectColor           @"0197d6"
#define reasonUnselectWordColor     @"999999"

@interface ChangeCartViewController ()


@property (strong, nonatomic) DBCon *lcDBCon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *groupInfo;
@property (strong, nonatomic) DataTable *cartInfo;
@property (strong, nonatomic) NSString  *changeReasonStr;
@property (strong, nonatomic) NSDictionary *eventInfoDic;


@property (strong, nonatomic) IBOutlet UIView *firstChangeCartView;
@property (strong, nonatomic) IBOutlet UIImageView *firstChangeCartImage;
@property (strong, nonatomic) IBOutlet UILabel *firstChangeCartInfo;
@property (strong, nonatomic) IBOutlet UIView *secondChangeCartView;
@property (strong, nonatomic) IBOutlet UIImageView *secondChangeCartImage;
@property (strong, nonatomic) IBOutlet UILabel *secondChangeCartInfo;

@property (strong, nonatomic) IBOutlet UIButton *changeLowPower;
@property (strong, nonatomic) IBOutlet UIButton *changeBad;
@property (strong, nonatomic) IBOutlet UIButton *changeOther;

- (IBAction)dismissCurView:(UIBarButtonItem *)sender;
- (IBAction)requestToServer:(UIButton *)sender;
- (IBAction)changeCartReason:(UIButton *)sender;



@end

@implementation ChangeCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init
    self.lcDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.cartInfo  = [[DataTable alloc] init];
    self.groupInfo = [[DataTable alloc] init];
    //
    self.changeReasonStr = [NSString stringWithFormat:@"%d",LowPowerRequest];
    //init a notificationcenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"changeCart" object:nil];
    
}

- (void)getEventFromHeart:(NSNotification *)sender
{
    self.eventInfoDic = sender.userInfo;
    NSLog(@"ChangeCart info:%@ and eventInfoDic:%@",sender.userInfo,self.eventInfoDic);
    [self.view removeFromSuperview];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    __weak typeof(self) weakSelf = self;
    //read the data from the memory
    self.logPerson = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.cartInfo  = [self.lcDBCon ExecDataTable:@"select *from tbl_cartInf"];
    self.groupInfo = [self.lcDBCon ExecDataTable:@"select *from tbl_groupInf"];
    //为了显示方便，将前两个球车的信息显示出来
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.cartInfo.Rows count]) {
            weakSelf.firstChangeCartInfo.text = [NSString stringWithFormat:@"%@ %@座",weakSelf.cartInfo.Rows[0][@"carnum"],weakSelf.cartInfo.Rows[0][@"carsea"]];//
            weakSelf.secondChangeCartInfo.text = [NSString stringWithFormat:@"%@ %@座",weakSelf.cartInfo.Rows[1][@"carnum"],weakSelf.cartInfo.Rows[1][@"carsea"]];
            //
            
        }
        
        
        
    });
    
    
    
    
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

- (IBAction)dismissCurView:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)requestToServer:(UIButton *)sender {
    NSLog(@"enter request to the server");
    __weak typeof(self) weakSelf = self;
    //construct parameters
    //先判断参数是否为空，为空则退出并弹出异常提示
    if (![self.logPerson.Rows count] || ![self.cartInfo.Rows count] || ![self.groupInfo.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //获取到当前移动设备的时间
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *curDeviceDate = [dataFormatter stringFromDate:[NSDate date]];
    
    NSMutableDictionary *changeCartParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.groupInfo.Rows[0][@"grocod"],@"grocod",self.logPerson.Rows[0][@"code"],@"empcod",self.changeReasonStr,@"reason",self.cartInfo.Rows[0][@"carcod"],@"carcod",curDeviceDate,@"subtim", nil];
    
    //request
    [HttpTools getHttp:ChangeCartURL forParams:changeCartParam success:^(NSData *nsData){
        NSLog(@"have request successfully");
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"recDic:%@",recDic);
        //
//        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
    }failure:^(NSError *err){
        NSLog(@"request failled and err:%@",err);
        
        
    }];
    
    
}

- (IBAction)changeCartReason:(UIButton *)sender {
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
                weakSelf.changeLowPower.backgroundColor = [UIColor HexString:reasonSelectColor];
                weakSelf.changeLowPower.titleLabel.textColor = [UIColor whiteColor];
            });
            
            if([changeReasonArray count] < 4)
                [changeReasonArray addObject:[NSString stringWithFormat:@"%d",LowPowerRequest]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.changeLowPower.backgroundColor = [UIColor whiteColor];
                weakSelf.changeLowPower.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
            });
            
            
            for (NSString *otherRea in changeReasonArray) {
                if ([otherRea intValue] == LowPowerRequest) {
                    [changeReasonArray removeObject:[NSString stringWithFormat:@"%d",LowPowerRequest]];
                }
            }
        }
        //second
        if (secondReason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.changeBad.backgroundColor = [UIColor HexString:reasonSelectColor];
                weakSelf.changeBad.titleLabel.textColor = [UIColor whiteColor];
            });
            
            if([changeReasonArray count] < 4)
                [changeReasonArray addObject:[NSString stringWithFormat:@"%d",CartBadRequest]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.changeBad.backgroundColor = [UIColor whiteColor];
                weakSelf.changeBad.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
            });
            
            for (NSString *otherRea in changeReasonArray) {
                if ([otherRea intValue] == CartBadRequest) {
                    [changeReasonArray removeObject:[NSString stringWithFormat:@"%d",CartBadRequest]];
                }
            }
        }
        //third
        if (thirdReason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.changeOther.backgroundColor = [UIColor HexString:reasonSelectColor];
                weakSelf.changeOther.titleLabel.textColor = [UIColor whiteColor];
            });
            
            if([changeReasonArray count] < 4)
                [changeReasonArray addObject:[NSString stringWithFormat:@"%d",OtherReason]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.changeOther.backgroundColor = [UIColor whiteColor];
                weakSelf.changeOther.titleLabel.textColor = [UIColor HexString:reasonUnselectWordColor];
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
@end
