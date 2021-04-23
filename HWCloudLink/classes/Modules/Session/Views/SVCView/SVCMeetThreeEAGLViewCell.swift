//
//  SVCMeetThreeEAGLViewCell.swift
//  HWCloudLink
//
//  Created by mac on 2021/1/13.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

protocol svcMeetThreeEAGLViewCellDelegate: NSObjectProtocol {
    func svcMeetThreeEAGLViewCellDoubleClick(index: Int)
}

class SVCMeetThreeEAGLViewCell: UICollectionViewCell {

    static let cellID = "SVCMeetThreeEAGLViewCell"
    
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
    
    @IBOutlet weak var threeVideoNameBottomMargin: NSLayoutConstraint!
    
    weak var svcDelegate: svcMeetThreeEAGLViewCellDelegate?
    
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
        
        self.oneName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        self.twoName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        self.threeName.backgroundColor = UIColorRGBA_Selft(r: 0, g: 0, b: 0, a: 0.0)
        
        oneView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        oneView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        oneView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        
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
        
    }
    
    // 第二个画面
    @objc func twoDoubleClickGestureCallBack(gesture:UITapGestureRecognizer) {
        if svcDelegate != nil {
            svcDelegate?.svcMeetThreeEAGLViewCellDoubleClick(index: 1)
        }
    }
    // 第三个画面
    @objc func threeDoubleClickGestureCallBack(gesture:UITapGestureRecognizer) {
        if svcDelegate != nil {
            svcDelegate?.svcMeetThreeEAGLViewCellDoubleClick(index: 2)
        }
    }
    
    
    @objc func participantNameOffset(notfication:Notification) {
        SvcBottomNameOffSet = notfication.object as! CGFloat
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        threeVideoNameBottomMargin.constant = SvcBottomNameOffSet
        CLLog("threeVideoCell oneBackView UIView frame \(self.oneView?.frame ?? CGRect.zero)")
        CLLog("threeVideoCell oneVideo EAGLView frame \(self.oneVideo?.frame ?? CGRect.zero)")
        CLLog("threeVideoCell twoBackView UIView frame \(self.twoView?.frame ?? CGRect.zero)")
        CLLog("threeVideoCell twoVideo EAGLView frame \(self.twoVideo?.frame ?? CGRect.zero)")
        CLLog("threeVideoCell threeBackView UIView frame \(self.threeView?.frame ?? CGRect.zero)")
        CLLog("threeVideoCell threeVideo EAGLView frame \(self.threeVideo?.frame ?? CGRect.zero)")
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
    
    func clearLabelName() {
        oneName.text = ""
        twoName.text = ""
        threeName.text = ""
    }
    
    func clearBackViewImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.oneBackView.image = UIImage.init()
            self.twoBackView.image = UIImage.init()
            self.threeBackView.image = UIImage.init()
        }
        
    }
    
    func setBackViewImage() {
        oneBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
        twoBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
        threeBackView.image = UIImage.init(named: "tup_call_loading_img.jpg")
    }
    
    deinit {
        CLLog("SVCMeetThreeEAGLViewCell deinit")
    }
}
