//
//  SVCMeetFourEAGLViewCell.swift
//  HWCloudLink
//
//  Created by Jabien.哲 on 2020/12/4.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol svcMeetFourEAGLViewCellDelegate: NSObjectProtocol {
    func svcMeetFourEAGLViewCellDoubleClick(index: Int)
}

class SVCMeetFourEAGLViewCell: UICollectionViewCell {

    static let cellID = "SVCMeetFourEAGLViewCell"
    
    @IBOutlet weak var oneView: UIView!
    @IBOutlet weak var oneBackView: UIImageView!
    @IBOutlet weak var oneName: UILabel!
    var oneVideo:EAGLView?
    
    @IBOutlet weak var twoView: UIView!
    @IBOutlet weak var twoBackView: UIImageView!
    @IBOutlet weak var twoName: UILabel!
    var twoVideo:EAGLView?
    
    @IBOutlet weak var threeView: UIView!
    @IBOutlet weak var threeBackView: UIImageView!
    @IBOutlet weak var threeName: UILabel!
    var threeVideo:EAGLView?
    
    @IBOutlet weak var fourView: UIView!
    @IBOutlet weak var fourBackView: UIImageView!
    @IBOutlet weak var fourName: UILabel!
    var fourVideo:EAGLView?
    
    @IBOutlet weak var threeVideoNameBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var fourVideoNameBottomMargin: NSLayoutConstraint!
    
    weak var svcDelegate: svcMeetFourEAGLViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black
        self.contentView.backgroundColor = UIColor.black
        
        oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
        oneBackView.layer.borderWidth = 1.2
        oneBackView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        
        twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
        twoBackView.layer.borderWidth = 1.2
        twoBackView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        
        threeBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
        threeBackView.layer.borderWidth = 1.2
        threeBackView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        fourBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
        fourBackView.layer.borderWidth = 1.2
        fourBackView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                
        self.oneName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        self.twoName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        self.threeName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        self.fourName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        
        oneView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        twoView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        threeView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        fourView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        
        // 会控名字偏移量
        NotificationCenter.default.addObserver(self, selector: #selector(participantNameOffset(notfication:)), name: NSNotification.Name.init(SVCParticipantNameOffset), object: nil)
        
        // 双击手势
        let twoClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(twoDoubleClickGestureCallBack(gesture:)))
        twoClickGesture.numberOfTapsRequired = 2
        twoClickGesture.numberOfTouchesRequired = 1
        twoBackView.addGestureRecognizer(twoClickGesture)
        SVCMeetingViewController.viewTapGesture?.require(toFail: twoClickGesture)
        
        // 双击手势
        let threeClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(threeDoubleClickGestureCallBack(gesture:)))
        threeClickGesture.numberOfTapsRequired = 2
        threeClickGesture.numberOfTouchesRequired = 1
        threeBackView.addGestureRecognizer(threeClickGesture)
        SVCMeetingViewController.viewTapGesture?.require(toFail: threeClickGesture)
        
        let fourClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(fourDoubleClickGestureCallBack(gesture:)))
        fourClickGesture.numberOfTapsRequired = 2
        fourClickGesture.numberOfTouchesRequired = 1
        fourBackView.addGestureRecognizer(fourClickGesture)
        SVCMeetingViewController.viewTapGesture?.require(toFail: fourClickGesture)
        
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
                
        self.threeVideo?.removeFromSuperview()
        let threeTemp = EAGLViewAvcManager.shared.getSvcRemoteView(number: 2, indexRow: indexRow, isAuxiliary: isAuxiliary)
        threeTemp.backgroundColor = UIColor.black
        threeTemp.frame = self.threeView.bounds
        threeTemp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.threeView.insertSubview(threeTemp, belowSubview: threeName)
        self.threeVideo = threeTemp
                
        self.fourVideo?.removeFromSuperview()
        let fourTemp = EAGLViewAvcManager.shared.getSvcRemoteView(number: 3, indexRow: indexRow, isAuxiliary: isAuxiliary)
        fourTemp.backgroundColor = UIColor.black
        fourTemp.frame = self.fourView.bounds
        fourTemp.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.fourView.insertSubview(fourTemp, belowSubview: fourName)
        self.fourVideo = fourTemp
    }
    
    @objc func twoDoubleClickGestureCallBack(gesture:UITapGestureRecognizer) {
        if svcDelegate != nil {
            svcDelegate?.svcMeetFourEAGLViewCellDoubleClick(index: 1)
        }
    }
    
    @objc func threeDoubleClickGestureCallBack(gesture:UITapGestureRecognizer) {
        if svcDelegate != nil {
            svcDelegate?.svcMeetFourEAGLViewCellDoubleClick(index: 2)
        }
    }
    
    @objc func fourDoubleClickGestureCallBack(gesture:UITapGestureRecognizer) {
        if svcDelegate != nil {
            svcDelegate?.svcMeetFourEAGLViewCellDoubleClick(index: 3)
        }
    }
    
    @objc func participantNameOffset(notfication:Notification) {
        SvcBottomNameOffSet = notfication.object as! CGFloat
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        threeVideoNameBottomMargin.constant = SvcBottomNameOffSet
        fourVideoNameBottomMargin.constant = SvcBottomNameOffSet
        CLLog("fourVideoCell oneBackView UIView frame \(self.oneView?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell oneVideo EAGLView frame \(self.oneVideo?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell twoBackView UIView frame \(self.twoView?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell twoVideo EAGLView frame \(self.twoVideo?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell threeBackView UIView frame \(self.threeView?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell threeVideo EAGLView frame \(self.threeVideo?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell fourBackView UIView frame \(self.fourView?.frame ?? CGRect.zero)")
        CLLog("fourVideoCell fourVideo EAGLView frame \(self.fourVideo?.frame ?? CGRect.zero)")
    }
    
    func setOneName(string: String) {
        self.oneName.text = " " + string + "  "
    }
    
    func setTwoName(string: String) {
        self.twoName.text = " " + string + "  "
    }
    
    func setThreeName(string: String) {
        self.threeName.text = " " + string + "  "
    }
    
    func setFourName(string: String) {
        self.fourName.text = " " + string + "  "
    }
    
    func clearLabelName() {
        oneName.text = ""
        twoName.text = ""
        threeName.text = ""
        fourName.text = ""
    }
    
    func clearBackViewImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.oneBackView.image = UIImage.init()
            self.twoBackView.image = UIImage.init()
            self.threeBackView.image = UIImage.init()
            self.fourBackView.image = UIImage.init()
        }
    }
    
    func setBackViewImage() {
        oneBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
        twoBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
        threeBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
        fourBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
    }
    
    deinit {
        CLLog("SVCMeetFourEAGLViewCell deinit")
    }
}
