//
//  FeedBackCommitFooterView.swift
//  HWCloudLink
//
//  Created by 驿路梨花 on 2020/11/20.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class FeedBackCommitFooterView: BaseCustomView {
    
    @IBOutlet weak var commitBtn: UIButton!//提交按钮
    
    var passCommitValueBlock :(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commitBtn.isEnabled = false
        self.commitBtn.setTitle(tr("提交"), for: .normal)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    static func creatFeedBackCommitFooterView() -> FeedBackCommitFooterView{
        return loadNibView(nibName: "FeedBackCommitFooterView") as! FeedBackCommitFooterView
    }

    public func updateCommitBtnStatus(isYES: Bool) -> Void{
        if isYES {
            commitBtn.isEnabled = true
            commitBtn.backgroundColor = UIColor.init(hexString: "#0D94FF")
        }else{
            commitBtn.isEnabled = false
            commitBtn.backgroundColor = UIColor.colorWithSystem(lightColor: "#cccccc", darkColor: "#444444")
        }
    }
    
    
    //MARK: 提交按钮的方法
    @IBAction func commitBtn(_ sender: Any) {
        if passCommitValueBlock != nil {
            passCommitValueBlock!()
        }
    }
    
    
}
