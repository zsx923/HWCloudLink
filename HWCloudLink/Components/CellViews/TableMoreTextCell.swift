//
// TableMoreTextCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol TableMoreTextCellDelegate :NSObjectProtocol {
    func TableMoreTextCellCallBtnClick()
    func TableMoreTextCellVideoBtnClick()
}


class TableMoreTextCell: UITableViewCell {
    static let CELL_ID = "TableMoreTextCell"
    static let CELL_HEIGHT: CGFloat = 72.0

    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var videoBtn: UIButton!
    weak var cellBtnDelegate: TableMoreTextCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showTitleLabel.isUserInteractionEnabled = false
        
        self.callBtn.addTarget({ (sender) in
            self.cellBtnDelegate?.TableMoreTextCellCallBtnClick()
        }, andEvent: .touchUpInside)
        
        self.videoBtn.addTarget({ (sender) in
            self.cellBtnDelegate?.TableMoreTextCellVideoBtnClick()
        }, andEvent: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
