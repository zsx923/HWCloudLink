//
// TableAccountHistoryCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/16.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableAccountHistoryCell: UITableViewCell {
    static let CELL_ID = "TableAccountHistoryCell"
    static let CELL_HEIGHT: CGFloat = 55.0
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showDeleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
