//
//  HWCreateMeetingController.m
//  JDFocusGovernmentBeiJing
//
//  Created by huangyingjie9 on 2021/4/20.
//  Copyright © 2021 jd.com. All rights reserved.
//

#import "HWCreateMeetingController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "HWCloudLinkEngine.h"
#import "HWCloudLink-Swift.h"
#import "Masonry.h"

@interface HWCreateMeetingController () <UITextFieldDelegate>

@property(nonatomic, strong)UILabel *microStatusLab;
@property(nonatomic, strong)UILabel *cameraStatusLab;

@property(nonatomic, strong)UIView *actionView;

@property(nonatomic, assign)BOOL microEnable;
@property(nonatomic, assign)BOOL cameraEnable;


@property(nonatomic, strong)UITapGestureRecognizer *keyboardStatusGesture;


@end

@implementation HWCreateMeetingController

- (void)viewWillAppear:(BOOL)animated
{
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeGestureRecognizer:self.keyboardStatusGesture];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.microEnable = YES;
    self.cameraEnable = YES;
    self.view.backgroundColor = [UIColor colorWithRed:33/255.0 green:43/255.0 blue:55/255.0 alpha:1.0];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    self.keyboardStatusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardStatusHandle)];
    [self.view addGestureRecognizer:self.keyboardStatusGesture];
    
    [self setupViews];
}

- (void)setupViews
{
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Nb"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(17.3);
        make.top.mas_equalTo(self.view.mas_top).offset(57.3);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(18);
    }];
    
    self.subjectTextField.hidden = NO;
    
    NSString *str = @"设置6位数字密码";
    CGRect contentRect = [str boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    UIButton *showPwdBtn = [[UIButton alloc] init];
    [showPwdBtn setBackgroundImage:[UIImage imageNamed:@"fm_btn_close"] forState:UIControlStateNormal];
    [showPwdBtn addTarget:self action:@selector(inputPwdAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPwdBtn];
    [showPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subjectTextField.mas_bottom).offset(38);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20 + contentRect.size.width);
    }];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"ic_bianji"];
    imgView.userInteractionEnabled = YES;
    [showPwdBtn addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(showPwdBtn.mas_left).offset(0);
        make.top.mas_equalTo(showPwdBtn.mas_top).offset(0);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.backgroundColor = [UIColor colorWithRed:33/255.0 green:43/255.0 blue:55/255.0 alpha:1.0];
    tipLab.text = str;
    tipLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0f];
    tipLab.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];;
    [showPwdBtn addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imgView.mas_right).offset(0);
        make.top.mas_equalTo(showPwdBtn.mas_top).offset(0);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(contentRect.size.width);
    }];
    
    
    self.actionView.hidden = NO;
    self.microBtn.hidden = NO;
    self.cameraBtn.hidden = NO;
    
    UIButton *startMeetingBtn = [[UIButton alloc] init];
    startMeetingBtn.backgroundColor = [UIColor colorWithRed:48/255.0 green:111/255.0 blue:220/255.0 alpha:1.0];
    startMeetingBtn.layer.cornerRadius = 4;
    [startMeetingBtn setTitle:@"开始会议" forState:UIControlStateNormal];
    [startMeetingBtn addTarget:self action:@selector(startMeetingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionView addSubview:startMeetingBtn];
    [startMeetingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.actionView.mas_bottom).offset(-84);
        make.centerX.mas_equalTo(self.actionView.mas_centerX);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(144);
    }];
}

#pragma mark -
#pragma mark - setter and getter

- (UIView *)actionView
{
    if (!_actionView)
    {
        _actionView = [[UIView alloc] init];
        [self.view addSubview:_actionView];
        [_actionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(0);
            make.right.mas_equalTo(self.view.mas_right).offset(0);
            make.top.mas_equalTo(self.view.mas_bottom).offset(-251);
            make.height.mas_equalTo(251);
        }];
    }
    
    return _actionView;
}

- (UITextField *)subjectTextField
{
    if (!_subjectTextField)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSForegroundColorAttributeName] = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
        dict[NSFontAttributeName] = [UIFont fontWithName:@"PingFangSC-Regular" size:20.0f];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"请输入会议主题" attributes:dict];
                
        _subjectTextField = [[UITextField alloc] init];
        _subjectTextField.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
        _subjectTextField.attributedPlaceholder = string;
        _subjectTextField.textAlignment = NSTextAlignmentCenter;
        _subjectTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.0f];
        _subjectTextField.textColor = [UIColor whiteColor];
        _subjectTextField.delegate = self;
        _subjectTextField.layer.cornerRadius = 6;
        [self.view addSubview:_subjectTextField];

        [_subjectTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(30);
            make.top.mas_equalTo(self.view.mas_top).offset(108);
            make.right.mas_equalTo(self.view.mas_right).offset(-30);
            make.height.mas_equalTo(46);
        }];
    }
    
    return  _subjectTextField;
}

- (UITextField *)passwordTextField
{
    if (!_passwordTextField)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSForegroundColorAttributeName] = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
        dict[NSFontAttributeName] = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"设置6位数字密码" attributes:dict];
                
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.hidden = YES;
        _passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
        _passwordTextField.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
        _passwordTextField.attributedPlaceholder = string;
        _passwordTextField.textAlignment = NSTextAlignmentCenter;
        _passwordTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _passwordTextField.textColor = [UIColor whiteColor];
        _passwordTextField.delegate = self;
        _passwordTextField.layer.cornerRadius = 6;
        [self.view addSubview:_passwordTextField];

        [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.subjectTextField.mas_left).offset(0);
            make.top.mas_equalTo(self.subjectTextField.mas_bottom).offset(30);
            make.right.mas_equalTo(self.subjectTextField.mas_right).offset(0);
            make.height.mas_equalTo(self.subjectTextField.mas_height);
        }];
    }
    return  _passwordTextField;
}

- (UIButton *)microBtn
{
    if (!_microBtn)
    {
        _microBtn = [[UIButton alloc] init];
        _microBtn.selected = self.microEnable;
        [_microBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal_off"] forState:UIControlStateNormal];
        [_microBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal"] forState:UIControlStateSelected];
        [_microBtn addTarget:self action:@selector(microAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.actionView addSubview:_microBtn];
        [_microBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.actionView.mas_left).offset(100);
            make.bottom.mas_equalTo(self.actionView.mas_bottom).offset(-203);
            make.height.mas_equalTo(48);
            make.width.mas_equalTo(48);
        }];
        
        _microStatusLab = [[UILabel alloc] init];
        _microStatusLab.text = self.microEnable ? @"已开启" : @"已关闭";
        _microStatusLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _microStatusLab.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.65];;
        [self.actionView addSubview:_microStatusLab];
        [_microStatusLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_microBtn.mas_bottom).offset(8);
            make.centerX.mas_equalTo(_microBtn.mas_centerX).offset(0);
            make.height.mas_equalTo(17);
            make.width.mas_equalTo(36);
        }];
    }
    
    return _microBtn;
}

- (UIButton *)cameraBtn
{
    if (!_cameraBtn)
    {
        _cameraBtn = [[UIButton alloc] init];
        _cameraBtn.selected = self.cameraEnable;
        [_cameraBtn setBackgroundImage:[UIImage imageNamed:@"btn_meeting_click_off"] forState:UIControlStateNormal];
        [_cameraBtn setBackgroundImage:[UIImage imageNamed:@"btn_meeting_click"] forState:UIControlStateSelected];
        [_cameraBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:_cameraBtn];
        [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.actionView.mas_right).offset(-100);
            make.bottom.mas_equalTo(self.microBtn.mas_bottom).offset(0);
            make.height.mas_equalTo(48);
            make.width.mas_equalTo(48);
        }];
        
        _cameraStatusLab = [[UILabel alloc] init];
        _cameraStatusLab.text = self.cameraEnable ? @"已开启" : @"已关闭";
        _cameraStatusLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        _cameraStatusLab.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.65];;
        [self.actionView addSubview:_cameraStatusLab];
        [_cameraStatusLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_cameraBtn.mas_bottom).offset(8);
            make.centerX.mas_equalTo(_cameraBtn.mas_centerX).offset(0);
            make.height.mas_equalTo(17);
            make.width.mas_equalTo(36);
        }];
    }
    return _cameraBtn;
}


#pragma mark -
#pragma mark - notifaction and gesture

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"键盘rect ----> %@", NSStringFromCGRect(endKeyboardRect));

    CGRect rect = self.actionView.frame;
    CGFloat KeyboardY = endKeyboardRect.origin.y;
    CGFloat transY = KeyboardY - CGRectGetHeight(rect);
    BOOL flag = (endKeyboardRect.origin.y == CGRectGetHeight(self.view.frame));

    [self.actionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(transY + (flag ? 0 : 60));
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardStatusHandle
{
    if (self.subjectTextField.isFirstResponder)
    {
        [self.subjectTextField resignFirstResponder];
    }
    
    if (self.passwordTextField.isFirstResponder)
    {
        [self.passwordTextField resignFirstResponder];
    }
}

#pragma mark -
#pragma mark - event action

- (void)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)inputPwdAction:(id)sender
{
    [(UIButton *)sender setHidden:YES];
    self.passwordTextField.hidden = NO;
}

- (void)microAction:(id)sender
{
    self.microBtn.selected = !self.microBtn.selected;
    self.microEnable = self.microBtn.selected;
    self.microStatusLab.text = self.microEnable ? @"已开启" : @"已关闭";
}

- (void)cameraAction:(id)sender
{
    self.cameraBtn.selected = !self.cameraBtn.selected;
    self.cameraEnable = self.cameraBtn.selected;
    self.cameraStatusLab.text = self.cameraEnable ? @"已开启" : @"已关闭";
}


- (void)startMeetingAction:(id)sender
{
    [self keyboardStatusHandle];
    
    HWCloudLinkEngine *engine = [HWCloudLinkEngine sharedInstance];
    [engine createMeetingWithSubject:self.subjectTextField.text password:self.passwordTextField.text microEnable:self.microEnable cameraEnable:self.cameraEnable];
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *valueText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger maxNum = (textField == self.passwordTextField ? 6 : 10);
    
    if (valueText.length > maxNum)
    {
        textField.text = [valueText substringToIndex:maxNum];
        return NO;
    }
    
    return YES;
}

@end
