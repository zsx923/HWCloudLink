//
//  TableRecentContactCell.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/17.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableRecentContactCell: UITableViewCell {
    
    static let CELL_ID = "TableRecentContactCell"
    static let CELL_HEIGHT: CGFloat = 72.0
    
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
