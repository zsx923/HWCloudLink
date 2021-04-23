//
//  TableSearchAttendeeCell.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableSearchAttendeeCell: UITableViewCell {
    
    static let CELL_ID = "TableSearchAttendeeCell"
    
    static let CELL_HEIGHT: CGFloat = 72.0
    
    @IBOutlet weak var chooseBtn: UIButton!
    
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBAction func touchBtn(_ sender: UIButton) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
//        self.chooseBtn.setImage(UIImage.init(named: "no_check"), for: .normal)
//        self.chooseBtn.setImage(UIImage.init(named: "check"), for: .selected)
        self.chooseBtn.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
