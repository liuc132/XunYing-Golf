//
//  TaskDetailViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/12/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "MessageModel.h"
#import "CellFrameModel.h"
#import "MessageCell.h"
#import "DBCon.h"
#import "DataTable.h"
#import "TaskTableViewCell.h"


#define kToolBarH 44
#define kTextFieldH 30

@interface TaskDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *_cellFrameDatas;
    UITableView *_chatView;
    UIImageView *_toolBar;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *theNav;
@property (strong, nonatomic) IBOutlet UILabel *statusDisLabel;
@property (strong, nonatomic) IBOutlet UIView *jumpHoleDetailView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItemDetail;
//三行事件视图
@property (strong, nonatomic) IBOutlet UIView *threeLineView;//整个视图
@property (strong, nonatomic) IBOutlet UILabel *threeLineReqTime;//申请时间
@property (strong, nonatomic) IBOutlet UILabel *threeLineReqPerson;//申请人
@property (strong, nonatomic) IBOutlet UILabel *taskReqName;//请求事件名称
@property (strong, nonatomic) IBOutlet UILabel *taskReqDetail;//请求事件详情
@property (strong, nonatomic) IBOutlet TaskTableViewCell *threeLineTableCell;

//四行事件视图
@property (strong, nonatomic) IBOutlet UIView *fourLineView;//真个视图
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqTime;//请求时间
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqPerson;//请求人
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqDetail;//请求事件详情
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqName;//请求事件名称
@property (strong, nonatomic) IBOutlet UILabel *fourLineHandleName;//处理结果名称
@property (strong, nonatomic) IBOutlet UILabel *fourLineHandleResult;//处理结果详情
@property (strong, nonatomic) IBOutlet TaskTableViewCell *fourLineTableCell;


//五行事件视图
@property (strong, nonatomic) IBOutlet UIView *fiveLineView;//整个视图
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqTime;//请求时间
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqPerson;//请求人
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqName;//事件请求名称
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqDetail;//事件请求详情
@property (strong, nonatomic) IBOutlet UILabel *fiveLineHandleName;//事件处理结果名称
@property (strong, nonatomic) IBOutlet UILabel *fiveLineHandleDetail;//事件处理结果详情
@property (strong, nonatomic) IBOutlet UILabel *rebackHandleName;//恢复事件名称
@property (strong, nonatomic) IBOutlet UILabel *rebackHandleDetail;//恢复时间详情
@property (strong, nonatomic) IBOutlet TaskTableViewCell *fiveLineTableCell;

//
- (IBAction)backToTaskList:(UIBarButtonItem *)sender;

@end

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.threeLineView.frame = CGRectMake(0, self.theNav.frame.size.height + self.theNav.frame.origin.y + self.statusDisLabel.frame.size.height + self.statusDisLabel.frame.origin.y, self.threeLineView.frame.size.width, self.threeLineView.frame.size.height);
    
    [self.view addSubview:self.threeLineView];
    
    //0.加载数据
    [self loadData];
    
    //1.tableView
    [self addChatView];
    
    //2.工具栏
    [self addToolBar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItemDetail.title = self.taskTypeName;
    
}
/**
 *  加载数据
 */
- (void)loadData
{
    _cellFrameDatas =[NSMutableArray array];
    NSURL *dataUrl = [[NSBundle mainBundle] URLForResource:@"messages.plist" withExtension:nil];
    NSArray *dataArray = [NSArray arrayWithContentsOfURL:dataUrl];
    for (NSDictionary *dict in dataArray) {
        MessageModel *message = [MessageModel messageModelWithDict:dict];
        CellFrameModel *lastFrame = [_cellFrameDatas lastObject];
        CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
        message.showTime = ![message.time isEqualToString:lastFrame.message.time];
        cellFrame.message = message;
        [_cellFrameDatas addObject:cellFrame];
    }
}
/**
 *  添加TableView
 */
- (void)addChatView
{
    self.jumpHoleDetailView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
    UITableView *chatView = [[UITableView alloc] init];
    chatView.frame = CGRectMake(0, self.theNav.frame.size.height + self.theNav.frame.origin.y + self.statusDisLabel.frame.size.height + self.statusDisLabel.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - kToolBarH - (self.theNav.frame.size.height + self.theNav.frame.origin.y + self.statusDisLabel.frame.size.height + self.statusDisLabel.frame.origin.y + 2*kToolBarH));
    chatView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
    chatView.delegate = self;
    chatView.dataSource = self;
    chatView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chatView.allowsSelection = NO;
    [chatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
    _chatView = chatView;
    
    [self.jumpHoleDetailView addSubview:chatView];
}
/**
 *  添加工具栏
 */
- (void)addToolBar
{
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.frame = CGRectMake(0, self.jumpHoleDetailView.frame.size.height - kToolBarH, self.jumpHoleDetailView.frame.size.width, kToolBarH);
    bgView.image = [UIImage imageNamed:@"chat_bottom_bg"];
    bgView.userInteractionEnabled = YES;
    _toolBar = bgView;
    [self.jumpHoleDetailView addSubview:bgView];
    
    UIButton *sendSoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendSoundBtn.frame = CGRectMake(0, 0, kToolBarH, kToolBarH);
    [sendSoundBtn setImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
    [bgView addSubview:sendSoundBtn];
    
    UIButton *addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = CGRectMake(self.view.frame.size.width - kToolBarH, 0, kToolBarH, kToolBarH);
    [addMoreBtn setImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
    [bgView addSubview:addMoreBtn];
    
    UIButton *expressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expressBtn.frame = CGRectMake(self.view.frame.size.width - kToolBarH * 2, 0, kToolBarH, kToolBarH);
    [expressBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [bgView addSubview:expressBtn];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeySend;
    textField.enablesReturnKeyAutomatically = YES;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 1)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.frame = CGRectMake(kToolBarH, (kToolBarH - kTextFieldH) * 0.5, self.view.frame.size.width - 3 * kToolBarH, kTextFieldH);
    textField.background = [UIImage imageNamed:@"chat_bottom_textfield"];
    textField.delegate = self;
    [bgView addSubview:textField];
}

#pragma mark - tableView的数据源和代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellFrameDatas.count;
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.cellFrame = _cellFrameDatas[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellFrameModel *cellFrame = _cellFrameDatas[indexPath.row];
    return cellFrame.cellHeght;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField的代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //1.获得时间
    NSDate *senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    //2.创建一个MessageModel类
    MessageModel *message = [[MessageModel alloc] init];
    message.text = textField.text;
    message.time = locationString;
    message.type = 0;
    
    //3.创建一个CellFrameModel类
    CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
    CellFrameModel *lastCellFrame = [_cellFrameDatas lastObject];
    message.showTime = ![lastCellFrame.message.time isEqualToString:message.time];
    cellFrame.message = message;
    
    //4.添加进去，并且刷新数据
    [_cellFrameDatas addObject:cellFrame];
    [_chatView reloadData];
    
    //5.自动滚到最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_cellFrameDatas.count - 1 inSection:0];
    [_chatView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    textField.text = @"";
    
    return YES;
}

- (void)endEdit
{
    [self.view endEditing:YES];
}

/**
 *  键盘发生改变执行
 */
- (void)keyboardWillChange:(NSNotification *)note
{
    NSLog(@"%@", note.userInfo);
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY);
    }];
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

- (IBAction)backToTaskList:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"taskDetailtoAllTaskList" sender:nil];
}
@end
