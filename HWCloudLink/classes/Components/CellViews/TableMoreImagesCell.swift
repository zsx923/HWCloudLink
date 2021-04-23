//
// TableMoreImagesCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/11.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class TableMoreImagesCell: UITableViewCell {
    static let CELL_ID = "TableMoreImagesCell"
    static let CELL_HEIGHT: CGFloat = 130.0

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var addView: UIView!
    
    // user 1
    @IBOutlet weak var user1View: UIView!
    @IBOutlet weak var user1ImageView: UIImageView!
    @IBOutlet weak var user1NameLabel: UILabel!
    
    // user 2
    @IBOutlet weak var user2View: UIView!
    @IBOutlet weak var user2ImageView: UIImageView!
    @IBOutlet weak var user2NameLabel: UILabel!
    
    // user 3
    @IBOutlet weak var user3View: UIView!
    @IBOutlet weak var user3ImageView: UIImageView!
    @IBOutlet weak var user3NameLabel: UILabel!
    
    // user 4
    @IBOutlet weak var user4View: UIView!
    @IBOutlet weak var user4ImageView: UIImageView!
    @IBOutlet weak var user4NameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.scrollView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: TableMoreImagesCell.CELL_HEIGHT)
//        self.scrollView.showsVerticalScrollIndicator = false
//        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.isScrollEnabled = true
    }
    
    func setDataCell(dataArray: [LoginInfo]) {
        self.user1View.isHidden = true
        self.user2View.isHidden = true
        self.user3View.isHidden = true
        self.user4View.isHidden = true
        
        for (index, userInfo) in dataArray.enumerated() {
            switch index {
            case 0:
                self.user1View.isHidden = true
                self.user1ImageView.image = UIImage.init(named: userInfo.userPhotoPath)
                self.user1NameLabel.text = userInfo.account
            case 1:
                self.user2View.isHidden = true
                self.user2ImageView.image = UIImage.init(named: userInfo.userPhotoPath)
                self.user2NameLabel.text = userInfo.account
            case 2:
                self.user3View.isHidden = true
                self.user3ImageView.image = UIImage.init(named: userInfo.userPhotoPath)
                self.user3NameLabel.text = userInfo.account
            case 3:
                self.user4View.isHidden = true
                self.user4ImageView.image = UIImage.init(named: userInfo.userPhotoPath)
                self.user4NameLabel.text = userInfo.account
            default:
                CLLog("not define.")
            }
        }
        self.scrollView.contentSize = CGSize.init(width: CGFloat(82 * (dataArray.count + 1)), height: STATUS_BAR_HEIGHT)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
