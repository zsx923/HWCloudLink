//
//  GeneralSettingsController.swift
//  HWCloudLink
//
//  Created by cos on 2021/1/12.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class GeneralSettingsController: UITableViewController {
    @IBOutlet weak var distinctLabel: UILabel!

    @IBOutlet weak var claritySettingTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("通用设置")
        self.claritySettingTitle.text = tr("清晰度设置")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

        // 是否正在会议状态的变更通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentMeetingChangedNotification(notfic:)),
                                               name: NOTIFICATION_CURRENT_MEETING_STATUS_CHANGED,
                                               object: nil)
        
        self.distinctLabel.textColor = SessionManager.shared.isCurrentMeeting ? COLOR_LIGHT_GAY : UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
    }
    
    // 是否当前正在会议中或点对点状态变更通知
    @objc func currentMeetingChangedNotification(notfic:Notification) {
        guard let isCurrentMeeting = notfic.object as? Bool else {
            return
        }
        self.distinctLabel.textColor = isCurrentMeeting ? COLOR_LIGHT_GAY : UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
    }
    
    // MARK: - click 返回按钮
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 54.0
        } else {
            return 0.01 // 隐藏：检测到啸叫自动静音 和 共享时屏蔽消息弹窗
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if !SessionManager.shared.isCurrentMeeting {
                let vc = WLANCallSetViewController.init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            
        }
    }
}
