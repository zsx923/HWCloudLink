//
//  MeetingInfoSecretTableViewCell.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingInfoSecretCell: UITableViewCell {

    @IBOutlet weak var safeImageView: UIImageView!
    @IBOutlet weak var secretLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
