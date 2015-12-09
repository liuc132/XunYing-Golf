//
//  SettingViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/8.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "SettingViewController.h"
#import "settingTableViewCell.h"

@implementation SettingViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"enter SettingViewController");
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            NSLog(@"selected row0");
            break;
            
        case 1:
            NSLog(@"selected row1");
            
            break;

        case 2:
            NSLog(@"selected row2");
            
            break;

        case 3:
            NSLog(@"selected row3");
            
            break;
        default:
            break;
    }
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *cellIdentifier;
    
    //= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GetPosition"];
    switch (indexPath.row) {
        case 0:
            cellIdentifier = @"settingCell0";
            
            break;
            
        case 1:
            cellIdentifier = @"settingCell1";
            
            break;

        case 2:
            cellIdentifier = @"settingCell2";
            
            break;

        case 3:
            cellIdentifier = @"settingCell3";
            
            break;
        default:
            break;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc]
              initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIdentifier];
    }
    
    
    return cell;
}





- (IBAction)confirmSetting:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (IBAction)back:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
