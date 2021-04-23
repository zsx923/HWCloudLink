//
// WhiteTextViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/6/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class WhiteTextViewController: UIViewController {
    @IBOutlet weak var showLabel: UILabel!
    
    var showText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showLabel.text = showText
        self.showLabel.font = UIFont.systemFont(ofSize: 30.0)
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.dismiss(animated: true, completion: nil)
        }))
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
