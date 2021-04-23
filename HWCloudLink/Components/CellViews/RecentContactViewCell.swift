//
//  RecentContactViewCell.swift
//  HWCloudLink
//
//  Created by mac on 2020/6/13.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class RecentContactViewCell: UITableViewCell {

    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var numberLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dateLable: UILabel!
    
    var userCallLogModel: UserCallLogModel = UserCallLogModel() {
        
        didSet {
            
            nameLable.text = userCallLogModel.meetingType == 1 ? userCallLogModel.userName : userCallLogModel.title
            CLLog("=meetingType =\(userCallLogModel.meetingType ?? 0) =name=\(NSString.encryptNumber(with: userCallLogModel.userName) ?? "")==title = \(NSString.encryptNumber(with: userCallLogModel.title) ?? "")")
            numberLable.text = ""
            if userCallLogModel.isAnswer {
                timeLable.text = (userCallLogModel.talkTime <= 0)  ? tr("未接通") : NSDate.stringReadStampHourMinuteSecond(withFormatted: userCallLogModel.talkTime)
            } else {
                timeLable.text = userCallLogModel.isComing ? tr("未接来电")
                    : tr("未接通")            }
            // timeLable.text = userCallLogModel.isAnswer ? NSDate.stringReadStampHourMinuteSecond(withFormatted: userCallLogModel.talkTime) : "未接来电"
            if userCallLogModel.meetingType == 1 {
                userCallLogModel.callType == 2 ? (userCallLogModel.isComing ? (iconImageView.image = UIImage(named: "视频-呼入")?.withRenderingMode(.alwaysTemplate)) : (iconImageView.image = UIImage(named: "视频-呼出")?.withRenderingMode(.alwaysTemplate))) : ( userCallLogModel.isComing ? (iconImageView.image = UIImage(named: "语音-呼入")?.withRenderingMode(.alwaysTemplate)) : (iconImageView.image = UIImage(named: "语音-呼出")?.withRenderingMode(.alwaysTemplate)))
            } else {
                userCallLogModel.callType == 2 ? (iconImageView.image = UIImage(named: "视频-呼入")?.withRenderingMode(.alwaysTemplate)) : (iconImageView.image = UIImage(named: "语音-呼入")?.withRenderingMode(.alwaysTemplate))
            }
            //时间
            if userCallLogModel.talkTime > 0 {
                let timeStr = NSDate.dateCurrentString(userCallLogModel.createTime, withCutTime: userCallLogModel.talkTime)
                dateLable.text = NSDate.stringNormalType2Read(withDate: timeStr)
            }else{
                dateLable.text = NSDate.stringNormalType2Read(withDate: userCallLogModel.createTime)
            }

            iconImageView.tintColor = UIColor(hexString: "979797")
            if !userCallLogModel.isAnswer {
                nameLable.textColor = UIColor(hexString: "F34B4B")
                numberLable.textColor = UIColor(hexString: "F34B4B")
                timeLable.textColor = UIColor(hexString: "F34B4B")
                timeLable.font = UIFont.systemFont(ofSize: 16)
            }else{
                nameLable.textColor = userCallLogModel.talkTime <= 0 ? UIColor(hexString: "F34B4B") : UIColor.colorWithSystem(lightColor: UIColor.black, darkColor: UIColor.white)
                numberLable.textColor = UIColor(hexString: "999999")
                timeLable.textColor = userCallLogModel.talkTime <= 0 ? UIColor(hexString: "F34B4B") : UIColor(hexString: "666666")
                timeLable.font = UIFont.systemFont(ofSize: 16)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
