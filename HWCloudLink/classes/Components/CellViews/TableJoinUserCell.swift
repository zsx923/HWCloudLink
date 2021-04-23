//
// TableJoinUserCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableJoinUserCell: UITableViewCell {
    static let CELL_ID = "TableJoinUserCell"
    static let CELL_HEIGHT: CGFloat = 72.0

    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
        
    @IBOutlet weak var showVoiceBtn: UIButton!
    
    @IBOutlet weak var showHandUpBtn: UIButton!
    
    @IBOutlet weak var showTitleVCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showTitleRightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showHandUpBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
}
