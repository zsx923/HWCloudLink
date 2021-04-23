//
// WLANCallSetViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class WLANCallSetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let listArray = [
        [
            "name": tr("图像质量优先"),
            "describe": tr("（需稳定网络）"),
            "value": 1
        ],
        [
            "name": tr("流畅优先"),
            "describe": tr("（推荐）"),
            "value": 2
        ]
    ]
    var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        self.title = tr("清晰度设置")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // table view
        tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.view.addSubview(tableView!)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#000000")
        self.tableView!.register(UINib.init(nibName: TableTitleSymbolCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTitleSymbolCell.CELL_ID)
        // 去分割线
        self.tableView!.separatorStyle = .none
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableTitleSymbolCell.CELL_HEIGHT
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableTitleSymbolCell.CELL_ID) as! TableTitleSymbolCell
        cell.backgroundColor = UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#000000")
        let dic = listArray[indexPath.row]
        cell.showTitleLabel.text = dic["name"] as? String
        cell.describeLabel.text = dic["describe"] as? String
        cell.isHiddenDescribe = false
        let policy = dic["value"] as? Int

        let value = UserSettingBusiness.shareInstance.getUserVideoPolicy()
        if policy == value {
            cell.showRightImageView.image = UIImage.init(named: "selected_icon")
        } else {
            cell.showRightImageView.image = UIImage.init()
        }
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if SuspendTool.isMeeting() {
            MBProgressHUD.showBottom(tr("无法修改"), icon: "", view: nil)
            return
        }
        
        let dic = listArray[indexPath.row]
        let policy = dic["value"] as? Int ?? 1
        UserSettingBusiness.shareInstance.updateUserSettingVideoPolicy(videpDefinitionPolicy: policy) { (res) in
            if res {
                CLLog("更新成功 -success")
                let bool = ManagerService.call()?.setVideoDefinitionPolicy(policy) ?? false
                if bool {
                    CLLog("视频清晰度更新成功 -success")
                    MBProgressHUD.showBottom(tr("视频清晰度更新成功"), icon: nil, view: self.view)
                    ManagerService.call()?.definition = policy
                }
            } else {
                CLLog("failed")
                MBProgressHUD.showBottom(tr("视频清晰度更新失败"), icon: nil, view: self.view)
            }
        }
        tableView.reloadData()
    }
    
   // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
