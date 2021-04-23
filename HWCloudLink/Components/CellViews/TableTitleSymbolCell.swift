//
// TableTitleSymbolCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableTitleSymbolCell: UITableViewCell {
    static let CELL_ID = "TableTitleSymbolCell"
    static let CELL_HEIGHT: CGFloat = 54.0
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    var isHiddenDescribe: Bool = true {
        didSet {
            describeLabel.isHidden = isHiddenDescribe
        }
    }
    
    @IBOutlet weak var showRightImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        describeLabel.isHidden = isHiddenDescribe
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
