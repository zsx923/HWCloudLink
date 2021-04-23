//
// TableNameFieldCell.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

protocol TableNameFieldCellDelegate: NSObjectProtocol {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}

class TableNameFieldCell: UITableViewCell {
    static let CELL_ID = "TableNameFieldCell"
    static let CELL_HEIGHT: CGFloat = 72.0
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showInputTextField: UITextField!
    
    @IBOutlet weak var buttomLine: UIView!
    
    weak var cellDelegate: TableNameFieldCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showInputTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension TableNameFieldCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.buttomLine.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.buttomLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.cellDelegate == nil {
            return false
        } else {
            return self.cellDelegate!.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
    }
}
