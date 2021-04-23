//
//  MeetingInfoQualityTableViewCell.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/30.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
typealias MeetingInfoQualityClickCallback = (_ cell: MeetingInfoQualityCell) -> Void
class MeetingInfoQualityCell: UITableViewCell {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var networkImageView: UIImageView!
    @IBOutlet weak var networkLabel: UILabel!
    var callback: MeetingInfoQualityClickCallback?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.arrowImageView.isUserInteractionEnabled = true
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(qulityAction))
        self.addGestureRecognizer(tapHandler)

    }

    @objc func qulityAction() {
        callback?(self)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
