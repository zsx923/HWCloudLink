//
// TableJoinUserCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class JoinUserSVCTableViewCell: UITableViewCell {
    
    static let CELL_ID = "JoinUserSVCTableViewCell"
    
    static let CELL_HEIGHT: CGFloat = 72.0

    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
        
    @IBOutlet weak var showVoiceBtn: UIButton!
    
    @IBOutlet weak var showHandUpBtn: UIButton!
    
    @IBOutlet weak var showTitleVCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showTitleRightConstraint: NSLayoutConstraint!
    
    // 加载会议
    func loadData(confAttendInfo:ConfAttendeeInConf, speakersArray:[ConfCtrlSpeaker]) {
        // set image
        self.showImageView.image = getUserIconWithAZ(name: confAttendInfo.name)
        
        // set title
        let nameStr:String = confAttendInfo.name + (confAttendInfo.isSelf ? "（\(tr("我"))）" : "")
        let codeStr:String = confAttendInfo.number
        self.showTitleLabel.text = "\(nameStr) \(codeStr)"
        
        let strStyle = NSMutableAttributedString.init(string: self.showTitleLabel.text ?? "")
        strStyle.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0), range: NSRange.init(location: nameStr.count + 1, length: codeStr.count))
        strStyle.addAttribute(.foregroundColor, value: COLOR_GAY, range: NSRange.init(location: nameStr.count + 1, length: codeStr.count))

        self.showTitleLabel.attributedText = strStyle
        
        // set subtitle
        var subTitle = ""
        if confAttendInfo.role == CONFCTRL_CONF_ROLE.CONF_ROLE_CHAIRMAN {
            // 主持人
            subTitle = tr("主持人")
        } else  {
            // 与会者
            subTitle = ""
        }
        
        // 是否广播
        if confAttendInfo.isBroadcast {
            subTitle += subTitle.count > 0 ? " | \(tr("广播"))" : tr("广播")
        }
        
//        // 正在发言
//        for speaker in speakersArray {
//            if NSString.getSipaccount(speaker.number) == NSString.getSipaccount(confAttendInfo.number) && speaker.is_speaking {
//                subTitle += subTitle.count > 0 ? " | 正在发言" : "正在发言"
//                break
//            }
//        }
        
        //是否正在选看
//        if confAttendInfo.hasBeWatch {
//            subTitle += subTitle.count > 0 ? " | \(tr("选看"))" : tr("选看")
//        }
        
        // 是否静音
        self.setMuteVoice(isMute: confAttendInfo.is_mute)
        
        // 是否举手
        self.setHandUp(isHandup: confAttendInfo.hand_state)
        CLLog("当前与会者是否举手：name:\(NSString.encryptNumber(with: nameStr) ?? "") hand_state:\(confAttendInfo.hand_state)")
        // 与会者状态
        switch confAttendInfo.state {
        case ATTENDEE_STATUS_IN_CONF:
            CLLog("正在会议中")
        case ATTENDEE_STATUS_CALLING:
            CLLog("正在呼叫")
            subTitle = tr("正在呼叫")
        case ATTENDEE_STATUS_JOINING:
            CLLog("正在加入")
            subTitle = tr("正在加入")
        case ATTENDEE_STATUS_LEAVED:
            CLLog("离开")
            subTitle = tr("已挂断")
            subTitle = ""
            self.setMuteVoice(isMute: true)
            self.setHangUp()
            self.setHandUp(isHandup: false)
        case ATTENDEE_STATUS_NO_EXIST:
            CLLog("用户不存在")
            subTitle = tr("用户不存在")
            self.setMuteVoice(isMute: true)
        case ATTENDEE_STATUS_BUSY:
            CLLog("正在忙")
            subTitle = tr("正在忙")
        case ATTENDEE_STATUS_NO_ANSWER:
             CLLog("未应答")
            subTitle = tr("未应答")
            self.setMuteVoice(isMute: true)
        case ATTENDEE_STATUS_REJECT:
             CLLog("拒绝")
            subTitle = tr("拒绝加入")
            self.setMuteVoice(isMute: true)
        case ATTENDEE_STATUS_CALL_FAILED:
             CLLog("呼叫失败")
            subTitle = tr("呼叫失败")
            self.setMuteVoice(isMute: true)
        default:
            CLLog("not define.")
        }
        
        if subTitle == tr("已挂断") {
            self.showSubTitleLabel.textColor = UIColor.red
        }else {
            self.showSubTitleLabel.textColor = UIColor.init(hexString: "#999999")
        }
        self.showSubTitleLabel.text = subTitle
        self.setTitleStyle(isTitleCenter: self.showSubTitleLabel.text == "")
    }
    
    // 设置title样式位置
    func setTitleStyle(isTitleCenter: Bool) {
        if isTitleCenter {
            self.showTitleVCenterConstraint.constant = 0
            self.showSubTitleLabel.isHidden = true
        } else {
            self.showTitleVCenterConstraint.constant = -12
            self.showSubTitleLabel.isHidden = false
        }
    }
    
    // 设置是否静音
    func setMuteVoice(isMute: Bool) {
        if isMute {
            self.showVoiceBtn.setImage(UIImage.init(named: "icon_mute2_disabled"), for: .normal)
        } else {
            self.showVoiceBtn.setImage(UIImage.init(named: "icon_mute1_disabled"), for: .normal)
        }
    }
    
    // 设置显示挂断按钮
    func setHangUp() {
        self.showVoiceBtn.setImage(UIImage.init(named: "sites_listicon_hangup"), for: .normal)
    }
    
    // 设置举手
    func setHandUp(isHandup: Bool) {
        self.showHandUpBtn.isHidden = !isHandup
        self.showTitleRightConstraint.constant = self.showHandUpBtn.isHidden ? -50 : 5
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showHandUpBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

