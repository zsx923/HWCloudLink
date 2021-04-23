//
// CollectionImageTopTextCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/1.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class CollectionImageTopTextCell: UICollectionViewCell {
    static let CELL_ID = "CollectionImageTopTextCell"
    static let CELL_HEIGHT: CGFloat = 100.0
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDeleteBtnHiden(isHidden: Bool) {
        self.deleteBtn.isHidden = isHidden
    }

}
