//
// AdvanceSetViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class AdvanceSetViewController: UITableViewController {
    
    @IBOutlet weak var microphoneTitleLabel: UILabel!
    
    @IBOutlet weak var microphoneSwitch: UISwitch!
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    @IBOutlet weak var videoSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化
        self.title = tr("高级设置")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // table view
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        // 去分割线
        self.tableView.separatorStyle = .none
        initDate()
    }
    
    func initDate() {
        let microphoneSwitch = UserDefaults.standard.bool(forKey: DICT_SAVE_MICROPHONE_IS_ON)
        self.microphoneSwitch.isOn = microphoneSwitch
        let videoSwitch = UserDefaults.standard.bool(forKey: DICT_SAVE_VIDEO_IS_ON)
        self.videoSwitch.isOn = videoSwitch
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        UserDefaults.standard.set(self.microphoneSwitch.isOn, forKey: DICT_SAVE_MICROPHONE_IS_ON)
        UserDefaults.standard.set(self.videoSwitch.isOn, forKey: DICT_SAVE_VIDEO_IS_ON)
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.00
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
