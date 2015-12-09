//
//  settingTableViewCell.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/8.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *getGPSWay;

@property (strong, nonatomic) IBOutlet UILabel *settingInternalTime;
@property (strong, nonatomic) IBOutlet UITextField *inputInternalTime;

@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UITextField *inputAddress;

@property (strong, nonatomic) IBOutlet UILabel *portNumber;
@property (strong, nonatomic) IBOutlet UITextField *inputPortNumber;





@end
