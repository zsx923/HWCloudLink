//
//  PicInPicCollectionCell.swift
//  PictureInPicture
//
//  Created by mac on 2020/6/1.
//  Copyright © 2020 coderybxu. All rights reserved.
//

import UIKit

class PicInPicCollectionCell: UICollectionViewCell {
    
    var video: EAGLView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    deinit {
        CLLog("PicInPicCollectionCell - deinit")
    }
    
    func setupVideo(isAux: Bool = false) {
        
        self.video?.removeFromSuperview()
        
        var temp = EAGLViewAvcManager.shared.viewForRemote
        if isAux {
            temp = EAGLViewAvcManager.shared.viewForBFCP
        }
        temp.backgroundColor = UIColor.clear
        temp.frame = self.contentView.bounds
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.contentView.addSubview(temp)
        
        self.video = temp
    }
}
