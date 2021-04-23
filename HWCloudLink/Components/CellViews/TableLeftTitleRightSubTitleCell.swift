//
// TableLeftTitleRightSubTitleCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/15.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableLeftTitleRightSubTitleCell: UITableViewCell {
    static let CELL_ID = "TableLeftTitleRightSubTitleCell"
    static let CELL_HEIGHT: CGFloat = 50.0
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
