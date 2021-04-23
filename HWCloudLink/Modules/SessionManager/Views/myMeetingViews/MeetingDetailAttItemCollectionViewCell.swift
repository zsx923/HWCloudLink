//
//  MeetingDetailAttItemCollectionViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingDetailAttItemCollectionViewCell: UICollectionViewCell {

    static let cellID = "MeetingDetailAttItemCollectionViewCell"
    
    @IBOutlet weak var picImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
