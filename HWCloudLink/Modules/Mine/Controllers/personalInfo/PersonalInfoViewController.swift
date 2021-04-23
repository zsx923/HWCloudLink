//
// PersonalInfoViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UITableViewController {
    static let CELL_HEIGHT: CGFloat = 72.0

    var userInfo: LdapContactInfo?
    // 姓名
    @IBOutlet weak var userNameTitle: UILabel!
    @IBOutlet weak var userName: UILabel!
    // 部门
    @IBOutlet weak var userDepartmentTitle: UILabel!
    @IBOutlet weak var userDepartment: UILabel!
    // 终端号码
    @IBOutlet weak var clientNumTitle: UILabel!
    @IBOutlet weak var clientNum: UILabel!
    // 个人会议ID
    @IBOutlet weak var meetingIDTitle: UILabel!
    @IBOutlet weak var meetingID: UILabel!
    // 手机号码
    @IBOutlet weak var phoneNumTitle: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    // 邮箱
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var email: UILabel!
    
    private var hasVMR = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("个人信息")
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.userNameTitle.text = tr("姓名")
        self.userDepartmentTitle.text = tr("部门")
        self.clientNumTitle.text = tr("终端号码")
        self.meetingIDTitle.text = tr("个人会议ID")
        self.phoneNumTitle.text = tr("手机号码")
        self.emailTitle.text = tr("邮箱")

        // 设置个人信息
        self.userName.text = userInfo?.name
        self.userDepartment.text = userInfo?.deptName
        self.clientNum.text = userInfo?.ucAcc
        self.phoneNum.text = userInfo?.mobile
        self.email.text = userInfo?.email
        
        // 获取vmr信息
        self.getVMRUserInfoList()
    }

    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return NSString.verifyString(self.userName.text) == "" ? 0.01 : PersonalInfoViewController.CELL_HEIGHT
        case 1:
            return NSString.verifyString(self.userDepartment.text) == "" ? 0.01 : PersonalInfoViewController.CELL_HEIGHT
        case 2:
            return NSString.verifyString(self.clientNum.text) == "" ? 0.01 : PersonalInfoViewController.CELL_HEIGHT
        case 3:
            return !hasVMR ? 0.01 : PersonalInfoViewController.CELL_HEIGHT
        case 4:
            return NSString.verifyString(self.phoneNum.text) == "" ? 0.01 : PersonalInfoViewController.CELL_HEIGHT
        case 5:
            return NSString.verifyString(self.email .text) == "" ? 0.01 : PersonalInfoViewController.CELL_HEIGHT
        default:
            return PersonalInfoViewController.CELL_HEIGHT
        }
    }
    
    //MARK: - 获取用户vmr信息
    private func getVMRUserInfoList() {
        guard ManagerService.confService()?.vmrBaseInfo.accessNumber?.count ?? 0 > 0 else {
            CLLog("3.0 当前账号无VMR信息")
            hasVMR = false
            self.tableView.reloadData()
            return
        }
        hasVMR = true
        self.meetingID.text = NSString.dealMeetingId(withSpaceString: ManagerService.confService()?.vmrBaseInfo.accessNumber ?? "")
        self.tableView.reloadData()
    }
}
