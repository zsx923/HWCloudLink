//
// TableCenterTextCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/20.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableCenterTextCell: UITableViewCell {
    static let CELL_ID = "TableCenterTextCell"
    static let CELL_HEIGHT: CGFloat = 50.0

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showSubtitleLabel: UILabel!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showSubtitleLabel.isHidden = true
        self.titleTopConstraint.constant = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSubTitle(subTitle: String?) {
        if subTitle != nil {
            self.showSubtitleLabel.isHidden = false
            self.showSubtitleLabel.text = subTitle
            self.titleTopConstraint.constant = 0
        } else {
            self.titleTopConstraint.constant = 15
            self.showSubtitleLabel.isHidden = true
        }
    }
    
}
