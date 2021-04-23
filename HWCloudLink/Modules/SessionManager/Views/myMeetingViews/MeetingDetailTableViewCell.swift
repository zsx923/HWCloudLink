//
//  MeetingDetailTableViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/10.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class MeetingDetailTableViewCell: UITableViewCell {
    
    static let cellID = "MeetingDetailTableViewCell"
    
    static let cellHeight: CGFloat = 54.0
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var eyeImageView: UIImageView!
    
    @IBOutlet weak var subTitleTextField: UITextField!
    let subTitleLabel = UILabel()
    
    @IBOutlet weak var TitleLabelWidthConstraints: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        eyeImageView.contentMode = .center

        subTitleTextField.isEnabled = false
        
        self.subTitleLabel.numberOfLines = 2
        self.subTitleLabel.text = ""
        self.subTitleLabel.textAlignment = .right
        self.subTitleLabel.font = UIFont.systemFont(ofSize: 16)
        self.subTitleLabel.textColor = UIColor(hexString: "#999999")
        self.contentView.addSubview(self.subTitleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 标题长度
        TitleLabelWidthConstraints.constant = TitleLabel.sizeThatFits(CGSize(width: SCREEN_WIDTH/2.0, height: 100)).width
        
        self.subTitleLabel.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(self.subTitleTextField)
            make?.top.bottom()?.mas_equalTo()(self.contentView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
