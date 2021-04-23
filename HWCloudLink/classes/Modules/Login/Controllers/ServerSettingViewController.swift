//
// ServerSettingViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/3/9.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class ServerSettingViewController: UITableViewController,UITextFieldDelegate {
    
    private var defaultPort = "5061"
    private var alertTips = "alertTips"
    @IBOutlet weak var TLSCompatibilityModeSwtich: UISwitch!
    @IBOutlet weak var TLSCompatibilityModeLabel: UILabel!
    // 服务器地址
    @IBOutlet weak var serverAddrTitleLabel: UILabel!
    @IBOutlet weak var serverAddrValueTextField: UITextField!
    @IBOutlet weak var serverAddLine: UIView!
    // 服务器端口
    @IBOutlet weak var serverPortTitleLabel: UILabel!
    @IBOutlet weak var serverPortValueTextField: UITextField!
    @IBOutlet weak var serverPortLine: UIView!
    // SIP URI
    @IBOutlet weak var serverSipUriValueTextField: UITextField!
    @IBOutlet weak var serverSipUriLine: UIView!
    @IBOutlet weak var SIPTitleLabel: UILabel!
    // 国密
    @IBOutlet weak var guoMiLabel: UILabel!
    @IBOutlet weak var guoMiSwitch: UISwitch!
    // UDP(5060) TLS(5061)登陆模式
    @IBOutlet weak var SIPLabel: UILabel!
    // 保存
    @IBOutlet weak var saveButton: UIButton!
    
    // httpsPort
    @IBOutlet weak var httpsPortTitleLabel: UILabel!
    @IBOutlet weak var httpsPortField: UITextField!
    @IBOutlet weak var httpsPortLine: UIView!
    
    // 登陆配置
    private var srtpMode:SRTP_MODE = SRTP_MODE_OPTION
    private var transportMode:TRANSPORT_MODE = TRANSPORT_MODE_TLS
    private var bfcpModel:TSDK_E_BFCP_TRANSPORT_MODE = TSDK_E_BFCP_TRANSPORT_AUTO
    private var priorityType:CONFIG_PRIORITY_TYPE = CONFIG_PRIORITY_TYPE_APP
    private var tunnelMode:TUNNEL_MODE = TUNNEL_MODE_DEFAULT
    private var sipPortPriority:Bool = false
    // 本地存储的服务器配置
    private var serverArray:NSArray = [];
    
    typealias saveServerAddrBlock = (_ serverAddr: String) -> ()
    var saveCallBack: saveServerAddrBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 初始化
        self.title = tr("服务器设置")
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        initView()
        
        // 处理数据
        serverArray = UserDefaults.standard.object(forKey: SRTP_TRANSPORT_MODE) != nil ? UserDefaults.standard.object(forKey: SRTP_TRANSPORT_MODE) as! NSArray : NSArray.init()
        self.initData()
    }
    
    func initView() {
        // table view
        // 去分割线
        self.tableView.separatorStyle = .none
        self.serverAddrValueTextField.delegate = self
        self.serverPortValueTextField.delegate = self
        self.serverSipUriValueTextField.delegate = self
        self.httpsPortField.delegate = self
        
        self.SIPLabel.textColor = UIColor.lightGray
        
        saveButton.layer.cornerRadius = 2.0
        
        self.serverAddrTitleLabel.text = tr("服务器地址")
        self.serverPortTitleLabel.text = tr("服务器端口")
        self.SIPTitleLabel.text = tr("SIP传输类型")
        self.TLSCompatibilityModeLabel.text = tr("TLS兼容模式")
        self.guoMiLabel.text = tr("国密")
        self.serverAddrValueTextField.placeholder = tr("请输入服务器地址")
        self.serverPortValueTextField.placeholder = tr("请输入服务器端口")
        self.serverSipUriValueTextField.placeholder = tr("请输入地址")
        self.saveButton.setTitle(tr("保存"), for: .normal)
        self.httpsPortTitleLabel.text = tr("HTTPS端口")
        self.httpsPortField.placeholder = tr("请输入HTTPS端口")
    }
    
    func initData() {
        
        // 如果本地有服务器记录 保持一致
        if serverArray.count != 0 {
            // 传输模式
            if serverArray[1] as? String == "0" {
                transportMode = TRANSPORT_MODE_UDP
            }else if serverArray[1] as? String == "1" {
                transportMode = TRANSPORT_MODE_TLS
            }else if serverArray[1] as? String == "2" {
                transportMode = TRANSPORT_MODE_TCP
            }
           /**< [en]Indicates Automatic transmission*/

            // 辅流传输模式
            if serverArray[7] as? String == "0" {
                bfcpModel = TSDK_E_BFCP_TRANSPORT_UDP
            }else if serverArray[7] as? String == "1" {
                bfcpModel = TSDK_E_BFCP_TRANSPORT_TLS
            }else if serverArray[7] as? String == "2" {
                bfcpModel = TSDK_E_BFCP_TRANSPORT_TCP
            }else if serverArray[7] as? String == "3" {
                bfcpModel = TSDK_E_BFCP_TRANSPORT_AUTO
            }
        }
        
        // 传输模式显示
        switch transportMode {
            case TRANSPORT_MODE_UDP:
                self.SIPLabel.text = "UDP"
                self.serverPortValueTextField.text = "5060"
                break
            case TRANSPORT_MODE_TLS:
                self.SIPLabel.text = "TLS"
                self.serverPortValueTextField.text = "5061"
                break
            case TRANSPORT_MODE_TCP:
                self.SIPLabel.text = "TCP"
                self.serverPortValueTextField.text = "5062"
                break
            default: break
        }
        
        if ServerConfigInfo.value(forKey: .port) != "" {
            self.serverPortValueTextField.text = ServerConfigInfo.value(forKey: .port)
        }
        if ServerConfigInfo.value(forKey: .httpsPort) != "" {
            self.httpsPortField.text = ServerConfigInfo.value(forKey: .httpsPort)
        }
        
        // SIP URL显示
        let addArray = UserDefaults.standard.object(forKey: DICT_SAVE_SERVER_INFO) != nil ? UserDefaults.standard.object(forKey: DICT_SAVE_SERVER_INFO) as! NSArray : NSArray.init()
        if addArray.count != 0 && addArray.count > 1 {
            self.serverAddrValueTextField.text = addArray[0] as? String
            if addArray.count == 3 {
                // url
                self.serverSipUriValueTextField.text = addArray[2] as? String
            }
        }

        //国密
        let guoIsOn = NSObject.getUserDefaultValue(withKey: DICT_SAVE_SERVER_INFO_GUOMI_IS_ON) as? String ?? "0"
        if guoIsOn == "1" {
            self.guoMiSwitch.isOn = true
            guoMiUpdateSubViews()
        } else {
            self.guoMiSwitch.isOn = false
        }

        //TLS兼容模式TLSCompatibilityModeSwtich//默认禁用
        let tlsIsOn = ServerConfigInfo.value(forKey: .tlsCompatibility)
        if tlsIsOn == "1" {
            self.TLSCompatibilityModeSwtich.isOn = true
        } else {
            self.TLSCompatibilityModeSwtich.isOn = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
        
    private func guoMiUpdateSubViews() {
        if  guoMiSwitch.isOn {
            self.serverPortValueTextField.text = defaultPort
            self.SIPLabel.text = "TLS"
            transportMode = TRANSPORT_MODE_TLS
            srtpMode = SRTP_MODE_FORCE
            self.serverPortValueTextField.textColor = UIColor.gray
        } else {
            self.serverPortValueTextField.textColor = UIColor.colorWithSystem(lightColor: "#333333", darkColor: "#F0F0F0")
            srtpMode = SRTP_MODE_OPTION
        }
        self.serverPortValueTextField.isUserInteractionEnabled = !guoMiSwitch.isOn
    }
    
    @IBAction func guomiSwitchValueChanged(_ sender: UISwitch) {
        guoMiUpdateSubViews()
    }

    @IBAction func TLSSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            alertTips = tr("TLS兼容模式存在安全隐患，是否继续开启？")
            alertTitleVC(tag: "101")
        }else {
            ServerConfigInfo.set(value: "0", forKey: .tlsCompatibility)
        }
    }

    @IBAction func saveBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        /*
         change at xuegd 2021/01/14 : 不做校验，与 Android 郭磊明(gwx1004312)进行确认（牵扯到了域名，有中文域名的情况）
        // 域名验证
        let uriReg = "(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$"
        let uriRes = checkRes(reg: uriReg, str: serverAddr)
        
        // ipv4验证
        let ipRes = CommonUtils.isValidateIP(serverAddr)
        // ipv6验证
        let ipv6Res = CommonUtils.isValidateIPv6(serverAddr)
        
        if !(uriRes || ipRes || ipv6Res) {
            MBProgressHUD.showBottom(tr("请输入合法的IP地址"), icon: nil, view: self.view)
            return
        }
        */
        
        guard let serverAddr = self.serverAddrValueTextField.text, serverAddr.count > 0 else {
            MBProgressHUD.showBottom(tr("请输入IP和端口"), icon: nil, view: self.view)
            return
        }
        
        guard let serverPort = self.serverPortValueTextField.text, serverPort.count > 0 else {
            MBProgressHUD.showBottom(tr("请输入IP和端口"), icon: nil, view: self.view)
            return
        }
        //端口号校验 0-65536,且如果是0开头的也弹出提示
        let portInt = Int(serverPort) ?? 0
        if  serverPort.hasPrefix("0") || portInt > 65536 {
            MBProgressHUD.showBottom(tr("请输入合法的端口"), icon: nil, view: self.view)
            return
        }
        
        var httpsPort = ""
        if let httpsPortStr = self.httpsPortField.text, httpsPortStr.count > 0 {
            let httpsPortInt = Int(httpsPortStr) ?? 0
            if  httpsPortStr.hasPrefix("0") || httpsPortInt > 65536 || httpsPortInt <= 0 {
                MBProgressHUD.showBottom(tr("请输入合法的端口"), icon: nil, view: self.view)
                return
            }
            httpsPort = "\(httpsPortInt)"
        }
        
//        bfcpModel = transportMode
        let srtp = String.init(format: "%d", srtpMode.rawValue)
        let transport = String.init(format: "%d", transportMode.rawValue)
        let priority = String.init(format: "%d", priorityType.rawValue)
        let portPriority = "1"
        let tunnel = String.init(format: "%d", tunnelMode.rawValue)
        var udpPort = "5060"
        var tlsport = serverPort
        let bfcp = String.init(format: "%d",  bfcpModel.rawValue)
        UserDefaults.standard.setValue(bfcp, forKey: DICT_SAVE_BFCPTRANSFERMODE)

        // change at xuegd: 服务器配置信息，通过ServerConfigInfo类进行存取
        ServerConfigInfo.setValuesWithDictionary(dic: [
            .address : serverAddr,
            .port : serverPort,
            .sipUri : self.serverSipUriValueTextField.text ?? "",
            .httpsPort : httpsPort,
            .udpPort : "5060",
            .tlsPort : "5061",
            .srtp : srtp,
            .transport : transport,
            .bfcp : bfcp,
            .priorityType : priority,
            .tunnel : tunnel,
            .smSecurity : self.guoMiSwitch.isOn ? "1" : "0",
            .tlsCompatibility: self.TLSCompatibilityModeSwtich.isOn ? "1" : "0"
        ])
        
        if transportMode == TRANSPORT_MODE_UDP {
            udpPort = serverPort
            tlsport = "5061"
        }
        
        let infoArr = NSArray.init(objects: serverAddr, serverPort, self.serverSipUriValueTextField.text ?? "")
        UserDefaults.standard.setValue(infoArr, forKey: DICT_SAVE_SERVER_INFO)
        
        let serArr = NSArray.init(objects: srtp, transport, priority, udpPort, tlsport, portPriority, tunnel, bfcp, self.guoMiSwitch.isOn ? "1" : "0")
        UserDefaults.standard.setValue(serArr, forKey: SRTP_TRANSPORT_MODE)
        
        let serverInfo = ServerConfigInfo.valuesArray()
        UserDefaults.standard.setValue(serverInfo, forKey: SERVER_CONFIG_INFO)

        NSObject.userDefaultSaveValue("1", forKey: USE_IDO_CONFCTRL)
        
        NSObject.userDefaultSaveValue(self.guoMiSwitch.isOn ? "1" : "0", forKey: DICT_SAVE_SERVER_INFO_GUOMI_IS_ON)

//        LoginCenter.sharedInstance()?.configSipRelevantParamServerAddress(ServerConfigInfo.value(forKey: .address), serverPort: ServerConfigInfo.value(forKey: .port))
        LoginCenter.sharedInstance()?.updateServerConfigInfo(true)
        UserDefaults.standard.setValue(serverAddr, forKey: CONFIG_SERVER_ADDR)
        UserDefaults.standard.setValue(serverPort, forKey: CONFIG_SERVER_PORT)
        
        Toast.showBottomMessage(tr("保存成功"))
        
        if #available(iOS 14 , *) {
            self.saveCallBack!(serverAddrValueTextField.text ?? "")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkRes(reg:String,str:String) -> Bool {
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        let res = pre.evaluate(with: str)
        return res
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0.01
        }
        return 16.00
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let View = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.01))
            return View
        }
        let View = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 16))
        return View
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
        case 2:
            return 0
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // change at xuegd: 国密开启，SIP传输模式禁止点击
        if self.guoMiSwitch.isOn && indexPath.section == 1 && indexPath.row == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.tableView.endEditing(true)
        if indexPath.section == 1 && indexPath.row == 0 {
            let popTitleVC = PopTitleNormalViewController.init(nibName: "PopTitleNormalViewController", bundle: nil)
            popTitleVC.modalTransitionStyle = .crossDissolve
            popTitleVC.modalPresentationStyle = .overFullScreen
            popTitleVC.showName = tr("SIP传输类型")
            popTitleVC.dataSource = ["TLS", "UDP", tr("取消")]
            popTitleVC.customDelegate = self
            popTitleVC.isShow = true
            self.present(popTitleVC, animated: true, completion: nil)
        }
    }
            
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK:  - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
        if textField == self.serverAddrValueTextField {
            if nowString.count > WORDCOUNT_SERVER_IP_COUNT_MAX {
                return false
            }
        }
        
        if textField == self.serverPortValueTextField {
            if nowString.count > WORDCOUNT_SERVER_PORT_COUNT_MAX {
                return false
            }
        }
        
        if textField == self.serverSipUriValueTextField {
            if nowString.count > WORDCOUNT_SERVER_URI_COUNT_MAX {
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.serverAddrValueTextField {
            self.serverAddLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
            self.serverPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.serverSipUriLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.httpsPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
        } else if textField == self.serverPortValueTextField {
            self.serverAddLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.serverPortLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
            self.serverSipUriLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.httpsPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
        } else if textField == self.serverSipUriValueTextField {
            self.serverAddLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.serverPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.serverSipUriLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
            self.httpsPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
        } else if textField == self.httpsPortField {
            self.serverAddLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.serverPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.serverSipUriLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
            self.httpsPortLine.backgroundColor = UIColorFromRGB(rgbValue: 0x0D94FF)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.serverAddLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
        self.serverPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
        self.serverSipUriLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
        self.httpsPortLine.backgroundColor = UIColor.colorWithSystem(lightColor: UIColor(hexString: "e9e9e9"), darkColor: UIColor(hexString: "1f1f1f"))
    }
    
    deinit {
        CLLog("ServerSettingViewController deinit")
    }
}

// MARK: -
extension ServerSettingViewController: PopTitleNormalViewDelegate{
    func popTitleNormalViewDidLoad(viewVC: PopTitleNormalViewController) {
    }
    
    func popTitleNormalViewCellClick(viewVC: PopTitleNormalViewController, index: IndexPath) {
            viewVC.dismiss(animated: true, completion: nil)
            if index.row == 0 {
                self.SIPLabel.text = "TLS"
                self.serverPortValueTextField.text = "5061"
                transportMode = TRANSPORT_MODE_TLS
            }else if index.row == 1 { // UDP弹窗
                // 弹出授权框
                alertTips = tr("UDP模式存在安全隐患，建议使用TLS，是否继续选择UDP？")
                alertTitleVC(tag: "100")
            }
    }
}
extension ServerSettingViewController {
    func alertTitleVC(tag :String)  {
        let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.accessibilityValue = tag
        alertTitleVC.customDelegate = self
        self.present(alertTitleVC, animated: true, completion: nil)
    }
}
// MARK: -
extension ServerSettingViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        viewVC.showTitleLabel.text = alertTips
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
    }
    
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        if viewVC.accessibilityValue == "101" {
            self.TLSCompatibilityModeSwtich.isOn = false
        }
    }
    
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {

        if viewVC.accessibilityValue == "100" {
            self.SIPLabel.text = "UDP"
            transportMode = TRANSPORT_MODE_UDP
            self.serverPortValueTextField.text = "5060"
        }else {
            ServerConfigInfo.set(value: "1", forKey: .tlsCompatibility)
        }


    }
}
