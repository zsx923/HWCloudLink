//
//  MeetingDetailAttendCountTableViewCell.swift
//  HWCloudLink
//
//  Created by mac on 2020/12/25.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingDetailAttendCountTableViewCell: UITableViewCell {

    static let cellID = "MeetingDetailAttendCountTableViewCell"
    
    static let cellHeight: CGFloat = 54.0
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var MoreImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        MoreImageView.image = UIImage.init(named: "icon_listarrow_press")
        TitleLabel.font = UIFont.systemFont(ofSize: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
