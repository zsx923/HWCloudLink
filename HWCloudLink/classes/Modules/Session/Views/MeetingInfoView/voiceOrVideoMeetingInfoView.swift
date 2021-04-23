//
//  voiceOrVideoMeetingInfoView.swift
//  HWCloudLink
//
//  Created by mac on 2021/2/5.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

typealias VoiceOrVideoMeetingInfoClickCallback = () -> Void

class voiceOrVideoMeetingInfoView: UIView {

    var callback: VoiceOrVideoMeetingInfoClickCallback?
    
    @IBOutlet weak var topTitleLabel: UILabel!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var ucAccNumberLabel: UILabel!
    
    @IBOutlet weak var checkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ucAccNumberLabel.text = tr("终端号码")
        checkLabel.text = tr("查看音视频质量")
    }
    
    class func shareMeetingInfo() -> voiceOrVideoMeetingInfoView {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! voiceOrVideoMeetingInfoView
    }
    

    
    
    @IBAction func netSigleBtn(_ sender: UIButton) {
        callback?()
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.removeFromSuperview()
    }
    
  

}
