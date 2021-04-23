//
//  SettingAdvancedViewController.swift
//  HWCloudLink
//
//  Created by Jabien on 2020/9/3.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class SettingAdvancedViewController: UITableViewController {
    // SRTP
    private var srtpText: String = ""
    // BFCP
    private var bfcpText: String = ""
    
    private let srtpTexts = [
        tr("可选"),
        tr("不启用"),
        tr("强制"),
        tr("取消"),
    ]

    private let bfcpIndexArray = [TSDK_E_BFCP_TRANSPORT_UDP,
                                  TSDK_E_BFCP_TRANSPORT_TCP,
                                  TSDK_E_BFCP_TRANSPORT_TLS,
                                  TSDK_E_BFCP_TRANSPORT_AUTO]
    private let bfcpTexts = [
        "UDP",
        "TCP",
        "TLS",
        "AUTO",
        tr("取消")
    ]

    func getBFCPIndex(value: Int) -> Int {
        for (index, valueT) in bfcpIndexArray.enumerated() {
            if value == valueT.rawValue {
                return index
            }
        }
        return 3
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.settingLocalConfig()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tr("高级设置")
        self.setupUI()
    }
    
    func setupUI() {
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.tableView.register(UINib.init(nibName: TableTextNextCell.CELL_ID, bundle: nil), forCellReuseIdentifier: TableTextNextCell.CELL_ID)
        self.tableView.separatorStyle = .none
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - 设置本地配置信息
    func settingLocalConfig() {
        let srtpIndex = Int(ServerConfigInfo.value(forKey: .srtp)) ?? 0
        srtpText = srtpTexts[srtpIndex]
        
        let bfcpIndex = Int(ServerConfigInfo.value(forKey: .bfcp)) ?? 0
        bfcpText = bfcpTexts[getBFCPIndex(value: bfcpIndex)]
        self.tableView.reloadData()
    }

    // MARK: - click 返回按钮
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableTextNextCell.CELL_HEIGHT
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableTextNextCell.CELL_ID) as! TableTextNextCell
        cell.showTipLabel.isHidden = true
        cell.showRightTitleLabel.isHidden = false
        cell.showTitleLabel.isHidden = false
        if indexPath.row == 0 {
            cell.showTitleLabel.text = tr("SRTP加密")
            cell.showRightTitleLabel.text = srtpText
        } else {
            cell.showTitleLabel.text = tr("BFCP传输类型")
            cell.showRightTitleLabel.text = bfcpText
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 国密开启后，不可配置
        if ServerConfigInfo.value(forKey: .smSecurity) == "1" { return }
        if indexPath.row == 0 { // SRTP加密
            let popTitleVC = PopTitleNormalViewController.init(nibName: "PopTitleNormalViewController", bundle: nil)
            popTitleVC.modalTransitionStyle = .crossDissolve
            popTitleVC.modalPresentationStyle = .overFullScreen
            popTitleVC.showName = tr("SRTP加密")
            popTitleVC.dataSource = srtpTexts
            popTitleVC.customDelegate = self
            popTitleVC.isShow = true
            popTitleVC.view.tag = 10
            self.present(popTitleVC, animated: true, completion: nil)
        }else if indexPath.row == 1 { // BFCP传输类型
            let popTitleVC = PopTitleNormalViewController.init(nibName: "PopTitleNormalViewController", bundle: nil)
            popTitleVC.modalTransitionStyle = .crossDissolve
            popTitleVC.modalPresentationStyle = .overFullScreen
            popTitleVC.showName = tr("BFCP传输类型")
            popTitleVC.dataSource = bfcpTexts
            popTitleVC.customDelegate = self
            popTitleVC.isShow = true
            popTitleVC.view.tag = 100
            self.present(popTitleVC, animated: true, completion: nil)
        }
    }
}

// MARK: - PopTitleNormalViewDelegate
extension SettingAdvancedViewController: PopTitleNormalViewDelegate {
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
        
    }
    
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
        viewVC.dismiss(animated: true, completion: nil)
        if index.row == -1 {
            return
        }
        if viewVC.view.tag == 10 { // SRTP
            if index.row == 2 {
                srtpText = srtpTexts[index.row]
                //0 -> OPTION, 1-> DISABLE, 2-> FORCE
                UserDefaults.standard.setValue(index.row, forKey: DICT_SAVE_SRTPENCRYPTIONN)
                ServerConfigInfo.set(value: "\(index.row)", forKey: .srtp)
            } else {
                // 弹框
                let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
                alertTitleVC.customDelegate = self
                alertTitleVC.vcTag = 20
                alertTitleVC.modalTransitionStyle = .crossDissolve
                alertTitleVC.modalPresentationStyle = .overFullScreen
                alertTitleVC.accessibilityValue = String(index.row)
                self.present(alertTitleVC, animated: true, completion: nil)
                return
            }
        } else { // BFCP
            if index.row == 0 || index.row == 2 || index.row == 3 { // UDP | TCP
                // 当前是UDP | TCP时，不弹框
                if (index.row == 0 && bfcpText == bfcpTexts[index.row]) ||
                    (index.row == 2 && bfcpText == bfcpTexts[index.row])  ||
                      (index.row == 3 && bfcpText == bfcpTexts[index.row]) {
                    return
                }
                // 弹框
                let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
                alertTitleVC.customDelegate = self
                alertTitleVC.vcTag = 200
                alertTitleVC.modalTransitionStyle = .crossDissolve
                alertTitleVC.modalPresentationStyle = .overFullScreen
                alertTitleVC.accessibilityValue = String(index.row)
                self.present(alertTitleVC, animated: true, completion: nil)
                return
            } else {
                CLLog("BDCPVALUE:bfcpIndexArray[index.row].rawValue\(bfcpIndexArray[index.row].rawValue)")
                bfcpText = bfcpTexts[index.row]
                UserDefaults.standard.setValue(bfcpIndexArray[index.row].rawValue, forKey: DICT_SAVE_BFCPTRANSFERMODE)
                ServerConfigInfo.set(value: "\(bfcpIndexArray[index.row].rawValue)", forKey: .bfcp)
            }
        }
        
        DispatchQueue.main.async {
            // 重新获取服务器配置信息进行更新
            let serverInfo = ServerConfigInfo.valuesArray()
            UserDefaults.standard.setValue(serverInfo, forKey: SERVER_CONFIG_INFO)
            LoginCenter.sharedInstance()?.updateServerConfigInfo(false)
            self.tableView.reloadData()
        }
    }
}

// MARK: - TextTitleViewDelegate
extension SettingAdvancedViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.vcTag == 20 {
            viewVC.showTitleLabel.text = viewVC.accessibilityValue == "0" ?
                tr("可选模式存在安全隐患，建议使用强制。是否继续选择可选？") :
                tr("不启用模式存在安全隐患，建议使用强制。是否继续选择不启用？")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        } else {
            let temTag = Int(viewVC.accessibilityValue ?? "")
            switch temTag {
            case 0:
                viewVC.showTitleLabel.text = tr("UDP模式存在安全隐患，建议使用TLS。是否继续选择UDP？")
            case 2:
                viewVC.showTitleLabel.text =  tr("TCP模式存在安全隐患，建议使用TLS。是否继续选择TCP？")
            case 3:
                viewVC.showTitleLabel.text = tr("AUTO模式存在安全隐患，建议使用TLS。是否继续选择AUTO？")
            default:
                break
            }
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        
    }
    
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        guard let indexStr = viewVC.accessibilityValue, let index = Int(indexStr) else {
            return
        }
        if viewVC.vcTag == 20 {
            srtpText = srtpTexts[index]
            //0 -> OPTION, 1-> DISABLE, 2-> FORCE
            UserDefaults.standard.setValue(index, forKey: DICT_SAVE_SRTPENCRYPTIONN)
            ServerConfigInfo.set(value: "\(index)", forKey: .srtp)
            
        } else {
            bfcpText = bfcpTexts[index]
            CLLog("BDCPVALUE:bfcpIndexArray[index.row].rawValue\(bfcpIndexArray[index].rawValue)")
            UserDefaults.standard.setValue(bfcpIndexArray[index].rawValue, forKey: DICT_SAVE_BFCPTRANSFERMODE)
            ServerConfigInfo.set(value: String(bfcpIndexArray[index].rawValue), forKey: .bfcp)
            // 重新获取服务器配置信息进行更新
            let serverInfo = ServerConfigInfo.valuesArray()
            UserDefaults.standard.setValue(serverInfo, forKey: SERVER_CONFIG_INFO)
            LoginCenter.sharedInstance()?.updateServerConfigInfo(false)
        }
        self.tableView.reloadData()
    }    
}
