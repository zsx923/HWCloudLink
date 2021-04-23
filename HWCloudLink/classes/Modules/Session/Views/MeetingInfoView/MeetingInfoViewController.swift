//
//  MeetingInfoViewController.swift
//  LandscapeTest
//
//  Created by wangyh1116 on 2020/12/31.
//

import UIKit

let LookAudioAndVideoQualityNotifiName = "LookAudioAndVideoQualityNotifiName"
private let meetingInfoSecretId = "MeetingInfoSecretCell"
private let meetingInfoNormalId = "MeetingInfoNormalCell"
private let meetingInfoQualityId = "MeetingInfoQualityCell"
private let meetingInfoHeaderId = "MeetingInfoHeaderCell"

enum MeetingInfoRowType {
    case headInfo
    case protectInfo
    case terminalNumber
    case meetingId
    case guestPassword
    case chairmanPassword
    case meetingQuality
}

class MeetingInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {

    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    public var displayShowRotation: UIInterfaceOrientation = .landscapeRight
    var dataSource = [MeetingInfoRowType]()
    var isShowChairmanPassword: Bool = false
    var netLevel:String = "5"
    var infoModel: MeetingInfoModel? {
        didSet {
            netLevel = infoModel?.netLevel ?? netLevel
            updateDataSource()
        }
    }

    @objc func back() {
        self.dismiss(animated: true) {
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        switch displayShowRotation {
        case .landscapeLeft, .landscapeRight:
            leftConstraint.constant = isiPhoneXMore() ? (SCREEN_HEIGHT-88.0)/2.0 : SCREEN_HEIGHT/2.0
        case .portrait, .portraitUpsideDown:
            leftConstraint.constant = 0
        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(back))
        tapHandler.delegate = self
        self.view.addGestureRecognizer(tapHandler)
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: meetingInfoSecretId, bundle: nil),
                                forCellReuseIdentifier: meetingInfoSecretId)
        self.tableView.register(UINib(nibName: meetingInfoNormalId, bundle: nil),
                                forCellReuseIdentifier: meetingInfoNormalId)
        self.tableView.register(UINib(nibName: meetingInfoQualityId, bundle: nil),
                                forCellReuseIdentifier: meetingInfoQualityId)
        self.tableView.register(UINib(nibName: meetingInfoHeaderId, bundle: nil),
                                forCellReuseIdentifier: meetingInfoHeaderId)
        //注册视频质量的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notficationVideoNetUpdate(notfication:)), name: NSNotification.Name("NET_LEVEL_UPDATE_NOTIFI"), object: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if String(describing: touch.view?.classForCoder).contains("UITableViewCellContentView") {
            return false
        }else {
            return true
        }
    }
    
    // 视频质量变化
    @objc func notficationVideoNetUpdate(notfication:Notification) {
        guard let userInfo = notfication.userInfo as? [String:String], let tempLevel = userInfo["netLevel"] else {
            return
        }
        if netLevel == tempLevel {
            return
        }
        netLevel = tempLevel
        tableView.reloadData()
    }
    
    deinit {
        CLLog("MeetingInfoViewController deinit")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowType = dataSource[indexPath.row]
        switch rowType {
        case .headInfo:
            return headInfoCell(tableView, indexPath)
        case .protectInfo:
            return protectInfoCell(tableView, indexPath)
        case .meetingId:
            return meetingIdCell(tableView, indexPath)
        case .terminalNumber:
            return terminalNumberCell(tableView, indexPath)
        case .guestPassword:
            return guestPasswordCell(tableView, indexPath)
        case .chairmanPassword:
            return chairmanCell(tableView, indexPath)
        case .meetingQuality:
            return signalQuality(tableView, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = dataSource[indexPath.row]
        switch rowType {
        case .meetingQuality:
            return 54
        case .chairmanPassword:
            if (infoModel?.isChairman ?? false) {
                return 72
            }else {
                return 0.00001
            }
        case .meetingId, .guestPassword, .terminalNumber:
            return 72
        case .headInfo:
            return 100 + caculateNameLableHeight()
        case .protectInfo:
            return 0.00001
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == (dataSource.count - 1) {
            print("点击信息质量图标")
        }
    }

    fileprivate func updateDataSource() {
        guard let model = infoModel else { return }
        dataSource.removeAll()
        dataSource.append(.headInfo)
        switch model.type {
        case .video:
            dataSource.append(.terminalNumber)
        case .voiceMeeting, .svcMeeting, .avcMeeting:
            if model.isProtect {
                dataSource.append(.protectInfo)
            }
            dataSource.append(.meetingId)
            if !model.guestPassword.isEmpty {
                dataSource.append(.guestPassword)
            }
            if !model.chairmanPassword.isEmpty {
                dataSource.append(.chairmanPassword)
            }
        }
        dataSource.append(.meetingQuality)
    }
    
    fileprivate func configChairmanCell(_ cell: MeetingInfoNormalCell) {
        if let chairmanPassword = self.infoModel?.chairmanPassword {
//            cell.valueLabel.text = self.isShowChairmanPassword ? chairmanPassword : String(repeating: "•", count: 6)
            cell.valueLabel.text = self.isShowChairmanPassword ? chairmanPassword : "*** ***"
        }
        var image = UIImage.init(named: self.isShowChairmanPassword ? "icon_openeye_default" : "icon_closeeye_default")
        image = image?.withRenderingMode(.alwaysTemplate)
        cell.iconButton.setImage(image, for: .normal)
    }
    
    fileprivate func chairmanCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoNormalId, for: indexPath) as! MeetingInfoNormalCell
        cell.keyLabel.text = tr("主持人密码")
        cell.iconButton.isHidden = false
        
        self.configChairmanCell(cell)
        cell.callback = { [weak self] (tmpCell) in
            guard let self = self else {return}
            self.isShowChairmanPassword = !self.isShowChairmanPassword
            self.configChairmanCell(tmpCell)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    fileprivate func meetingIdCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoNormalId, for: indexPath) as! MeetingInfoNormalCell
        cell.keyLabel.text = tr("会议ID")
        cell.valueLabel.text = NSString.dealMeetingId(withSpaceString: infoModel?.meetingId ?? "")
        cell.iconButton.setImage(UIImage(named: "icon_copy_default"), for: .normal)
        cell.iconButton.isHidden = false
        cell.callback = {[weak self]  (tmpCell)  in
            // 复制代码
            UIPasteboard.general.string = self?.infoModel?.meetingId
            MBProgressHUD.showBottom(tr("已复制到剪贴板"), icon: nil, view: nil)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    fileprivate func headInfoCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoHeaderId, for: indexPath) as! MeetingInfoHeaderCell
        cell.nameLabel.text = infoModel?.name
//        let labelWidth = UILabel.getLabelWidth(with: cell.nameLabel)
//        cell.nameLabel.textAlignment = (labelWidth > (SCREEN_WIDTH - 100))  ? .left : .center
        
        if case .video = infoModel?.type {
            cell.dateLabel.text = ""
        } else {
            cell.dateLabel.attributedText = infoModel?.dateStr
        }
        cell.selectionStyle = .none
        return cell
    }
    
    private func caculateNameLableHeight() -> CGFloat {
        if infoModel?.name.count == 0 {
            return 0
        }else {
            return getTextHeigh(textStr: infoModel?.name ?? "", font: UIFont.systemFont(ofSize: 22), width: SCREEN_WIDTH - 40)
        }
    }
    
    private func getTextHeigh(textStr : String, font : UIFont, width : CGFloat)  -> CGFloat{

         let normalText : NSString = textStr as NSString

         let size = CGSize(width: width, height:1000)
         let dic = NSDictionary(object: font, forKey : kCTFontAttributeName as! NSCopying)

         let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key:Any], context:nil).size

         return  stringSize.height
    }

    
    fileprivate func terminalNumberCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoNormalId, for: indexPath) as! MeetingInfoNormalCell
        cell.keyLabel.text = tr("终端号码")
        cell.valueLabel.text = infoModel?.number
        cell.iconButton.isHidden = true
        cell.selectionStyle = .none
        return cell
    }
    
    fileprivate func guestPasswordCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoNormalId, for: indexPath) as! MeetingInfoNormalCell
        cell.keyLabel.text = tr("来宾密码")
        cell.valueLabel.text = infoModel?.guestPassword
        cell.iconButton.isHidden = true
        cell.selectionStyle = .none
        return cell
    }
    
    fileprivate func signalQuality(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoQualityId, for: indexPath) as! MeetingInfoQualityCell
        cell.networkLabel.text = tr("查看音视频质量")
        cell.arrowImageView.image = UIImage(named: "arrow_next")?.withRenderingMode(.alwaysTemplate)
        cell.networkImageView.image = SessionHelper.getSignalQualityImage(netLevel: netLevel)
        cell.selectionStyle = .none
        cell.callback = { [weak self] (tmpCell) in
            guard let self = self else {return}
            self.back()
            NotificationCenter.default.post(name: NSNotification.Name(LookAudioAndVideoQualityNotifiName), object: nil, userInfo: nil)
        }
        return cell
    }
    
    fileprivate func protectInfoCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingInfoSecretId, for: indexPath) as! MeetingInfoSecretCell
        cell.secretLabel.text = tr("会议已加密")
        cell.selectionStyle = .none
        return cell
    }
}
