//
//  SVCMeetBfcpEAGLViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/5.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SVCMeetBfcpEAGLViewCell: UICollectionViewCell {
    
    static let cellID = "SVCMeetBfcpEAGLViewCell"
    
    var video: EAGLView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        self.contentView.backgroundColor = UIColor.black
        
        let temp = EAGLViewAvcManager.shared.viewForBFCP
        temp.backgroundColor = UIColor.clear
        temp.frame = self.contentView.bounds
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.contentView.addSubview(temp)
        self.video = temp
    }
    
    func setupVideo() {
        self.video?.removeFromSuperview()
        let temp = EAGLViewAvcManager.shared.viewForBFCP
        temp.backgroundColor = UIColor.clear
        temp.frame = self.contentView.bounds
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.contentView.addSubview(temp)
        self.video = temp
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CLLog("bfceCell bfcpVideo EAGLView frame \(self.video?.frame ?? CGRect.zero)")
    }
    
    deinit {
        CLLog("SVCMeetBfcpEAGLViewCell deinit")
    }
    
}
