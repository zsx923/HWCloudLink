//
// ContactDetailViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

enum ContactDetailVCType {
    case localContact // 个人
    case companyContact  // 企业
    case favouriteContact
}

enum ContactFromVCType {
    case contactVC // 联系人页面跳转
    case searchVC  // 从企业搜索页面
    case companyVC // 从企业联系人
}

class ContactDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,TextTitleViewDelegate, TableMoreTextCellDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topBgImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userCodeLabel: UILabel!
    
    @IBOutlet weak var voiceBtn: UIButton!
    
    @IBOutlet weak var voiceImageView: UIImageView!
    @IBOutlet weak var videoBtn: UIButton!
        
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    
    @IBOutlet weak var bottomView: UIView!//底部视图
    
    @IBOutlet weak var tableViewBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    var iconImage:UIImage?
    
    var rightBtn :UIButton!
    
    private var isClickVideoBtn: Bool = false
    
    var ldapContactInfo : LdapContactInfo?
    
    var tempContactInfo : LocalContactModel?
    
    var localContactInfo : LocalContactModel?
    
    var contactDetailVC : ContactDetailVCType?
    
    var fromVc: ContactFromVCType?
    
    var name : String?

    var number : String?
    
    var campany : String?
    
    var depart : String?
    
    var post : String?
    
    var eMail : String?
    
    var address : String?
    
    var mobile : String?
    
    var fax : String?
    
    var localContactId : Int?//个人会议ID
    
    fileprivate var currentBgImageName = ""
    
    let sizeIcon = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setViewUI()
        // 初始化
        self.title = ""
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        let rightBtn = UIButton.init()
        rightBtn.setTitleColor(UIColor.colorWithSystem(lightColor: UIColor.black, darkColor: UIColor.white), for: .normal)
        self.rightBtn = rightBtn
        rightBtn.addTarget(self, action: #selector(rightBarBtnItemClick(sender:)), for: UIControl.Event.touchUpInside)
        let rightBarBtnItem = UIBarButtonItem.init(customView: rightBtn)
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        //右侧收藏按钮
        if self.localContactInfo?.type == 1{
            //删除联系人
            self.bottomView.isHidden = false
            self.tableViewBottomConstraints.constant = 84
        }else{
            //收藏
            self.bottomView.isHidden = true
            self.tableViewBottomConstraints.constant = 0
        }
        
        self.tableView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.black)
        // set init data
        self.setInitData()
        
        // set table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: TableMoreTextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableMoreTextCell.CELL_ID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = getNaviImageColor(imageName: currentBgImageName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
    }
    
    func setViewUI() {
        self.iconImageView.image = self.iconImage
        let num = self.getIndexFromIconImage(self.iconImage)
        currentBgImageName = "contact_detail_topbg\(num)"
//        self.topBgImageView.image = UIImage.init(named: currentBgImageName)
        self.topBgImageView.image = nil
        let bgColor = self.getNaviImageColor(imageName: currentBgImageName)
        let bgColorGradient = self.getImageGradientColor(imageName: currentBgImageName)
        let layer = CAGradientLayer.init()
        layer.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: self.topBgImageView.bounds.size.height)
        layer.colors = [bgColor.cgColor, bgColorGradient.cgColor]
        self.topBgImageView.layer.insertSublayer(layer, at: 0)
        
        self.voiceImageView.image = UIImage.init(named: "call_image")?.withRenderingMode(.alwaysTemplate)
        self.voiceImageView.tintColor = UIColor(hexString: "#666666")
        self.videoImageView.image = UIImage.init(named: "cammera")?.withRenderingMode(.alwaysTemplate)
        self.videoImageView.tintColor = UIColor(hexString: "#666666")
        
////        let mostColor = UIImage.mostImageColor(with: self.topBgImageView.image)
//        self.userNameLabel.textColor = COLOR_DARK_GAY
//        self.userCodeLabel.textColor = COLOR_DARK_GAY
        
//        self.voiceBtn.setTopAndBottomImage(UIImage.scal(toSize: UIImage.init(named: "call_image"), size: CGSize.init(width: sizeIcon, height: sizeIcon)), withTitle: "语音", for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: 12.0), andImageTitleGap: 20.0)
//        self.videoBtn.setTopAndBottomImage(UIImage.scal(toSize: UIImage.init(named: "cammera"), size: CGSize.init(width: sizeIcon, height: sizeIcon)), withTitle: "视频", for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: 12.0), andImageTitleGap: 20.0)
        
//        self.voiceBtn.setTopAndBottomImage(UIImage.init(named: "call_image"), withTitle: "语音", for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: 12.0), andImageTitleGap: 20.0)
//        self.videoBtn.setTopAndBottomImage(UIImage.init(named: "cammera"), withTitle: "视频", for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: 12.0), andImageTitleGap: 20.0)
    }
    
    func getIndexFromIconImage(_ image: UIImage?) -> Int {
        guard let img = image, let imgName = img.accessibilityIdentifier else {
            return 1
        }
        var index: Int = 1
        if imgName.hasPrefix("num-") || imgName.hasPrefix("symbol-") {
            let str = String(imgName.last ?? "1")
            index = Int(str) ?? 1
        } else {
            // A-Z
            if imgName.last == "1" || imgName.last == "2" || imgName.last == "3" {
                let str = String(imgName.last ?? "1")
                index = Int(str) ?? 1
                index += 1
            } else {
                index = 1
            }
        }
        return index
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let bgColor = self.getNaviImageColor(imageName: self.currentBgImageName)
        let bgColorGradient = self.getImageGradientColor(imageName: self.currentBgImageName)
        let layer: CAGradientLayer = self.topBgImageView.layer.sublayers?.first as! CAGradientLayer
        layer.colors = [bgColor.cgColor, bgColorGradient.cgColor]
    }
    
    func setInitData()  {
        switch fromVc {
        //本地联系人页面
        case .contactVC:
            self.number = self.localContactInfo!.number
            self.name = self.localContactInfo!.name
            self.campany = self.localContactInfo!.campany
            self.depart = self.localContactInfo!.depart
            self.post = self.localContactInfo!.post
            self.eMail = self.localContactInfo!.eMail
            self.address = self.localContactInfo!.address
            self.mobile = self.localContactInfo?.mobile
            self.fax = self.localContactInfo?.fax
            self.localContactId = self.localContactInfo?.localContactId //主键key
        break
        default:
            self.number = self.ldapContactInfo!.ucAcc
            self.name = self.ldapContactInfo!.name
            self.campany = self.ldapContactInfo!.corpName
//          self.depart = LdapContactInfo.getDeptName(ldapContactInfo?.corpName)
            self.depart = ldapContactInfo?.deptName
            self.post = self.ldapContactInfo!.duty
            self.eMail = self.ldapContactInfo!.email
            self.address = self.ldapContactInfo!.address
            self.mobile = self.ldapContactInfo!.mobile
            self.fax = self.ldapContactInfo!.fax
//            self.localContactId = self.ldapContactInfo?.confid
            break
        }
        
        
        
        
//        switch contactDetailVC {
//        case .localContact:
//            self.number = self.localContactInfo!.number
//            self.name = self.localContactInfo!.name
//            self.campany = self.localContactInfo!.campany
//            self.depart = self.localContactInfo!.depart
//            self.post = self.localContactInfo!.post
//            self.eMail = self.localContactInfo!.eMail
//            self.address = self.localContactInfo!.address
//            self.mobile = self.localContactInfo?.mobile
//            self.fax = self.localContactInfo?.fax
//            break;
//        case .companyContact:
//            self.number = self.ldapContactInfo!.ucAcc
//            self.name = self.ldapContactInfo!.name
//            self.campany = self.ldapContactInfo!.corpName
////            self.depart = LdapContactInfo.getDeptName(ldapContactInfo?.corpName)
//            self.depart = ldapContactInfo?.deptName
//            self.post = self.ldapContactInfo!.duty
//            self.eMail = self.ldapContactInfo!.email
//            self.address = self.ldapContactInfo!.address
//            self.mobile = self.ldapContactInfo!.mobile
//            self.fax = self.ldapContactInfo!.fax
//            break;
//        default:
//            break;
//        }
        LocalContactBusiness.shareInstance.selectLocalContact(number: self.number!, name: self.name!,complete:{ (arr) in
//            self.likeButton.isHidden = false
            if arr.count == 0{
                self.likeButton.tag = 1
                self.rightBtn.tag = 1
//                self.rightBtn .setTitle("收藏", for: .normal)
                self.rightBtn.setImage(UIImage.init(named: "icon_uncollect"), for: .normal)
                self.likeButton.setTitle(tr("收藏联系人"), for: .normal)
                self.likeButton.backgroundColor = COLOR_BLUE
            }else{
                self.tempContactInfo = arr[0]
                self.likeButton.tag = 2
                self.rightBtn.tag = 2
                if self.localContactInfo?.type == 1 {
//                    self.rightBtn.setImageName(normalImg: "icon_edit_default", pressImg: "icon_edit_press", title: "")
                    self.rightBtn.setImage(UIImage.init(named: "icon_edit_default"), for: .normal)
                    self.rightBtn.setImage(UIImage.init(named: "icon_edit_press"), for: .highlighted)
                    self.likeButton.setTitle(tr("删除联系人"), for: .normal)
                }else{
                    self.likeButton.setImage(UIImage.init(named: "icon_collect"), for: .selected)
                    self.likeButton.setTitle(tr("取消收藏"), for: .normal)
//                    self.rightBtn .setTitle("取消", for: .normal)
                    self.rightBtn.setImage(UIImage.init(named: "icon_collect"), for: .normal)
                }
                self.likeButton.backgroundColor = COLOR_RED
            }
        })
        // set name
        self.userNameLabel.text = self.name
        // set code
        self.userCodeLabel.text = self.number
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:收藏按钮
    @objc func rightBarBtnItemClick(sender: UIButton) {
        if self.localContactInfo?.type == 1{
            //编辑联系人
            let addLocalContactVC =  AddLocalContactViewController.init()
            addLocalContactVC.operationType = .editContact
            let editModel = LocalContactModel.init()
            editModel.name = self.name
            editModel.number = self.number
            editModel.post = self.post //个人会议ID
            editModel.mobile = self.mobile
            editModel.eMail = self.eMail
            editModel.depart = self.depart
            editModel.localContactId = self.localContactId
            addLocalContactVC.editModel = editModel

            //编辑后返回值
            addLocalContactVC.editBackBlock = { [weak self] (model) in
                guard let self = self else {return}
                //单独处理顶部视图
                self.name = model.name
                self.userNameLabel.text = model.name
                //topImageView
                let image = getUserIconWithAZ(name: model.name ?? "")
                let num = self.getIndexFromIconImage(image)
                self.currentBgImageName = "contact_detail_topbg\(num)"
                self.iconImageView.image = image
                let bgColor = self.getNaviImageColor(imageName: "contact_detail_topbg\(num)")
                let bgColorGradient = self.getImageGradientColor(imageName: "contact_detail_topbg\(num)")
                let layer = CAGradientLayer.init()
                layer.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: self.topBgImageView.bounds.size.height)
                layer.colors = [bgColor.cgColor, bgColorGradient.cgColor]
                self.topBgImageView.layer.addSublayer(layer)
       
                self.number = model.number
                self.post = model.post
                self.mobile = model.mobile
                self.eMail = model.eMail
                self.depart = model.depart
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(addLocalContactVC, animated: true)
        }else{
            //收藏
            likeContactBtnClick(sender)
        }
    }
    
    @IBAction func voiceBtnClick(_ sender: UIButton) {
        isClickVideoBtn = false
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        SessionManager.shared.startCall(isVideo: false, name: self.name ?? "", number: self.number ?? "", depart: self.depart ?? "")
    }
    
    @IBAction func videoBtnClick(_ sender: UIButton) {
        isClickVideoBtn = true
        if !HWAuthorizationManager.shareInstanst.isAuthorizeCameraphone() {
            self.getAuthAlertWithAccessibilityValue(value: "10")
            return
        }
        if !HWAuthorizationManager.shareInstanst.isAuthorizeToMicrophone() {
            self.getAuthAlertWithAccessibilityValue(value: "20")
            return
        }
        SessionManager.shared.startCall(isVideo: true, name: self.name ?? "", number: self.number ?? "", depart: self.depart ?? "")
    }
    
    @IBAction func shareBtnClick(_ sender: UIButton) {
        
    }

    @IBAction func likeContactBtnClick(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            addFavouriteLdapContact()
            self.setInitData()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.navigationController?.popViewController(animated: true)
//            }
            break;
        case 2:
            getAuthAlertWithAccessibilityValue(value: "")
            break;
        default:
            break
        }
        
    }
    //收藏联系人
    func addFavouriteLdapContact(){
        let localContactModel =  LocalContactModel.init()
        switch fromVc {
        case .contactVC:
            localContactModel.name = localContactInfo?.name
            localContactModel.number = localContactInfo?.number
            localContactModel.address = localContactInfo?.address
            localContactModel.campany = localContactInfo?.campany
            localContactModel.depart = localContactInfo?.depart
            localContactModel.firstCharactor = localContactInfo?.firstCharactor
            localContactModel.post = localContactInfo?.post
            localContactModel.eMail = localContactInfo?.eMail
            localContactModel.mobile = localContactInfo?.mobile
            localContactModel.fax = localContactInfo?.fax
            localContactModel.remark = localContactInfo?.remark
            localContactModel.type = 2
            break
        default:
            localContactModel.name = ldapContactInfo?.name
            localContactModel.number = ldapContactInfo?.ucAcc
            localContactModel.address = ldapContactInfo?.address
            localContactModel.campany = ldapContactInfo?.corpName
    //        localContactModel.depart = LdapContactInfo.getDeptName(ldapContactInfo?.corpName)
            localContactModel.depart = ldapContactInfo?.deptName
            localContactModel.firstCharactor = localContactModel.getFirstCharactor(name: ldapContactInfo!.name)
            localContactModel.post = ldapContactInfo?.duty
            localContactModel.eMail = ldapContactInfo?.email
            localContactModel.mobile = ldapContactInfo?.mobile
            localContactModel.fax = ldapContactInfo?.fax
            localContactModel.remark = ldapContactInfo?.uri
            localContactModel.type = 2
            break
        }
        
        LocalContactBusiness.shareInstance.insertLocalContact(localContactModel: localContactModel) { (res) in
            if res{
                MBProgressHUD.showBottom(tr("收藏联系人成功"), icon: nil, view: self.view)
                self.setInitData()
            }else{
                MBProgressHUD.showBottom(tr("收藏联系人失败"), icon: nil, view: self.view)
            }
        }
    }

    private func getAuthAlertWithAccessibilityValue(value: String) {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = value
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    private func sureDeleteContact() {
        LocalContactBusiness.shareInstance.deleteLocalContact(id: (tempContactInfo!.localContactId)!) { (res) in
            if res{
                if self.localContactInfo?.type == 1 {
                    //添加到view上只在当前页面, 为nil时会在window上显示
                    MBProgressHUD.showBottom(tr("删除联系人成功"), icon: nil, view: nil)
//                    self.likeButton.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }else{
                    MBProgressHUD.showBottom(tr("取消收藏联系人成功"), icon: nil, view: self.view)
                    // 重新刷新页面
                    self.setInitData()
//                    self.likeButton.tag = 1
//                    self.likeButton.setTitle("收藏联系人", for: .normal)
//                    self.likeButton.backgroundColor = COLOR_BLUE
//                    self.likeButton.isHidden = false
                }
                
            }else{
                if self.localContactInfo?.type == 1 {
                    MBProgressHUD.showBottom(tr("删除联系人失败"), icon: nil, view: self.view)
                }else{
                    MBProgressHUD.showBottom(tr("取消收藏联系人失败"), icon: nil, view: self.view)
                }
            }
        }
    }
    // MARK: - TextTitleViewDelegate
    // MARK: view did load
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "10" {
            viewVC.showTitleLabel.text = tr("视频呼叫需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        } else if viewVC.accessibilityValue == "20" {
            viewVC.showTitleLabel.text = tr("语音呼叫需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        } else {
            if self.localContactInfo?.type == 1 {
                viewVC.showTitleLabel.text = tr("是否删除该联系人？")
            }else{
                viewVC.showTitleLabel.text = tr("是否取消收藏该联系人？")
            }
           viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
           viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
            viewVC.showRightBtn.setTitleColor(COLOR_RED, for: .normal)
        }
    }
       
    // MARK: left btn click
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
    }
       
    // MARK: right btn click
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        if viewVC.accessibilityValue == "10" || viewVC.accessibilityValue == "20" {
            viewVC.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            return
        }
        self.sureDeleteContact()
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
//        return contactDetailVC == .companyContact ? 3 : 2
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
            return 4
            case 1:
            return 1
            default:
            return 0
        }
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableMoreTextCell.CELL_ID) as! TableMoreTextCell
        
//        if indexPath.section == 0 && indexPath.row == 0 {
//            cell.selectionStyle = .none
//            cell.showSubTitleLabel.text = "姓名"
//            cell.showTitleLabel.text = self.name
////            cell.showNextImageView.image = UIImage(named: "arrow_next")
////            cell.showNextImageView.isHidden = false
//            if self.contactDetailVC != nil && self.contactDetailVC == ContactDetailVCType.companyContact {
//                cell.selectionStyle = .none
//                cell.showNextImageView.isHidden = true
//            }
//
//            return cell
//        }
//
//        cell.selectionStyle = .none
////        if indexPath.section == 1 && indexPath.row == 0 {
////            cell.showSubTitleLabel.text = "职位"
////            cell.showTitleLabel.text = self.post
////        }
//        if indexPath.section == 1 && indexPath.row == 0 {
//            cell.showSubTitleLabel.text = "部门"
//            cell.showTitleLabel.text = self.depart
//        }
//        if indexPath.section == 2 && indexPath.row == 0 {
//            cell.showSubTitleLabel.text = "终端号码"
//            cell.showTitleLabel.text = self.number
//            cell.showNextImageView.isHidden = false
//        }
//        if indexPath.section == 2 && indexPath.row == 1 {
//            cell.showSubTitleLabel.text = "手机号码"
//            cell.showTitleLabel.text = self.mobile
//        }
////        if indexPath.section == 2 && indexPath.row == 2 {
////            cell.showSubTitleLabel.text = "传真"
////            cell.showTitleLabel.text = self.fax
////        }
//        if indexPath.section == 2 && indexPath.row == 2 {
//            cell.showSubTitleLabel.text = "邮箱"
//            cell.showTitleLabel.text = self.eMail
//        }
       
        //变更UCD
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.showSubTitleLabel.text = tr("终端号码")
                cell.showTitleLabel.text = self.number
                cell.callBtn.isHidden = false
                cell.videoBtn.isHidden = false
                cell.cellBtnDelegate = self
            }
            if indexPath.row == 1 {
                cell.showSubTitleLabel.text = tr("个人会议ID")
                cell.showTitleLabel.text = NSString.dealMeetingId(withSpaceString: self.post)
            }
            if indexPath.row == 2 {
                cell.showSubTitleLabel.text = tr("手机号码")
                cell.showTitleLabel.text = self.mobile
            }
            
            if indexPath.row == 3 {
                cell.showSubTitleLabel.text = tr("邮箱")
                cell.showTitleLabel.text = self.eMail
            }
        }else{
            cell.showSubTitleLabel.text = tr("部门")
            cell.showTitleLabel.text = self.depart
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! TableMoreTextCell
          
        
        if indexPath.row == 0 && indexPath.section == 0 {
//            return
//            if self.contactDetailVC != nil && self.contactDetailVC == ContactDetailVCType.companyContact {
//                return
//            }
//            let modifyOneTxtVC = ModifyOneTextViewController()
//            modifyOneTxtVC.textCallBack = {[weak self] str in
//                //修改备注的回调
//                self?.name = str;
//                self?.userNameLabel.text = self?.name
//                self?.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
//            }
//            modifyOneTxtVC.localContactInfo = self.localContactInfo
//            modifyOneTxtVC.name = self.name ?? ""
//            self.navigationController?.pushViewController(modifyOneTxtVC, animated: true)
        }
        
//        if indexPath.section == 1 && indexPath.row == 0 {
//            if SuspendTool.isMeeting() {
//                MBProgressHUD.showBottom("目前前正在会议中", icon: "", view: nil)
//                return
//            }
//            SessionManager.shared.showCallSelectView(name: self.name!, number: self.number!, depart: self.depart!, vc: self)
//        }
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //变更UCD
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return (self.number != nil && self.number?.count != 0) ? TableMoreTextCell.CELL_HEIGHT : 0.01
            } else if indexPath.row == 1 {
                return (self.post != nil && self.post?.count != 0) ? TableMoreTextCell.CELL_HEIGHT : 0.01
            } else if indexPath.row == 2 {
                return (self.mobile != nil && self.mobile?.count != 0) ? TableMoreTextCell.CELL_HEIGHT : 0.01
            } else if indexPath.row == 3 {
                return (self.eMail != nil && self.eMail?.count != 0) ? TableMoreTextCell.CELL_HEIGHT : 0.01
            } else {
                return 0.01
            }
        }else{
            return (self.depart != nil && self.depart?.count != 0) ? TableMoreTextCell.CELL_HEIGHT : 0.01
        }
    }
    
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "#fafafa"), darkColor: UIColor(hexString: "#1a1a1a"))
        return headerView
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }
        return (self.depart != nil && self.depart?.count != 0) ? 10 : 0.1
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 100.0 {
            self.navigationController?.navigationBar.barTintColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.clear)
            self.title = self.userNameLabel.text
        } else {
            self.navigationController?.navigationBar.barTintColor = getNaviImageColor(imageName: currentBgImageName)
            self.title = ""
        }
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getNaviImageColor(imageName: String) -> UIColor {
        switch imageName {
        case "contact_detail_topbg1":
            return UIColor.colorWithSystem(lightColor: "#FFFBEB", darkColor: "#201C19")
        case "contact_detail_topbg2":
            return UIColor.colorWithSystem(lightColor: "#EBFFFD", darkColor: "#191B20")
        case "contact_detail_topbg3":
            return UIColor.colorWithSystem(lightColor: "#F3EBFF", darkColor: "#20191E")
        case "contact_detail_topbg4":
            return UIColor.colorWithSystem(lightColor: "#F1FFF7", darkColor: "#19201B")
        default:
            return UIColor.white
        }
    }
    
    func getImageGradientColor(imageName: String) -> UIColor {
        switch imageName {
        case "contact_detail_topbg1":
            return UIColor.colorWithSystem(lightColor: "#FFF6F1", darkColor: "#201C19")
        case "contact_detail_topbg2":
            return UIColor.colorWithSystem(lightColor: "#F1F9FF", darkColor: "#191B20")
        case "contact_detail_topbg3":
            return UIColor.colorWithSystem(lightColor: "#F1F1FF", darkColor: "#20191E")
        case "contact_detail_topbg4":
            return UIColor.colorWithSystem(lightColor: "#F1FFF7", darkColor: "#19201B")
        default:
            return UIColor.white
        }
    }
    
     //MARK TableMoreTextCellDelegate
    func TableMoreTextCellCallBtnClick() {
        voiceBtnClick(UIButton.init())
    }
    
    func TableMoreTextCellVideoBtnClick() {
        videoBtnClick(UIButton.init())
    }
    
}
