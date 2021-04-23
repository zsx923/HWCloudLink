//
//  ShareScreenBackView.swift
//  HWCloudLink
//
//  Created by mac on 2021/3/10.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit
typealias ShareScreenBackBlcok = () -> Void
class ShareScreenBackView: UIView {
    @IBOutlet weak var screenShareTitleLabel: UILabel!
    @IBOutlet weak var screenShareSubTitleLabel: UILabel!
    var callback: ShareScreenBackBlcok?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.screenShareTitleLabel.text = tr("您正在共享屏幕")
        self.screenShareSubTitleLabel.text = tr("停止共享")
    }
    
    class func shareScreenBackView() -> ShareScreenBackView {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! ShareScreenBackView
    }

    @IBAction func stopBtnClick(_ sender: Any) {
        callback?()
        self.removeFromSuperview()
    }
    
    func dismissCurrentView()  {
        self.removeFromSuperview()
    }
}
