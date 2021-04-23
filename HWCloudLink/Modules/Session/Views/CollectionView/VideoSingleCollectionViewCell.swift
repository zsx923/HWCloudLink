//
//  VideoSingleCollectionViewCell.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/11.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class VideoSingleCollectionViewCell: UICollectionViewCell {
    static let CELL_ID = "VideoSingleCollectionViewCell"
    static let CELL_HEIGHT: CGFloat = SCREEN_HEIGHT
    static let CELL_WIDTH: CGFloat = SCREEN_WIDTH
    
    @IBOutlet weak var showBackgroundView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        autoresizingMask = [.flexibleLeftMargin , .flexibleWidth];
        
        self.showBackgroundView.image = UIImage.init(named: "background")
        self.showBackgroundView.contentMode = .scaleAspectFill
        //self.showBackgroundView.backgroundColor = UIColor.black
    }

}
