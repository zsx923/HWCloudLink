//
//  ThemeChangesViewController.swift
//  HWCloudLink
//
//  Created by Tory on 2020/3/13.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class ThemeChangesViewController: UIViewController {

    @IBOutlet weak var lightBtn: UIButton!
    
    @IBOutlet weak var darkBtn: UIButton!
    
    @IBOutlet weak var colorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorView.backgroundColor = UIColor.colorWithSystem(lightColor: "#000000", darkColor: "#EEEEEE")
    }
    
    
    @IBAction func changeToLight(_ sender: UIButton) {
        MyThemes.switchTo(theme: .light)
        NSObject.userDefaultSaveValue("light", forKey: DICT_SAVE_THEME_SETTING)
    }
    

    @IBAction func changeToDark(_ sender: UIButton) {
        MyThemes.switchTo(theme: .dark)
        NSObject.userDefaultSaveValue("dark", forKey: DICT_SAVE_THEME_SETTING)
    }

}
