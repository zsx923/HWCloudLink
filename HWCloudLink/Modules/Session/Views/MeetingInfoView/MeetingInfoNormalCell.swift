//
//  MeetingInfoNormalTableViewCell.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

typealias MeetingInfoClickCallback = (_ cell: MeetingInfoNormalCell) -> Void

class MeetingInfoNormalCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var iconButton: UIButton!
    
    var callback: MeetingInfoClickCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnClickHandler(_ sender: UIButton) {
        callback?(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
