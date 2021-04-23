//
//  NoStreamAlert.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2020/12/29.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class NoStreamAlert: UIView {
    
    typealias callBack = () -> Void

    @IBOutlet weak var textLabel: UILabel!
    
    var sureClick: callBack?

    @IBAction func sureAction(_ sender: UIButton) {
        self.sureClick!()
    }
    
    class func alert() -> NoStreamAlert {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! NoStreamAlert
    }
}
