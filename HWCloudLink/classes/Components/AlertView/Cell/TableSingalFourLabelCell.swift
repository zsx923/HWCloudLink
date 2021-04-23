//
// TableSingalFourLabelCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/17.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableSingalFourLabelCell: UITableViewCell {
    static let CELL_ID = "TableSingalFourLabelCell"
    static let CELL_HEIGHT: CGFloat = 32.0
    
    @IBOutlet weak var showTitle1Label: UILabel!
    @IBOutlet weak var showTitle2Label: UILabel!
    @IBOutlet weak var showTitle3Label: UILabel!
    @IBOutlet weak var showTitle4Label: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
