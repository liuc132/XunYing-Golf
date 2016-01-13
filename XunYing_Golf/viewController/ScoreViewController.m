//
//  ScoreViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/25.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "ScoreViewController.h"

@interface ScoreViewController ()


@property (strong, nonatomic) IBOutlet UILabel *startInfDis;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)saveScore:(UIBarButtonItem *)sender;
- (IBAction)backToPersonalList:(UIBarButtonItem *)sender;


@end

@implementation ScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    
}

- (void)ForceBackField:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *serverForceBackAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的小组已回场" delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [serverForceBackAlert show];
            
            [weakSelf performSegueWithIdentifier:@"serVerBackField" sender:nil];
        });
        
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (IBAction)saveScore:(UIBarButtonItem *)sender {
    NSLog(@"save the score");
    //将成绩保存到本地
    
}

- (IBAction)backToPersonalList:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
