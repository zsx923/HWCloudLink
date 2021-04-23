//
//  AttributedTextView.swift
//  HWCloudLink
//
//  Created by JYF on 2020/7/25.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit


extension UITextView {
       //add link str if nil means normal text (extend in need)
    func appendAttributString(string: String, color: UIColor, font: UIFont) {
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 6.0
        //orignal text
        let attrString: NSMutableAttributedString = NSMutableAttributedString()
           attrString.append(self.attributedText)
        
        //new text ,system normal style
        let attrs = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: paraph]
        let appendString = NSMutableAttributedString(string: string, attributes: attrs)
        //merge text
        attrString.append(appendString)
        self.attributedText = attrString
    }
   
}
