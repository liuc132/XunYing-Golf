//
//  WaitToPlayTableViewController.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "passValueLogInDelegate.h"

@interface WaitToPlayTableViewController : UITableViewController

@property (nonatomic) NSString* holeType;
@property (nonatomic) NSInteger customerCounts;


@property (strong, nonatomic) id<passValueLogInDelegate> passDelegate;

@end
