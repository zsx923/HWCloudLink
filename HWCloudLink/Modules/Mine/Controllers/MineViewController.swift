//
// MineViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    @IBOutlet weak var topUserInfoView: UIView!
    @IBOutlet weak var userNameLabel: ActionUILabel!
    @IBOutlet weak var userCodeLabel: UILabel!
//    @IBOutlet weak var tableView: UITableView!

    var  tableView: UITableView?
    @IBOutlet weak var netWorkChangeConstraint: NSLayoutConstraint!
    //图片
    @IBOutlet weak var backImageView: UIImageView!
    
    var headerView : MyselfHeaderView = {
        let view = MyselfHeaderView.creatMySeftHeaderView()
        
        return view as! MyselfHeaderView
    } ()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if ManagerService.call()?.ldapContactInfo == nil {
//            let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
//            headerView.nameLabel.text = loginInfo?.account
//            headerView.codeLabel.text = ManagerService.call()?.terminal
//            // 更新后台数据
//            if !HWLoginInfoManager.shareInstance.isSuccessGetName() {
//                HWLoginInfoManager.shareInstance.getLoginInfoByCorporateDirectory()
//                HWLoginInfoManager.shareInstance.getLoginInfoBack = { [weak self](_ name:String) in
//                    self?.setInitData()
//                }
//            }
//        }
    }

    override func viewDidLoad() {
        tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.view.addSubview(tableView!)
        super.viewDidLoad()
        ViewControllerUtil.setNavigationStyle(navigationVC: self.navigationController)
        // set init data
        self.setInitData()
        // set table
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.separatorStyle = .none
        self.tableView!.register(UINib.init(nibName: TableImageTextNormalCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableImageTextNormalCell.CELL_ID)
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 210)
        tableView?.tableHeaderView = headerView
        headerView.passClickHeaderViewValueBlock = { [weak self] in
            let userInfo = ManagerService.call()?.ldapContactInfo
            let storyboard = UIStoryboard.init(name: "PersonalInfoViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PersonalInfoView") as! PersonalInfoViewController
            vc.userInfo = userInfo
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        // 接收更新userName（主要是AD账号登录回调中没有用户名称）
        HWLoginInfoManager.shareInstance.getLoginInfoBack = { [weak self](_ name:String) in
            guard let self = self else { return }
            if let loginUserName = ManagerService.loginService()?.obtainCurrentLoginInfo()?.userName, loginUserName == "" {
                ManagerService.loginService()?.setLoginInfoWithUserName(name)
                self.setInitData()
            }
        }
        
        // language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageChange(notfic:)), name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(displaySuccessView), name: NSNotification.Name("upLogsLoadSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserInfoUpdate(notification:)), name: NSNotification.Name(LOGIN_GET_USER_INFO_SUCCESS_KEY), object: nil)

        if ManagerService.call()?.isSMC3==true,LoginCenter.sharedInstance().getUserLoginStatus() !=  UserLoginStatus.unLogin{
            NotificationCenter.default.addObserver(self, selector: #selector(getUpLoadLogResult(noti:)), name: NSNotification.Name(UPLOAD_LOG_RESULT), object: nil)
        }
    }
    @objc func getUpLoadLogResult(noti: Notification){
        FeedBackCommitViewController.isLogUpLoad = false
        guard let value = noti.userInfo as? [String:Any] , let uploadResult = value["result"] as? String else {
            DispatchQueue.main.async {
//                MBProgressHUD.showBottomOnRootVC(with: tr("日志上传失败"), icon: nil, view: nil)
                MBProgressHUD.showBottom(tr("日志上传失败"), icon: nil, view: nil)
                CLLog("日志上传错误")
            }
            return
        }
        //清除本地缓存
        let zipYES =  ISLogFileManager.clearZip()
        CLLog("日志清理返回结果:\(zipYES)")
        if  uploadResult == "0" {
            DispatchQueue.main.async {
                self.displaySuccessView()
            }
        } else {
            DispatchQueue.main.async {
                CLLog("日志上传报错")
//                MBProgressHUD.showBottomOnRootVC(with: tr("日志上传失败"), icon: nil, view: nil)
                MBProgressHUD.showBottom(tr("日志上传失败"), icon: nil, view: nil)

            }
        }
    }
    deinit {
        CLLog("MineViewController deinit")
    }
    
    @objc func languageChange(notfic:Notification) {
        self.tableView!.reloadData()
    }
    @objc func displaySuccessView(){
        DispatchQueue.main.async {
            CLLog("日志上传成功")
//            MBProgressHUD.showBottomOnRootVC(with: tr("已收到，感谢你的反馈"), icon: nil, view: nil)
            MBProgressHUD.showBottom(tr("已收到，感谢你的反馈"), icon: nil, view: nil)
        }
    }
    
    // MARK: 用户信息回调通知
    @objc func notificationUserInfoUpdate(notification: Notification) {
        self.setInitData()
    }
    
    func setViewUI() {
        //
//        self.topUserInfoView.clipsToBounds = true
        topUserInfoView.layer.cornerRadius = 3
        topUserInfoView.isUserInteractionEnabled = true
        topUserInfoView.layer.shadowOffset = CGSize(width: 5, height: 5)
        topUserInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        topUserInfoView.layer.shadowOpacity = 0.5
        topUserInfoView.layer.shadowRadius = 5;//阴影半径，默认3
        
        self.topUserInfoView.sendSubviewToBack(self.backImageView)
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(topUserInfoViewClick(sender:)))
        gesture.cancelsTouchesInView = false
        // 双击事件冲突-- userNameLabel
        for doubleGesture in self.userNameLabel.gestureRecognizers! {
            gesture.require(toFail: doubleGesture)
        }
        // 双击事件冲突-- userCodeLabel
        for doubleGesture in self.userCodeLabel.gestureRecognizers! {
            gesture.require(toFail: doubleGesture)
        }
        self.topUserInfoView.addGestureRecognizer(gesture)
    }
    
    @objc func topUserInfoViewClick(sender: UITapGestureRecognizer) {
//        let personalInfoViewVC = self.storyboard?.instantiateViewController(withIdentifier: "PersonalInfoView") as! PersonalInfoViewController
//        personalInfoViewVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(personalInfoViewVC, animated: true)
    }
    
    func setInitData()  {
        let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        let loginUserName = NSString.verifyString(loginInfo?.userName) == "" ? (loginInfo?.account ?? "") : (loginInfo?.userName ?? "")
        
        headerView.nameLabel.text = loginUserName
        let tempUI = getCardImageAndColor(from: loginUserName)
        headerView.tag = tempUI.colorIndex
        headerView.nameLabel.textColor = tempUI.textColor
        headerView.codeLabel.textColor = tempUI.textColor

        headerView.upImageView.image = tempUI.cardImage
        
        headerView.bottomView.backgroundColor = tempUI.backGroudColor
        let layer: CAGradientLayer = headerView.bgView.layer.sublayers?.first as! CAGradientLayer
        layer.colors = [tempUI.backGroudColor.cgColor, tempUI.backGroudColor.cgColor, tempUI.gradientColor.cgColor]
        
        let terminal = ManagerService.call()?.terminal
        if terminal != nil && !terminal!.isEmpty {
            headerView.codeLabel.text = terminal
        } else {
            headerView.codeLabel.text = loginInfo?.account
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let colors = getBackgroundColor(index: headerView.tag)
        let layer: CAGradientLayer = headerView.bgView.layer.sublayers?.first as! CAGradientLayer
        layer.colors = [colors.backGroudColor.cgColor, colors.backGroudColor.cgColor, colors.gradientColor.cgColor]
    }
    
    @IBAction func searchBarBtnItemClick(_ sender: Any) {
        let companySearchViewVC = CompanySearchViewController()
        companySearchViewVC.hidesBottomBarWhenPushed = true
        companySearchViewVC.searchType = .localContact
        self.navigationController?.pushViewController(companySearchViewVC, animated: true)
    }
    
    @IBAction func addBarBtnItemClick(_ sender: Any) {
        let action1 = YCMenuAction.init(title: tr("发起会议"), image: nil) { [weak self] (sender) in
            guard let self = self else {return}
            CLLog("action1")
            
            // chenfan：断网后的样式
            if WelcomeViewController.checkNetworkWithNoNetworkAlert() { return }
            
            /*
            let storyboard = UIStoryboard.init(name: "CreateMeetingViewController", bundle: nil)
            let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreateMeetingView") as! CreateMeetingViewController
            creatMeetingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(creatMeetingVC, animated: true)*/
            //xiejc 2021-01-05 发起会议，2.0 和 3.0 区分
            if SuspendTool.isMeeting() {
                SessionManager.showMeetingWarning()
                return
            }
            if  ManagerService.call()?.isSMC3 == true {
                let storyboard = UIStoryboard.init(name: "CreatMeetingThreeVersionViewController", bundle: nil)
                let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreatMeetingThreeVersionViewController") as! CreatMeetingThreeVersionViewController
                creatMeetingVC.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(creatMeetingVC, animated: true)
            } else {
                let storyboard = UIStoryboard.init(name: "CreateMeetingViewController", bundle: nil)
                let creatMeetingVC = storyboard.instantiateViewController(withIdentifier: "CreateMeetingView") as! CreateMeetingViewController
                creatMeetingVC.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(creatMeetingVC, animated: true)
            }
        }
        let action2 = YCMenuAction.init(title: tr("添加联系人"), image: nil) { [weak self] (sender) in
            guard let self = self else {return}
            CLLog("action2")
            let addLocalContactVC = AddLocalContactViewController()
            addLocalContactVC.operationType = .addContact
            addLocalContactVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addLocalContactVC, animated: true)
        }
        
        let menu = YCMenuView.menu(with: [action1!, action2!], width: 150.0, relyonView: self.addBarItem)
        
        // config
        menu?.backgroundColor = UIColor.white
        menu?.textAlignment = .center
        menu?.separatorColor = UIColor.colorWithSystem(lightColor: COLOR_SEPARATOR_LINE, darkColor: COLOR_GAY)
        menu?.maxDisplayCount = 20
        menu?.offset = 0
        menu?.textColor = COLOR_DARK_GAY
        menu?.textFont = UIFont.systemFont(ofSize: 16.0)
        menu?.menuCellHeight = 50.0
        menu?.dismissOnselected = true
        menu?.dismissOnTouchOutside = true
        menu?.show()
    }
    
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableImageTextNormalCell.CELL_ID) as! TableImageTextNormalCell
        cell.showImageView.tintColor = COLOR_LIGHT_GAY
        cell.bottomLineView.isHidden = true
        
        // set data
        if indexPath.row == 0 {
            cell.showImageView.image = UIImage.init(named: "mine_setting")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            // set title
            cell.showTitleLabel.text = tr("设置")
        } else if indexPath.row == 1 {
            cell.showImageView.image = UIImage.init(named: "mine_feed")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            // set title
            cell.showTitleLabel.text = tr("问题反馈")
        }
        
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let storyboard = UIStoryboard.init(name: "SettingViewController", bundle: nil)
            let settingViewVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
            settingViewVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingViewVC, animated: true)
        } else if indexPath.row == 1 {
//            let feedBackViewVC =  FeedBackViewController.init()
//            feedBackViewVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(feedBackViewVC, animated: true)
            
            // 反馈
            let fbcVc = FeedBackCommitViewController()
            navigationController?.pushViewController(fbcVc, animated: true)
        }
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableImageTextNormalCell.CELL_HEIGHT
    }
}
