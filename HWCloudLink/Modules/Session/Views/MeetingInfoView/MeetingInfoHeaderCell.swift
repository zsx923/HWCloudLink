//
//  MeetingInfoTableViewCell.swift
//  LandscapeTest
//
//  Created by wangyh1116 on 2020/12/30.
//

import UIKit

class MeetingInfoHeaderCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
