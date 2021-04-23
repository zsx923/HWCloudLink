//
//  AskVoiceToVideoRequestViewController.swift
//  HWCloudLink
//
//  Created by JYF on 2020/8/5.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
typealias ResponseBlock = (Bool) -> Void


class AskVoiceToVideoRequestViewController: UIViewController {

    var meetInfo: ConfBaseInfo?
    var callInfo: CallInfo?
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var openCameraLabel: UILabel!
    
    
    var responseBlock: ResponseBlock? // 如果需要回传数据则使用，否则不用

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.backgroundColor = UIColor.gradient(size: CGSize(width: kScreenWidth, height: kScreenHeight), direction: .default, start: UIColor(white: 0, alpha:0.3), end:  UIColor(white: 0, alpha: 1))

        self.backgroudImageView.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(80)
            make?.width.mas_equalTo()(SCREEN_WIDTH)
            make?.height.mas_equalTo()(SCREEN_HEIGHT)
        }
        //默认为人头像
        let userCardStyle = getCardImageAndColor(from: "")
        self.backgroudImageView.image = userCardStyle.cardImage
        self.backgroudImageView.alpha = 0.3
        
        
        
//        self.backgroudImageView.image = getUserIconWithAZ(name: callInfo?.stateInfo.callName ?? "")
        var name = self.callInfo?.stateInfo.callName ?? ""
        if name.count == 0 {
            name = self.meetInfo?.accessNumber ?? ""
        }
        self.nameLabel.text = name
        self.statusLabel.text = tr("想与您视频通话")
    
        self.nameLabel.isHidden = true
        self.statusLabel.isHidden = true
        
        self.openCameraLabel.text = tr("对方请求打开视频")
        
    }

    
    
    // MARK: events
    @IBAction func sureButtonAction(_ sender: UIButton) {
        CLLog("同意打开视频")
        self.responseForRequestDismiss(true)

    }
    
    @IBAction func rejectButtonAction(_ sender: UIButton) {
        CLLog("拒绝打开视频")
        self.responseForRequestDismiss(false)
    }
    
    private func responseForRequestDismiss(_ sure: Bool) {
        self.responseBlock?(sure)
        self.dismiss(animated: true, completion: nil)
    } 
}
