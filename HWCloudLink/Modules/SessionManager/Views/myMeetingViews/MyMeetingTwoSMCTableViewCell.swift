//
//  MyMeetingTwoSMCTableViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/9.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MyMeetingTwoSMCTableViewCell: UITableViewCell {

    static let CellID = "MyMeetingTwoSMCTableViewCell"
    
    static let CellHeight: CGFloat = 72.0

    @IBOutlet weak var showBeginTimeLabel: UILabel!
    
    @IBOutlet weak var showEndTimeLabel: UILabel!
    
     @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showJoinBtn: UIButton!
            
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showJoinBtn.clipsToBounds = true
        self.showJoinBtn.layer.cornerRadius = 2.0
        self.showJoinBtn.layer.borderWidth = 0.5
        self.showJoinBtn.layer.borderColor = UIColor(hexString: "#0D94FF")?.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.height = 72
    }

    func loadData(meetInfo: ConfBaseInfo, isShow: Bool, indexPath:IndexPath) {
        
        self.setJoinTitle(title: tr("加入"), isShow: isShow, isAction: true, indexPath: indexPath)
        
       // yyyy-MM-dd HH:mm:ss
        self.showBeginTimeLabel.text = NSString.getRangeOfIndex(withStart: 11, andEnd: 16, andDealStr: meetInfo.startTime)
            // 结束时间
        if meetInfo.endTime != nil && meetInfo.endTime != "" {
            // 跨天数
//            let gapDay = NSDate.gapDayCount(withStartTime: meetInfo.startTime, endTime: meetInfo.endTime)
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
                self.showEndTimeLabel.attributedText = AttStr
            }else{
                self.showEndTimeLabel.text = endTime
            }
        } else {
            self.showEndTimeLabel.text = tr("持续会议")
        }
        
        // set title
        self.showTitleLabel.text = meetInfo.confSubject
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setJoinTitle(title: String, isShow: Bool, isAction: Bool, indexPath: IndexPath) {
//        if !isShow {
//            self.showJoinBtn.isHidden = false
//            return
//        }
        
        self.showJoinBtn.isHidden = !isShow
        if isShow {
            self.showJoinBtn.setTitle(title, for: .normal)
            self.showJoinBtn.isUserInteractionEnabled = isAction
    //        if isAction {
    //            self.showJoinBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
    //            self.showJoinBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
    //        } else {
    //            self.showJoinBtn.layer.borderColor = COLOR_GRAY_WHITE.cgColor
    //            self.showJoinBtn.setTitleColor(COLOR_GRAY_WHITE, for: .normal)
    //        }
            
            self.showJoinBtn.tag = indexPath.row
            self.showJoinBtn.accessibilityValue = String(indexPath.section)
        }
    }
    
}
