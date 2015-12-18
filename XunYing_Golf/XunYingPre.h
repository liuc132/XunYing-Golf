//
//  XunYingPre.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/7.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#ifndef XunYing_Golf_XunYingPre_h
#define XunYing_Golf_XunYingPre_h

#define ScreenWidth [[UIScreen mainScreen]bounds].size.width
#define ScreenHeight [[UIScreen mainScreen]bounds].size.height

/*
 http://192.168.1.66:8111   --朱小康电脑的服务@"http://192.168.1.66"  @":8111"
 http://192.168.1.119:8081  --公司的服务器@"http://192.168.1.119"  @":8089" 或者 www.hdch.net :8089
 以上的两个地址都是用来测试的其中公司的服务器是测试花卉园的模拟球场
 阿里云服务器地址：
 http://101.200.187.92:8081 --巡鹰项目@"http://101.200.187.92"  @":8081"
 http://101.200.187.92:8888 --推送服务
 
 */

#define MainURL                             @"http:www.hdch.net"
#define PortNum                             @":8089"


#define HeartBeatURL                        [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/appheartbeat.htm"]

#define loginURL                            [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/empLoginApp.htm"]

#define JumpHoleURL                         [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/skipHole.htm"]
#define MendHoleURL                         [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/mendHole.htm"]

#define CaddyCartInfURL                     [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/caddyCartList.htm"]

#define CustomInfURL                        [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/getLastShownum.htm"]

#define createGroupURL                      [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/createGroup.htm"]
//cancle down group
#define CancleWaitingGroupURL               [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/cancelGroup.htm"]

//back to the field
#define BackToFieldURL                      [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/gotoBack.htm"]
//判断是否可以建组，是否可以进入球场功能界面
#define DecideCreateGrpAndDownField         [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/isOperation.htm"]
//退出登录接口
#define LogOutURL                           [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/exitLoginApp.htm"]
//请求更换球童接口
#define ChangeCaddyURL                      [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/changeCaddy.htm"]
//请求更换球车接口
#define ChangeCartURL                       [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/changeCart.htm"]
//打球进度借口
#define GetPlayProcessURL                   [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/getProgress.htm"]
//申请立场休息
#define RequestLeaveTimeURL                 [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/offHole.htm"]
//获取历史消息
#define RequestMsgHistoryURL                [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/msgHistroyApp.htm"]
//发送消息
#define RequestSendMsgURL                   [NSString stringWithFormat:@"%@%@%@",MainURL,PortNum,@"/XYGolfManage/messageComm.htm"]


//#define testChangeInterface                 1



//IMEI code
#define TESTMIDCODE                         @"A_IMEI_864505021764438"
#define MIDCODE                             @"A_IMEI_15000204330"
//how many times send simulateGPS Data for for each GPS point
#define GPSSendTimes    3

//playBack
#define PlayBack        0
#define JumpHole        1
#define CancleSelect    2

#endif
