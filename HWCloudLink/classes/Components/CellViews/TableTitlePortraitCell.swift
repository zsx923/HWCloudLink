//
// TableTitlePortraitCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableTitlePortraitCell: UITableViewCell {
    static let CELL_ID = "TableTitlePortraitCell"
    static let CELL_HEIGHT: CGFloat = 72.0

    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
