//
//  SVCMeetOneEAGLViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SVCMeetOneEAGLViewCell: UICollectionViewCell {

    static let cellID = "SVCMeetOneEAGLViewCell"
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var videoTopImageView: UIImageView!
    
    @IBOutlet weak var videoBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var videoTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabelBottomMargin: NSLayoutConstraint!
    
    var video: EAGLView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        self.contentView.backgroundColor = UIColor.black
        
        self.nameLabel.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
                
        backView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        // 会控名字偏移量
        NotificationCenter.default.addObserver(self, selector: #selector(participantNameOffset(notfication:)), name: NSNotification.Name.init(SVCParticipantNameOffset), object: nil)
        
        let temp = EAGLViewAvcManager.shared.viewForRemote
        temp.backgroundColor = UIColor.black
        temp.frame = self.backView.bounds
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.backView.insertSubview(temp, belowSubview: nameLabel)
        self.video = temp
    }

    func setupVideo() {
        self.video?.removeFromSuperview()
        let temp = EAGLViewAvcManager.shared.viewForRemote
        temp.backgroundColor = UIColor.black
        temp.frame = self.backView.bounds
        temp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.backView.insertSubview(temp, belowSubview: nameLabel)
        self.video = temp
    }
    
    @objc func participantNameOffset(notfication:Notification) {
        SvcBottomNameOffSet = notfication.object as! CGFloat
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CLLog("bigPicCell backView UIView frame \(self.backView?.frame ?? CGRect.zero)")
        CLLog("bigPicCell picVideo EAGLView frame \(self.video?.frame ?? CGRect.zero)")
        
        if self.safeAreaInsets.top != 0.0 {
            nameLabelBottomMargin.constant = isiPhoneXMore() ? 34.0 + SvcBottomNameOffSet : SvcBottomNameOffSet
            return
        }
        nameLabelBottomMargin.constant = SvcBottomNameOffSet
    }
    
    func setName(string: String) {
        self.nameLabel.text = " " + string + "  "
    }

    func clearLabelName() {
        nameLabel.text = ""
    }
    
    func clearBackViewImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.videoTopImageView.image = UIImage.init()
        }
    }
    
    func setBackViewImage() {
        videoTopImageView.image = UIImage.init(named: "tup_call_loading_img.jpg")
    }
    
    func setBackViewBlackImage() {
        videoTopImageView.image = UIImage.init(color: UIColor.black)
    }
    
    deinit {
        CLLog("SVCMeetOneEAGLViewCell deinit")
    }

}
