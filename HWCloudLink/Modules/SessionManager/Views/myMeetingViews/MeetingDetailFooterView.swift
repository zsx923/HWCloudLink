//
//  MeetingDetailFooterView.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2021/2/20.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class MeetingDetailFooterView: UIView {
    
    @IBOutlet weak var cancelMeetingBtn: UIButton!
    @IBOutlet weak var joinMeetingBtn: UIButton!
    
    func setButtonStyle(isActive: Bool, isConvener: Bool = false, isShowJoinBtn: Bool = false) {

        cancelMeetingBtn.layer.borderColor = UIColor(hexString: "#F34B4B")?.cgColor
        cancelMeetingBtn.layer.borderWidth = 0.5*2
        cancelMeetingBtn.setTitle(tr("取消会议"), for: UIControl.State.normal)
        cancelMeetingBtn.setTitleColor(UIColor(hexString: "#F34B4B"), for: UIControl.State.normal)
        
        if ManagerService.call()?.isSMC3 == false { // SMC 2.0
            cancelMeetingBtn.isHidden = true
        } else { // SMC 3.0
            if !isActive { // 预约会议
                // 召集人或者会议管理员可以取消会议
                if isConvener || ManagerService.loginService()?.userType == "confAdmin" {
                    cancelMeetingBtn.isHidden = false
                } else {
                    cancelMeetingBtn.isHidden = true
                }
            } else { // 正在开会
                cancelMeetingBtn.isHidden = true
            }
        }
        
        joinMeetingBtn.setTitle(tr("加入会议"), for: .normal)
        if !(ManagerService.call()?.isSMC3 ?? false) { // SMC 2.0
            joinMeetingBtn.isEnabled = isShowJoinBtn
            joinMeetingBtn.backgroundColor = isShowJoinBtn ? UIColor.colorWithSystem(lightColor: "#0D94FF", darkColor: "#0D94FF") : UIColor.colorWithSystem(lightColor: "#cccccc", darkColor: "#222222")
            joinMeetingBtn.setTitleColor(isShowJoinBtn ? UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#ffffff") : UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#666666"), for: .normal)
        } else { // SMC 3.0
            if !isActive { // 预约会议
                joinMeetingBtn.isEnabled = false
                joinMeetingBtn.backgroundColor = UIColor.colorWithSystem(lightColor: "#cccccc", darkColor: "#222222")
                joinMeetingBtn.setTitleColor(UIColor.colorWithSystem(lightColor: "#ffffff", darkColor: "#666666"), for: .normal)
            } else { // 正在开会
                joinMeetingBtn.isEnabled = true
                joinMeetingBtn.backgroundColor = UIColor(hexString: "#0D94FF")
                joinMeetingBtn.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
            }
        }
    }

    class func detailFooterView() -> MeetingDetailFooterView {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! MeetingDetailFooterView
    }
}

