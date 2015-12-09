//
//  SettingViewController.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/8.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UITableViewController

- (IBAction)confirmSetting:(id)sender;
@property (strong, nonatomic) IBOutlet UINavigationItem *setNavigationItem;

- (IBAction)back:(UIBarButtonItem *)sender;

@end
