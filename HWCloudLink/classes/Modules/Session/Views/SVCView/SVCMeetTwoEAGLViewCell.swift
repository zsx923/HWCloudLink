//
//  SVCMeetTwoEAGLViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol svcMeetTwoEAGLViewCellDelegate: NSObjectProtocol {
    func svcMeetTwoEAGLViewCellDoubleClick(index: Int)
}

class SVCMeetTwoEAGLViewCell: UICollectionViewCell {

    static let cellID = "SVCMeetTwoEAGLViewCell"
    
    @IBOutlet weak var oneView: UIView!
    var oneVideo: EAGLView?
    @IBOutlet weak var oneBackView: UIImageView!
    @IBOutlet weak var oneName: UILabel!
    
    @IBOutlet weak var twoView: UIView!
    var twoVideo: EAGLView?
    @IBOutlet weak var twoBackView: UIImageView!
    @IBOutlet weak var twoName: UILabel!
    
    @IBOutlet weak var twoVideoNameBottomMargin: NSLayoutConstraint!
    
    weak var svcDelegate : svcMeetTwoEAGLViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.black
        oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
        oneBackView.layer.borderWidth = 1.2
        oneBackView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
        twoBackView.layer.borderWidth = 1.2
        twoBackView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        self.oneName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        self.twoName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)

        oneView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        oneView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        
        // 会控名字偏移量
        NotificationCenter.default.addObserver(self, selector: #selector(participantNameOffset(notfication:)), name: NSNotification.Name.init(SVCParticipantNameOffset), object: nil)
        
        // 双击手势
        let doubleClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleClickGestureCallBack(gesture:)))
        doubleClickGesture.numberOfTapsRequired = 2
        doubleClickGesture.numberOfTouchesRequired = 1
        twoBackView.addGestureRecognizer(doubleClickGesture)
        SVCMeetingViewController.viewTapGesture?.require(toFail: doubleClickGesture)
        
    }
    
    func setupVideo(indexRow:Int,isAuxiliary:Bool) {
        
        self.oneVideo?.removeFromSuperview()
        let oneTemp = EAGLViewAvcManager.shared.getSvcRemoteView(number: 0, indexRow: indexRow, isAuxiliary: isAuxiliary)
        oneTemp.backgroundColor = UIColor.black
        oneTemp.frame = self.oneView.bounds
        oneTemp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.oneView.insertSubview(oneTemp, belowSubview: oneName)
        self.oneVideo = oneTemp
        
        self.twoVideo?.removeFromSuperview()
        let twoTemp = EAGLViewAvcManager.shared.getSvcRemoteView(number: 1, indexRow: indexRow, isAuxiliary: isAuxiliary)
        twoTemp.backgroundColor = UIColor.black
        twoTemp.frame = self.twoView.bounds
        twoTemp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.twoView.insertSubview(twoTemp, belowSubview: twoName)
        self.twoVideo = twoTemp
    }
    
    // 双击选看
    @objc func doubleClickGestureCallBack(gesture:UITapGestureRecognizer) {
        if (svcDelegate != nil) {
            svcDelegate?.svcMeetTwoEAGLViewCellDoubleClick(index: 1)
        }
    }
    
    @objc func participantNameOffset(notfication:Notification) {
        SvcBottomNameOffSet = notfication.object as! CGFloat
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        twoVideoNameBottomMargin.constant = SvcBottomNameOffSet
        CLLog("twoVideoCell oneBackView UIView frame \(self.oneView?.frame ?? CGRect.zero)")
        CLLog("twoVideoCell oneVideo EAGLView frame \(self.oneVideo?.frame ?? CGRect.zero)")
        CLLog("twoVideoCell twoBackView UIView frame \(self.twoView?.frame ?? CGRect.zero)")
        CLLog("twoVideoCell twoVideo EAGLView frame \(self.twoVideo?.frame ?? CGRect.zero)")
    }
    
    func setOneName(string: String) {
        self.oneName.text = " " + string + "  "
    }
    
    func setTwoName(string: String) {
        self.twoName.text = " " + string + "  "
    }
    
    func clearLabelName() {
        oneName.text = ""
        twoName.text = ""
    }
    
    func clearBackViewImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.oneBackView.image = UIImage.init()
            self.twoBackView.image = UIImage.init()
        }
    }
    
    func setBackViewImage() {
        oneBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
        twoBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
    }
    
    deinit {
        CLLog("SVCMeetTwoEAGLViewCell deinit")
    }
}
