//
//  SettingViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 16/1/4.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputHeartIntervalTime;
@property (strong, nonatomic) IBOutlet UITextField *inputIPAddress;
@property (strong, nonatomic) IBOutlet UITextField *inputPortNum;

- (IBAction)confirmSetting:(UIButton *)sender;
- (IBAction)backToLogInView:(UIBarButtonItem *)sender;


@property (strong, nonatomic) UITapGestureRecognizer *tapDismiss;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tapDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInput:)];
    self.tapDismiss.delegate = self;
    [self.view addGestureRecognizer:self.tapDismiss];
}

- (void)dismissInput:(id)sender
{
    [self.inputHeartIntervalTime resignFirstResponder];
    [self.inputIPAddress resignFirstResponder];
    [self.inputPortNum resignFirstResponder];
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

- (IBAction)confirmSetting:(UIButton *)sender {
    NSLog(@"enter confirm setting and store");
    
    [self.inputHeartIntervalTime resignFirstResponder];
    [self.inputIPAddress resignFirstResponder];
    [self.inputPortNum resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"intervalTime:%@ IP:%@ PortNum:%@",self.inputHeartIntervalTime.text,self.inputIPAddress.text,self.inputPortNum.text);
}
- (IBAction)backToLogInView:(UIBarButtonItem *)sender {
    [self.inputHeartIntervalTime resignFirstResponder];
    [self.inputIPAddress resignFirstResponder];
    [self.inputPortNum resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
