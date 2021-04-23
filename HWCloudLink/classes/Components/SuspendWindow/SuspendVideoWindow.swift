//
//  SuspendVideoWindow.swift
//  HWCloudLink
//
//  Created by Jabien on 2020/8/8.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SuspendVideoWindow: UIWindow {

    var isSvcConf:Bool?
    var meetInfo:ConfBaseInfo?
    var callInfo:CallInfo?
    
    init(frame:CGRect,isSvc:Bool,meetInfo:ConfBaseInfo,callInfo:CallInfo) {
        super.init(frame: frame)
        
        self.isSvcConf = isSvc
        self.meetInfo = meetInfo
        self.callInfo = callInfo
        
    }
    
    
    fileprivate func showVideo() {
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
