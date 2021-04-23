//
//  NoCopyTextField.swift
//  HWCloudLink
//
//  Created by JYF on 2020/7/24.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol NoCopyTextFieldDelegate: NSObjectProtocol {
    func baseTextFieldDeleteBackward(baseTextField: NoCopyTextField)
}

class NoCopyTextField: UITextField {
    weak var baseTextFieldDelegate: NoCopyTextFieldDelegate?

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func deleteBackward() {
        super.deleteBackward()

        guard let baseTextFieldDelegate = baseTextFieldDelegate else {
            print("baseTextFieldDelegate is nil.")
            return
        }
        baseTextFieldDelegate.baseTextFieldDeleteBackward(baseTextField: self)
    }

}
