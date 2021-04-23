//
// TableTextNextCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableTextNextCell: UITableViewCell {
    static let CELL_ID = "TableTextNextCell"
    static let CELL_HEIGHT: CGFloat = 54.0

    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var rightImageView: UIImageView!
    //    @IBOutlet weak var showTipImageView: UIImageView!
    
    @IBOutlet weak var showTipLabel: UILabel!
    
    @IBOutlet weak var showRightTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        
        
        // Configure the view for the selected state
    }
    
}
