//
//  MeetingDetailThemeTableViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingDetailThemeTableViewCell: UITableViewCell {

    static let cellID = "MeetingDetailThemeTableViewCell"
        
    @IBOutlet weak var ContentLabel: ActionUILabel!
        
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var BottomView: UIView!
    
    @IBOutlet weak var confTypeImageView: UIImageView!
    
    func cellHeight() -> CGFloat {
        let Size = ContentLabel.sizeThatFits(CGSize(width: SCREEN_WIDTH-60, height: SCREEN_HEIGHT))
        return Size.height + 90
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        confTypeImageView.isHidden = ManagerService.call()?.isSMC3 == false
        
        BottomView.layer.cornerRadius = 10
        BottomView.layer.masksToBounds = true
        BottomView.backgroundColor = UIColor.colorWithSystem(lightColor: "#f6f6f6", darkColor: "#222222")
        
        TitleLabel.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#666666")
        TitleLabel.font = UIFont.systemFont(ofSize: 16)
        TitleLabel.text = tr("会议主题")
        
        ContentLabel.numberOfLines = 2
        ContentLabel.font = UIFont.boldSystemFont(ofSize: 26)
        ContentLabel.textColor = UIColor.colorWithSystem(lightColor: "#000000", darkColor: "#ffffff")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
