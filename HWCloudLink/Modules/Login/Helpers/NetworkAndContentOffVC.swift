//
//  NetworkAndContentOffVC.swift
//  HWCloudLink
//
//  Created by cos on 2020/11/28.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation
import SwiftTheme

/// 网络判断会议类型
enum NeworkConfStatus {
    case notInConf          // 不在会议中
    case inPointTwoPoint    // 正在点对点通话
    case inConf             // 正在会议中
}

extension WelcomeViewController {
    static func noNetWorkAndContentOffCurrentVC() {
        let currentVC = ViewControllerUtil.getCurrentViewController()
        self.noNetWorkAndContentOffWithVC(viewController: currentVC)
    }
    
    static func netWorkAndContentOffCurrentVC() {
        let currentVC = ViewControllerUtil.getCurrentViewController()
        self.netWorkAndContentOffWithVC(viewController: currentVC)
    }
    
    static func noNetWorkAndContentOffWithVC(viewController: UIViewController) {
        switch viewController {
        case is LoginViewController:  // 登陆页面
            let loginVC:LoginViewController = viewController as! LoginViewController
            UIView.hideSetColorNoAction(withYesOrNo: true, andView: loginVC.loginBtn, andBgColor: COLOR_GRAY_WHITE)
            TopToastView.loginViewToast.isHidden = false
        case is MeetingDetailViewController:  // 会议详情
            let meetDetailVC:MeetingDetailViewController = viewController as! MeetingDetailViewController
            meetDetailVC.footerView.joinMeetingBtn.theme_backgroundColor = ThemeColorPicker.init(colors: COLOR_GRAY_WHITE)
            UIView.hideSetBtnBorderColorNoAction(withYesOrNo: true, andView: meetDetailVC.footerView.cancelMeetingBtn, andBorderColor: COLOR_GRAY_WHITE)
            meetDetailVC.footerView.joinMeetingBtn.isUserInteractionEnabled = false
        case is MyMeetingListViewController:  // 我的会议
            let myMeetVC:MyMeetingListViewController = viewController as! MyMeetingListViewController
            myMeetVC.TableView.mj_header?.isHidden = true
            myMeetVC.TableView.reloadData()
        case is CreateMeetingViewController:  // 发起会议
            let creatMeetVC:CreateMeetingViewController = viewController as! CreateMeetingViewController
            UIView.hideSetColorNoAction(withYesOrNo: true,
                                        andView: creatMeetVC.beginBtnRef,
                                        andBgColor: COLOR_GRAY_WHITE)
        case is JoinMeetingViewController:  // 加入会议
            let joinMeetVC:JoinMeetingViewController = viewController as! JoinMeetingViewController
            UIView.hideSetColorNoAction(withYesOrNo: true,
                                        andView: joinMeetVC.joinConfBtn,
                                        andBgColor: COLOR_GRAY_WHITE)
        case is PreMeetingViewController:  // 预约会议
            let preMeetingVC:PreMeetingViewController = viewController as! PreMeetingViewController
            UIView.hideSetColorNoAction(withYesOrNo: true, andView: preMeetingVC.preConfBtn, andBgColor: COLOR_GRAY_WHITE)
        case is SearchAttendeeViewController:  // 与会者邀请搜索
            let searchAttVC:SearchAttendeeViewController = viewController as! SearchAttendeeViewController
            searchAttVC.refreshAllData(isNetwork: false)
        case is FeedBackCommitViewController:  // 日志上传
            let  commitVC:FeedBackCommitViewController = viewController as! FeedBackCommitViewController
            commitVC.netIsNormal = false
        case is CompanySearchViewController:  // 全局搜索VC
            let companyVC:CompanySearchViewController = viewController as! CompanySearchViewController
            companyVC.tableView.reloadData()
        case is CreatMeetingThreeVersionViewController:  // 3.0创建会议VC
            let creatMeetingThreeVersionVC:CreatMeetingThreeVersionViewController = viewController as! CreatMeetingThreeVersionViewController
            UIView.hideSetColorNoAction(withYesOrNo: true, andView: creatMeetingThreeVersionVC.beginBtnRef, andBgColor: COLOR_GRAY_WHITE)
        case is AnswerPhoneViewController:  // 接听来电界面
            let answerPhoneVC = viewController as! AnswerPhoneViewController
            answerPhoneVC.cancelCallBtnClick(UIButton.init())
            _ = self.checkNetworkWithNoNetworkAlert(confStatus: .notInConf, isDelayShow: true)
        case is SessionViewController:  // 会议VC
            TopToastView.sessionViewToast.isHidden = false
        case is ContactViewController:  // 联系人VC
            let contactVC = viewController as! ContactViewController
            contactVC.tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            TopToastView.contactViewToast.isHidden = false
        case is MineViewController:     // 我的VC
            let mineVC = viewController as! MineViewController
            if (mineVC.tableView != nil) {
                mineVC.tableView!.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            }
            TopToastView.mineViewToast.isHidden = false
        default: break
        }
    }
    
    static func netWorkAndContentOffWithVC(viewController: UIViewController) {
        switch viewController {
        case is LoginViewController:  // 登陆页面
            let loginVC:LoginViewController = viewController as! LoginViewController
            UIView.hideSetColorNoAction(withYesOrNo: false, andView: loginVC.loginBtn,
                                        andBgColor: COLOR_HIGHT_LIGHT_SYSTEM)
            TopToastView.loginViewToast.isHidden = true
        case is LoginSettingViewController:  // 登陆设置
            let loginSetVC:LoginSettingViewController = viewController as! LoginSettingViewController
            loginSetVC.tableView.contentInset = UIEdgeInsets.zero
        case is ServerSettingViewController:  // 服务器设置
            let serverVC:ServerSettingViewController = viewController as! ServerSettingViewController
            serverVC.tableView.contentInset = UIEdgeInsets.zero
        case is PrivateExplainViewController:  // 隐私声明
            let privateVC:PrivateExplainViewController = viewController as! PrivateExplainViewController
            privateVC.textViewConstraintTop.constant = 0
        case is MeetingDetailViewController:  // 会议详情
            let meetDetailVC:MeetingDetailViewController = viewController as! MeetingDetailViewController
            meetDetailVC.tableView.contentInset = UIEdgeInsets.zero
            meetDetailVC.footerView.setButtonStyle(isActive: meetDetailVC.meetInfo?.isActive ?? false, isConvener: meetDetailVC.isConvener, isShowJoinBtn: meetDetailVC.isShowJoinBtn)
            UIView.hideSetBtnBorderColorNoAction(withYesOrNo: false, andView: meetDetailVC.footerView.cancelMeetingBtn,
                                                 andBorderColor: UIColorFromRGB(rgbValue: 0xF34B4B))
            meetDetailVC.footerView.joinMeetingBtn.isUserInteractionEnabled = true
        case is MyMeetingListViewController:  // 我的会议
            let myMeetVC:MyMeetingListViewController = viewController as! MyMeetingListViewController
            myMeetVC.TableView.contentInset = UIEdgeInsets.zero
            myMeetVC.TableView.mj_header?.isHidden = false
            myMeetVC.headerRefresh()
        case is CreateMeetingViewController:  // 发起会议
            let creatMeetVC:CreateMeetingViewController = viewController as! CreateMeetingViewController
            creatMeetVC.tableView.contentInset = UIEdgeInsets.zero
            UIView.hideSetColorNoAction(withYesOrNo: false,
                                        andView: creatMeetVC.beginBtnRef,
                                        andBgColor: COLOR_HIGHT_LIGHT_SYSTEM)
        case is MeetAdvanceSetViewController:  // 高级设置
            let meetAdvanceVC:MeetAdvanceSetViewController = viewController as! MeetAdvanceSetViewController
            meetAdvanceVC.tableView.contentInset = UIEdgeInsets.zero
        case is MeetingTypeSetViewController:  // 会议类型
            let meetTypeVC:MeetingTypeSetViewController = viewController as! MeetingTypeSetViewController
            meetTypeVC.tableView.contentInset = UIEdgeInsets.zero
        case is JoinMeetingViewController:  // 加入会议
            let joinMeetVC:JoinMeetingViewController = viewController as! JoinMeetingViewController
            joinMeetVC.tableView.contentInset = UIEdgeInsets.zero
            UIView.hideSetColorNoAction(withYesOrNo: false,
                                        andView: joinMeetVC.joinConfBtn,
                                        andBgColor: COLOR_HIGHT_LIGHT_SYSTEM)
        case is PreMeetingViewController:  // 预约会议
            let preMeetingVC:PreMeetingViewController = viewController as! PreMeetingViewController
            preMeetingVC.tableView.contentInset = UIEdgeInsets.zero
            UIView.hideSetColorNoAction(withYesOrNo: false, andView: preMeetingVC.preConfBtn, andBgColor: COLOR_HIGHT_LIGHT_SYSTEM)
        case is PreMeetingSettingViewController:  // 预约会议高级设置
            let  preMeetSetVC:PreMeetingSettingViewController = viewController as! PreMeetingSettingViewController
            preMeetSetVC.tableView.contentInset = UIEdgeInsets.zero
        case is PreMeetingAttendeeViewController:  // 预约会议添加与会者
            let  preMeetAttVC:PreMeetingAttendeeViewController = viewController as! PreMeetingAttendeeViewController
            preMeetAttVC.collectionView.contentInset = UIEdgeInsets.zero
        case is SearchAttendeeViewController:  // 与会者邀请搜索
            let searchAttVC:SearchAttendeeViewController = viewController as! SearchAttendeeViewController
            searchAttVC.refreshAllData(isNetwork: true)
        case is FeedBackCommitViewController:  // 日志上传
            let  commitVC:FeedBackCommitViewController = viewController as! FeedBackCommitViewController
            commitVC.netIsNormal = true
            commitVC.tableView.contentInset = UIEdgeInsets.zero
        case is CompanySearchViewController:  // 全局搜索VC
            let companyVC:CompanySearchViewController = viewController as! CompanySearchViewController
            companyVC.tableView.reloadData()
        case is CreatMeetingThreeVersionViewController:  // 3.0创建会议VC
            let creatMeetingThreeVersionVC:CreatMeetingThreeVersionViewController = viewController as! CreatMeetingThreeVersionViewController
            UIView.hideSetColorNoAction(withYesOrNo: false, andView: creatMeetingThreeVersionVC.beginBtnRef, andBgColor: COLOR_HIGHT_LIGHT_SYSTEM)
        case is SessionViewController:  // 会议VC
            let sessionVC = viewController as! SessionViewController
            sessionVC.tableView.contentInset = UIEdgeInsets.zero
            TopToastView.sessionViewToast.isHidden = true
        case is ContactViewController:  // 联系人VC
            let contactVC = viewController as! ContactViewController
            contactVC.tableView.contentInset = UIEdgeInsets.zero
            TopToastView.contactViewToast.isHidden = true
        case is MineViewController:     // 我的VC
            let mineVC = viewController as! MineViewController
            if (mineVC.tableView != nil) {
                mineVC.tableView!.contentInset = UIEdgeInsets.zero
            }
            TopToastView.mineViewToast.isHidden = true
        default:break
        }
    }
    
    // chenfan: update UI
    static func checkNetworkAndUpdateUI() -> Bool {
        var result = LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.offline
        
        // 未登录
        if LoginCenter.sharedInstance()?.getUserLoginStatus() == UserLoginStatus.unLogin {
            result = NetworkUtils.unavailable()
        }
        // 已登录
        _ = result ? self.noNetWorkAndContentOffCurrentVC() : self.netWorkAndContentOffCurrentVC()
        
        return result
    }
    
    // chenfan: no network with show alert
    static func checkNetworkWithNoNetworkAlert(confStatus: NeworkConfStatus = .notInConf, isDelayShow: Bool = false) -> Bool {
        let result = LoginCenter.sharedInstance()?.getUserLoginStatus() != UserLoginStatus.online
        if result {
            let alertTitleVC = TextTitleSingleBtnViewController()
            alertTitleVC.modalTransitionStyle = .crossDissolve
            alertTitleVC.modalPresentationStyle = .overFullScreen
            
            switch confStatus {
            case .inConf:
                alertTitleVC.title = tr("当前网络异常，会议中断，请重新加入会议")
            case .notInConf:
                alertTitleVC.title = tr("网络异常，请检查网络设置")
            case .inPointTwoPoint:
                alertTitleVC.title = tr("当前网络异常，通话中断，请重新呼叫")
            }
            
            alertTitleVC.viewDidLoadClosure = { [weak alertTitleVC] () -> Void in
                if (alertTitleVC != nil && alertTitleVC?.showTitleLabel != nil) {
                    alertTitleVC?.showTitleLabel.text = alertTitleVC?.title
                    alertTitleVC?.showSureBtn.setTitle(tr("我知道了"), for: UIControl.State.normal)
                }
            }
            if isDelayShow {
                
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (isDelayShow ? 1.0 : 0.0)) {
                let currentVC = ViewControllerUtil.getCurrentViewController()
                currentVC.present(alertTitleVC, animated: true, completion: nil)
            }
        }
        
        return result
    }
}

extension UIViewController {
    public class func initializeMethod(){
        // 交换viewDidload方法
        exchangeMethod(systemMethod: #selector(UIViewController.viewDidLoad),
                       customMethod: #selector(UIViewController.viewDidLoadR))
        // 交换viewdidappear方法
        exchangeMethod(systemMethod: #selector(UIViewController.viewDidAppear),
                       customMethod: #selector(UIViewController.viewDidAppearR))
    }
    
    @objc func viewDidLoadR() {
        self.viewDidLoadR()
        
        let showWarningText = tr("网络异常，请检查网络设置")
        switch self {
        case is SessionViewController:  // 会议VC
            self.view.addSubview(TopToastView.sessionViewToast)
            TopToastView.sessionViewToast.showWarning(text: tr(showWarningText), isAddToView: false)
            _ = WelcomeViewController.checkNetworkAndUpdateUI()
        case is ContactViewController:  // 联系人VC
            self.view.addSubview(TopToastView.contactViewToast)
            TopToastView.contactViewToast.showWarning(text: tr(showWarningText), isAddToView: false)
            _ = WelcomeViewController.checkNetworkAndUpdateUI()
        case is MineViewController:     // 我的VC
            self.view.addSubview(TopToastView.mineViewToast)
            TopToastView.mineViewToast.showWarning(text: tr(showWarningText), isAddToView: false)
            _ = WelcomeViewController.checkNetworkAndUpdateUI()
        case is LoginViewController:     // 登录VC
            self.view.addSubview(TopToastView.loginViewToast)
            TopToastView.loginViewToast.showWarning(text: tr(showWarningText), isAddToView: false)
            _ = WelcomeViewController.checkNetworkAndUpdateUI()
        default: break
        }
        
        // 监听网络变化
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNetworkChangeUIVCStatus(notification:)), name: NSNotification.Name.init(rawValue: NETWORK_STATUS_CHAGNE_UI_NOTIFY), object: nil)
    }
    
    @objc func viewDidAppearR() {
        self.viewDidAppearR()
    }
    
    @objc func notificationNetworkChangeUIVCStatus(notification: Notification) {
        let isConnectServer = notification.object as! Bool
        
        if isConnectServer {
            WelcomeViewController.netWorkAndContentOffWithVC(viewController: self)
        } else {
            WelcomeViewController.noNetWorkAndContentOffWithVC(viewController: self)
        }
    }
}


extension UIViewController {
    
    /// 方法交换函数
    /// - Parameters:
    ///   - systemMethod: 系统方法
    ///   - customMethod: 自定义方法
    public class func exchangeMethod(systemMethod: Selector, customMethod: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, systemMethod) else { return }
        guard let swizzledMethod = class_getInstanceMethod(self, customMethod) else { return }

        
        let didAddMethod: Bool = class_addMethod(self, systemMethod, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(self, customMethod, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
