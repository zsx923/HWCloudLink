//
// LauguageSetViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/10.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
 
class LauguageSetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView?
    
    let languageTitles : Array = ["简体中文", "English"]
    let languageKeys : Array = ["zh-Hans", "en"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化
        self.title = tr("语言")
        self.setViewUI()
    }
    
    // MARK: - 设置UI相关
    func setViewUI() {
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(leftBarBtnItemClick(sender:))
        )
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // tableView
        tableView = UITableView.init(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: SCREEN_WIDTH,
                                                   height: SCREEN_HEIGHT)
        )
        self.view.addSubview(tableView!)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor.white, darkColor: UIColor.black)
        self.tableView!.register(UINib.init(nibName: TableTitleSymbolCell.CELL_ID,
                                            bundle: nil),
                                 forCellReuseIdentifier: TableTitleSymbolCell.CELL_ID
        )
        self.tableView!.separatorStyle = .none
    }

    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func switchLanguage(_ index: Int) {
        UserDefaults.standard.set(self.languageKeys[index], forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH)
        // 发送通知, 更新页面
        NotificationCenter.default.post(name: NSNotification.Name.init(LOCALIZABLE_CHANGE_LANGUAGE), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

}

extension LauguageSetViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        viewVC.showTitleLabel.text = tr("正在会议中，切换语言会议将中断，是否确认切换？")
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        viewVC.showRightBtn.setTitleColor(COLOR_RED, for: .normal)
    }
    
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        
    }
    
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        if let window: SuspendWindow = SuspendTool.sharedInstance.suspendWindows.first {
            if window.rootVC?.classForCoder == VoiceViewController.classForCoder() {
                if let voiceVc = window.rootVC as? VoiceViewController {
                    voiceVc.callBtnClick(UIButton.init(type: .system))
                }
            } else if window.rootVC?.classForCoder == VideoViewController.classForCoder() {
                if let videoVc = window.rootVC as? VideoViewController {
                    videoVc.leaveBtnClick(UIButton.init(type: .system))
                }
            } else {
                MBProgressHUD.showMessage("")
                SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
            }
        } else {
            MBProgressHUD.showMessage("")
            SessionManager.shared.endAndLeaveConferenceDeal(isEndConf: false)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            MBProgressHUD.hide()
            self.switchLanguage(viewVC.view.tag)
        }
    }
}

// MARK: - UITableViewDelegate
extension LauguageSetViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableTitleSymbolCell.CELL_ID) as! TableTitleSymbolCell
        // change at xuegd 2020-12-30 : 本地语言的Key
        let localLanguageKey = UserDefaults.standard.string(forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH)
        cell.showTitleLabel.text = languageTitles[indexPath.row]
         cell.showRightImageView.image = localLanguageKey == languageKeys[indexPath.row] ? UIImage.init(named: "selected_icon") : UIImage.init()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let localLanguageKey = UserDefaults.standard.string(forKey: LOCALIZABLE_SAVE_LANGUAGE_SWITCH)
        if localLanguageKey == languageKeys[indexPath.row] {
            return
        }
        if SessionManager.shared.isCurrentMeeting {  // 正在会议中时
            let vc = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.customDelegate = self
            vc.view.tag = indexPath.row
            self.present(vc, animated: true, completion: nil)
        } else {
            self.switchLanguage(indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.languageTitles.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableTitleSymbolCell.CELL_HEIGHT
    }
}
