//
//  MyMeetingEmptyTableViewCell.swift
//  HWCloudLink
//
//  Created by mac on 2020/12/24.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MyMeetingEmptyTableViewCell: UITableViewCell {

    static let CellID = "MyMeetingEmptyTableViewCell"
    
    static let CellHeight: CGFloat = SCREEN_HEIGHT-AppNaviHeight-AppNaviHeight
    
    @IBOutlet weak var PicImageView: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
