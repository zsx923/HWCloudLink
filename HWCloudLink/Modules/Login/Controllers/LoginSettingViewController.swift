//
// LoginSettingViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class LoginSettingViewController: UITableViewController {

    // 服务器设置
    @IBOutlet weak var ServerSetting: UILabel!
    // 问题反馈
    @IBOutlet weak var questionFeedback: UILabel!
    // 版权说明
    @IBOutlet weak var VersionExplain: UILabel!
    // 隐私声明
    @IBOutlet weak var PrivateExplain: UILabel!

    let sectionTitles : Array = [tr("基本设置"), tr("故障报告"), tr("关于")]
    let rowTitles : Dictionary<String, Array<String>> = [
        tr("基本设置") : [tr("服务器设置")],
        tr("故障报告") : [tr("问题反馈")],
        tr("关于") : [tr("版权说明"), tr("隐私声明")]
    ]
    
    private var pingTester: WHPingTester?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        self.title = tr("登录设置")
        self.setViewUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - 初始化UI相关
    func setViewUI() {
        // 初始化文字
        self.ServerSetting.text = tr("服务器设置")
        self.questionFeedback.text = tr("问题反馈")
        self.VersionExplain.text = tr("版权说明")
        self.PrivateExplain.text = tr("隐私声明")

        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(leftBarBtnItemClick(sender:))
        )
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

        // tableView
        self.tableView.separatorStyle = .none
    }
    
    // MARK: - left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.00
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let titleView = view as? UITableViewHeaderFooterView
        // 国际化处理
        titleView?.textLabel?.text = tr(sectionTitles[section])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 && indexPath.row == 0 { // 服务器设置
            let storyboard = UIStoryboard.init(name: "ServerSettingViewController", bundle: nil);
            let serverSettingViewVC = storyboard.instantiateViewController(withIdentifier:
                "ServerSettingView") as! ServerSettingViewController
            serverSettingViewVC.saveCallBack = { (serverAddr: String) in
                // ping局域网
                self.pingTester = WHPingTester(hostName: serverAddr)
                self.pingTester?.delegate = self
                self.pingTester?.startPing()
            }
            self.navigationController?.pushViewController(serverSettingViewVC, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 { // 问题反馈
            let feedback = FeedBackCommitViewController()
            navigationController?.pushViewController(feedback, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 0 { // 版权说明
            let VersionExplainVC = VersionExplainViewController.init()
            self.navigationController?.pushViewController(VersionExplainVC, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 1 { // 隐私声明
            let privateExplainVC = PrivateExplainViewController.init()
            self.navigationController?.pushViewController(privateExplainVC, animated: true)
        }
    }
    
    deinit {
        CLLog("LoginSettingViewController deinit")
    }
}

extension LoginSettingViewController: WHPingDelegate {
    func didPingSucccess(withTime time: Float, withError error: Error!) {
        if error != nil {
            CLLog("局域网不能ping通")
        } else {
            CLLog("局域网可以ping通")
        }
        pingTester?.stopPing()
    }
}
