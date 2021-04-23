//
//  MyMeetingThreeSMCTableViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/9.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MyMeetingThreeSMCTableViewCell: UITableViewCell {

    static let CellID = "MyMeetingThreeSMCTableViewCell"
    
    static let CellHeight: CGFloat = 72.0
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var picImageView: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var joinInBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.joinInBtn.clipsToBounds = true
        self.joinInBtn.layer.cornerRadius = 2.0
        self.joinInBtn.layer.borderWidth = 0.5
        self.joinInBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
        self.joinInBtn.setTitle(tr("加入"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.height = 72
    }
    
    // 加载数据
    func loadData(meetInfo:ConfBaseInfo,indexPath:IndexPath) {
        // 是否显示加入会议
        if !meetInfo.isActive {
            self.joinInBtn.isHidden = true
        }else{
            self.joinInBtn.isHidden = false
        }
        self.joinInBtn.accessibilityValue = String(indexPath.section)
        self.joinInBtn.tag = indexPath.row
        // 结束时间
        if meetInfo.endTime != nil && meetInfo.endTime != "" {
            // 跨天数
            let startDate = String.string2Date(meetInfo.startTime.components(separatedBy: " ").first ?? "", dateFormat: "yyyy-MM-dd")
            let endDate = String.string2Date(meetInfo.endTime.components(separatedBy: " ").first ?? "", dateFormat: "yyyy-MM-dd")
            let gapDay = NSCalendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            
            let endTime:String = NSString.getRangeOfIndex(withStart: 11, andEnd: 16, andDealStr: meetInfo.endTime) ?? ""
            if gapDay > 0 {
                let allStr:String = endTime+" "+"+"+String(gapDay)
                let AttStr = NSMutableAttributedString.init(string: allStr)
                AttStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "333333")!,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], range: NSMakeRange(0, allStr.count))
                AttStr.setAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], range: NSMakeRange(0, allStr.count))
                AttStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "0D94FF")!,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 9)], range: NSMakeRange(endTime.count+1, String(gapDay).count+1))
                self.endTimeLabel.attributedText = AttStr
            }else{
                self.endTimeLabel.text = endTime
            }
        }else {
            self.endTimeLabel.text = tr("持续会议")
        }
       // 开始时间
        self.startTimeLabel.text = NSString.getRangeOfIndex(withStart: 11, andEnd: 16, andDealStr: meetInfo.startTime)
        
        // 谁的会议
        self.TitleLabel.text = meetInfo.confSubject
        // 视频会议还是音频会议
        if meetInfo.confType == TSDK_E_CONF_EX_AUDIO {
            // 音频
            self.picImageView.image = UIImage.init(named: "icon_meetdetail_voice_press")
        } else {
            // 视频
            self.picImageView.image = UIImage.init(named: "icon_meetdetail_video_press")
        }
        // set sub title
        self.subTitleLabel.text = tr("召集人：") + meetInfo.scheduleUserName
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
