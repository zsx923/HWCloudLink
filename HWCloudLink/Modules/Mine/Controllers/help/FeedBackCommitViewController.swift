//
//  FeedBackCommitViewController.swift
//  HWCloudLink
//
//  Created by 严腾飞 on 2020/7/17.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import MessageUI

private let cellId = "feedBackCommitCell"
private let imageWH: CGFloat = 47

enum TextTitleAlertType {
    case backViewAlert          // 确认退出界面alert
    case sureUploadLogAlert     // 确认上传日志alert
}

class FeedBackCommitViewController: UIViewController, UITextViewDelegate {
/*
    @IBOutlet weak var topTextView: UITextView!
    @IBOutlet weak var textViewHightConstant: NSLayoutConstraint!
    @IBOutlet weak var topViewHightConstant: NSLayoutConstraint! //承载textview的底部view
    
//    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var tfLabel: UILabel!
    @IBOutlet weak var imagesBackView: UIView!
    @IBOutlet weak var imageCountLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    */
    static var isLogUpLoad: Bool = false //3.0
    @IBOutlet weak var tableView: UITableView!
    var headerView: FeedBackCommitHeaderView = {
        let view = FeedBackCommitHeaderView.creatFeedBackCommitHeaderView()
        return view
    }()
    var footerView :FeedBackCommitFooterView = {
        let view = FeedBackCommitFooterView.creatFeedBackCommitFooterView()
        return view
    }()
    
    
    var tempHight = 30 //记录 textfield 的高度，默认给30
    var contentStr: String = ""
    var picDatasource:[UIImage] = [] //从相册选取完毕以及拍照完毕 都需要存储在这个数组中
    private var abnormalTimer: Timer?
    private var actionAcount: CGFloat = 0
    private var logsDatas: [String] = [] //日志数组
    private var selImages: [UIImage] = [UIImage]()
//    private var pictures: [UIImageView] = [UIImageView]()
//    private var addImageView: UIImageView?
    private var sdkLogPath:[String] = [] //存储sdk日志全路径
    var cellIndexPath = NSMutableArray.init() //多选
    var selectedDates = NSMutableArray()
    var isUpLoading: Bool = false
    var netIsNormal:Bool = true {
        willSet {
            if isUpLoading == true {
                isUpLoading = false
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(tr("暂无网络"), icon: nil, view: self.view)
            }
                 
        }
    }
    private var uploadSMC3FilePath = "" // 上传SMC3.0的path路径
    private var showAlertType = TextTitleAlertType.backViewAlert
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.checkLog()
        self.title = tr("问题反馈")
        setupTableView()
         //接受预览图片页面删除图片发送的通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDeleteNoti(noti:)), name: NSNotification.Name(rawValue: mine_set_deleteImageView), object: nil)
        
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

    }

    //MARK: 接受通知，删除数组中的数据源信息
    @objc func receiveDeleteNoti(noti:Notification){
        let index = noti.userInfo!["index"]
        picDatasource.remove(at: index as! Int)
        headerView.deleteImageViewWithIndex(index: index as! Int)
        self.tableView.reloadData()
    }
    // MARK: - Subviews
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 54
        tableView.separatorStyle = .none
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 250)
        tableView.tableHeaderView = headerView
        footerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        tableView.tableFooterView = footerView
    
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        //MARK: 提交反馈
        footerView.passCommitValueBlock = { [weak self] () in
            CLLog("提交了反馈")
            guard let self = self else { return }
            if  self.headerView.getContentStr() == ""{
                self.contentStr = ""
            }else{
                self.contentStr = self.headerView.getContentStr()
            }
            
            self.view.endEditing(true)
            if self.contentStr == "" {
                MBProgressHUD.showBottom(tr("内容描述不能为空"), icon: nil, view: self.view)
                return
            }
            if NetworkUtils.unavailable() {
                self.isUpLoading = false
                self.netIsNormal = false
                MBProgressHUD.showBottom(tr("暂无网络"), icon: nil, view: self.view)
                CLLog("暂无网络")
                return
            } else {
                self.isUpLoading = false
                self.netIsNormal = true
            }
            if FeedBackCommitViewController.isLogUpLoad {
                if self.actionAcount == 0 {
                    self.actionAcount = 1
                    MBProgressHUD.feedViewshowBottom(tr("正在上传"), icon: nil, view: nil)
                    self.startAbnormalTimer()
                    return
                }
                if self.actionAcount == 1{
                    MBProgressHUD.feedViewshowBottom(tr("请勿重复点击！"), icon: nil, view: nil)
                }

                CLLog("日志上传中")
                return
            }
            MBProgressHUD.showMessage(tr("正在打包日志，请稍等"))
            if ManagerService.call()?.isSMC3 == true ,LoginCenter.sharedInstance().getUserLoginStatus() !=  UserLoginStatus.unLogin { //3。0 单独处理
                self.isUpLoading = true
                self.commitLocalData()
                return
             }
            self.sendEmailforPrintLog()
        }
        //MARK:添加图片
        headerView.passAddImageViewBlock = { [weak self]() in
            guard let self = self else { return }
            self.showBottomAlert()
        }
        //MARK:是否显示日志
        headerView.passIsDisplayLocalLogsBlock = { [weak self] (isYES : Bool) in
            guard let self = self else { return }
            if isYES{
                self.getLocalLog()
            }else{
                self.logsDatas.removeAll()
                self.cellIndexPath.removeAllObjects()
                self.selectedDates.removeAllObjects()
            }
            self.tableView.reloadData()
        }
        //MARK:点击图片，显示大图
        headerView.passDisplayImageBlock = { [weak self] (index : Int) in
            guard let self = self else { return }
            let pre = PreviewImageViewController.init()
            pre.index = index
            pre.imageArray = self.picDatasource
            self.navigationController?.pushViewController(pre, animated: true)
        }
        //MARK:更新headerview的高度
        headerView.passUpDateTextViewHightBlock = { [weak self] (hight: Int , isAdd: Bool) in
            guard let self = self else { return }
            var frame  =  self.headerView.frame
            frame.size.height = 250 - 31 + CGFloat(hight)
            self.headerView.frame = frame
            self.tableView.reloadData()
        }
        //MARK: 获取输入的内容
        headerView.passContentValueBlokc = { [weak self] (content: String) in
            guard let self = self else { return }
            self.contentStr = content
            if content == ""   {
                self.footerView.updateCommitBtnStatus(isYES: false)
            }else {
                self.footerView.updateCommitBtnStatus(isYES: true)
            }
        }
    }
    func getLocalLog(){
        logsDatas.removeAll()
        let logPath = "/Documents/Log/"
        let allPath = NSHomeDirectory() + logPath
        let manager = FileManager.default
        let isFile = manager.fileExists(atPath: allPath)
        if  isFile == false {
            return
        }
        var dateArray:[String] = []
        let fileArray = try?  manager.contentsOfDirectory(atPath: allPath)
        for fileName in (fileArray! as Array) {
            let longDate = fileName.components(separatedBy: " ")[1]
            let shortDate = longDate.subString(to: 10) //2020-12-31
            dateArray.append(shortDate) //所有的日志全部放进数组中
        }
        dateArray.sort { (item1, item2) -> Bool in
            return item1 > item2
        }
        dateArray = dateArray.filterDuplicates({$0})
        while dateArray.count > 3 { //保留最新的3天的日志信息
            dateArray.removeLast()
        }
        logsDatas = dateArray
        //开启日志默认选中第一条日志
        let index = NSIndexPath.init(row: 0, section: 0)
        self.cellIndexPath.add(index)
        self.selectedDates.add(self.logsDatas[index.row])
        tableView.cellForRow(at: index as IndexPath)
    }
    func getTSDKlogPath(){
        sdkLogPath.removeAll()
        let frontPath = "/Documents/TUPC60log/tsdk/"
        let hmeaPath = NSHomeDirectory() + frontPath + "hmea"
        let hmevPath = NSHomeDirectory() + frontPath + "hmev"
        let opensdkPath = NSHomeDirectory() + frontPath + "opensdk"
        let tsdkPath = NSHomeDirectory() + frontPath + "tsdk"
        
        let manager = FileManager.default
        let today = self.getTodayStr()
        
        let pathArray = [hmeaPath,hmevPath,opensdkPath,tsdkPath]
        //遍历所有的路径，
        for sdkPath in pathArray {
            let exist_hmeaPath = manager.fileExists(atPath: sdkPath)
            if  exist_hmeaPath == false {
                return
            }
            let innerName_hmeaPath = try?  manager.contentsOfDirectory(atPath: sdkPath)
            //遍历当前路径下的每一个文件
            for logName_hmeaPath in (innerName_hmeaPath! as Array)  {
                let allPath = sdkPath + "/" + logName_hmeaPath
                if logName_hmeaPath.hasSuffix(".zip") { //是.zip结尾的，判断是不是选中的日期，
                    let lastDate = logName_hmeaPath.components(separatedBy: "_").last //"20201222094801.zip"
                    let newTimeDate = lastDate?.subString(from: 0, to: 7)//20201222
                    let changedDate = self.changeDateStr(date: newTimeDate!)//2020-12-22
                    for  item   in (selectedDates as Array) {
                        if (item as! String) == changedDate {
                            sdkLogPath.append(allPath)
                        }
                    }
                }else{
                    for  item   in (selectedDates as Array) {
                        if (item as! String) == today {
                            sdkLogPath.append(allPath)
                        }
                    }
                    
                }
            }
            
        }
         
    }
    
    func getTodayStr() -> String {
        //获得时间戳
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        return result
    }
    func changeDateStr(date:String) -> String {
        var tempDate = date
        let oneIndex = tempDate.index(date.endIndex, offsetBy: -4)
        let twoIndex = tempDate.index(date.endIndex,offsetBy: -1)
         tempDate.insert(contentsOf: "-", at: oneIndex)
         tempDate.insert(contentsOf: "-", at: twoIndex)
        return tempDate
    }
    //MARK: -  返回
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        if contentStr != ""  {
            self.showAlertType = .backViewAlert
            let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
            alertTitleVC.modalTransitionStyle = .crossDissolve
            alertTitleVC.modalPresentationStyle = .overFullScreen
            alertTitleVC.customDelegate = self
            self.present(alertTitleVC, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    deinit {
        CLLog("deinit.")
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension FeedBackCommitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)! as UITableViewCell
        cell.textLabel?.text = logsDatas[indexPath.row]
        if self.cellIndexPath.contains(indexPath) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.cellIndexPath.contains(indexPath) {
            self.cellIndexPath.remove(indexPath)
            self.selectedDates.remove(self.logsDatas[indexPath.row])
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
        } else {
            self.cellIndexPath.add(indexPath)
            self.selectedDates.add(self.logsDatas[indexPath.row])
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
extension FeedBackCommitViewController {
    func stopAbnormalTimer() {
        self.abnormalTimer?.invalidate()
        self.abnormalTimer = nil
    }
    func startAbnormalTimer() {
        self.stopAbnormalTimer()
        self.abnormalTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            DispatchQueue.main.async {
                self.actionAcount = 0
            }
        }

    }
}
// MARK: - 相机相册
extension FeedBackCommitViewController {
    private func showBottomAlert(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title:tr("取消"), style: .cancel, handler: nil)
        let takingPictures = UIAlertAction(title:tr("相机"), style: .default){ action in
            self.goCamera()
        }
        let localPhoto = UIAlertAction(title:tr("相册"), style: .default){ action in
            self.goImage()
        }
        alertController.addAction(cancel)
        alertController.addAction(takingPictures)
        alertController.addAction(localPhoto)
        
        if alertController.responds(to: #selector(getter: popoverPresentationController)) {
            alertController.popoverPresentationController?.sourceView = self.headerView.addImageView
            alertController.popoverPresentationController?.sourceRect = CGRect.init(x: 0, y: 0, width: 60, height: 50)
            alertController.popoverPresentationController?.permittedArrowDirections = .any
        }
        
        self.present(alertController, animated:true, completion:nil)
  
        
//        let imagePickTool = CLImagePickerTool()
//        imagePickTool.cameraOut = true
//        imagePickTool.cl_setupImagePickerWith(MaxImagesCount: 3 - picDatasource.count, superVC: self) { (assets , image) in
//            let size = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//            let imageArray = CLImagePickerTool.convertAssetArrToThumbnailImage(assetArr: assets, targetSize: size)
//
//            self.picDatasource.insert(contentsOf: imageArray, at: 0)// += imageArray
//
//            self.headerView.addNewImageView(imageArray: self.picDatasource)
//        }
    }
    //MARK:相册选择
    private func goImage(){
        /*
        let photoPicker =  UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        photoPicker.sourceType = .photoLibrary
        self.present(photoPicker, animated: true, completion: nil)
        */
         
        let imagePickTool = CLImagePickerTool()
        imagePickTool.cameraOut = true
        imagePickTool.isHiddenVideo = true
        imagePickTool.cl_setupImagePickerWith(MaxImagesCount: 3 - picDatasource.count, superVC: self) { (assets , image) in
          
            //获取原图
            CLImagePickerTool.convertAssetArrToOriginImage(assetArr: assets, scale: 1.0, successClouse: { (originImage, asset) in
                self.picDatasource.insert(originImage, at: 0)
            }) {
                
            }
           //获取缩略图
//          convertAssetArrToThumbnailImage(assetArr: assets, targetSize: size)
//          self.picDatasource.insert(contentsOf: imageArray, at: 0)// += imageArray
            self.headerView.addNewImageView(imageArray: self.picDatasource)
           
        }
    }
    //MARK:  拍照
    private func goCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
             
            let  cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = false
            cameraPicker.sourceType = .camera
            self.present(cameraPicker, animated: true, completion: nil)
             
           
        }
    }
     
}

// MARK: - UIImagePickerControllerDelegate
extension FeedBackCommitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        selImages.append(image)
//        self.addImageView?.isHidden = self.selImages.count == 3
//        setupImageViews()
        self.picDatasource.insert(image, at: 0)
        headerView.addNewImageView(imageArray:self.picDatasource )
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextTitleViewController 代理方法实现
extension FeedBackCommitViewController: TextTitleViewDelegate {
    // MARK: - TextTitleViewDelegate
    // MARK: view did load
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        switch self.showAlertType {
        case .backViewAlert:
            viewVC.showTitleLabel.text = tr("您编辑的内容还未提交，确定要放弃操作吗?")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("放弃"), for: .normal)
        case .sureUploadLogAlert:
            viewVC.showTitleLabel.text = tr("确认上传日志文件?")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        
    }
    
    // MARK: left btn click
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
    }
    
    // MARK: right btn click
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        switch self.showAlertType {
        case .backViewAlert:
            self.navigationController?.popViewController(animated: true)
        case .sureUploadLogAlert:
//            MBProgressHUD.showMessage("")
            DispatchQueue.global().async {
                let result = ManagerService.confService()?.upLoadLog(withPath: self.uploadSMC3FilePath)
                FeedBackCommitViewController.isLogUpLoad = true
                CLLog("上传返回结果result:\(String(result!))")
            }
            guard let vc = self.navigationController?.viewControllers[0] else { return }
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
}

//MARK: - 2.0 邮件上传日志
extension FeedBackCommitViewController: MFMailComposeViewControllerDelegate {
    private func sendEmailforPrintLog() {

        //2.0采用邮件发送
        if self.selectedDates.count > 0 {
            self.getTSDKlogPath()
        }
        //选中的日期
        var resultDateArray:[String] = []
        for item  in self.selectedDates {
            resultDateArray.append(item as? String ?? "")
        }
        DispatchQueue.global().async {
            var datas = Data()
            if let data = ISLogFileManager.getISLog(withDateArray: resultDateArray, images: self.picDatasource, sdkLogPathArray: self.sdkLogPath){
                datas.append(data)
            }
            let dataMax = datas.count
            if dataMax > LOGSIZEMAX{//日志大小限制600M
                DispatchQueue.main.async {
                  MBProgressHUD.hide()
                  MBProgressHUD.showBottom(tr("日志上传失败，大小超出600M的限制"), icon: nil, view: nil)
                }
               return
            }
        DispatchQueue.main.async {
        if MFMailComposeViewController.canSendMail() {
            CLLog("安装了邮件")
            let mailCompose = MFMailComposeViewController()
            mailCompose.mailComposeDelegate = self
            mailCompose.setSubject(tr("用户日志"))
            mailCompose.setToRecipients([""])
            mailCompose.setMessageBody(self.contentStr, isHTML: false)
            let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
            let loginUserName = loginInfo?.account
            let time = NSString.getTimestamp()

            mailCompose.addAttachmentData(datas, mimeType: "", fileName: "\("HWCloudLink")_\(loginUserName ?? "")_\(time ?? "")_\(self.randomStr(len: 6)).zip")
            MBProgressHUD.hide()
            self.present(mailCompose, animated: true, completion: nil)
        }else{
            MBProgressHUD.hide()
            guard let url = URL(string: "mailto:") else {
                MBProgressHUD.showBottom(tr("尚未安装应用"), icon: nil, view: nil)
                CLLog("尚未安装应用")
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                CLLog("未配置邮箱，请配置后重试")
                MBProgressHUD.showBottom(tr("未配置邮箱，请配置后重试"), icon: nil, view: nil)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else {
                CLLog("没有安装邮件，跳转appstore")
                MBProgressHUD.showBottom(tr("尚未安装应用"), icon: nil, view: nil)
                UIApplication.shared.open(URL(string: "https://apps.apple.com/cn/app/id1108187098")!, options: [:]) { (install) in
                }
            }
          }
        }
      }
    }
    // 随机字符
    func randomStr(len : Int) -> String{
        var ranStr = ""
        let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let clearLogResult = ISLogFileManager.clearZip()
        CLLog("2.0邮件日志请理结果：\(clearLogResult)")
        dismiss(animated: true, completion: nil)
        switch result {
        case .cancelled:
         break
        case .saved:
            break
        case .sent:
            MBProgressHUD.showBottom(tr("已收到，感谢你的反馈"), icon: nil, view: view)
            CLLog("日志发送成功")
            navigationController?.popViewController(animated: true)
        case .failed:
            CLLog("日志发送失败")
            MBProgressHUD.showBottom(tr("日志发送失败"), icon: nil, view: view)
        default:
            break
        }
        
    }
    
    /// 获取距离当前日期，几年几月几日的日期
    ///
    /// - Parameters:
    ///   - year: 距离当前日期的前/后几年  如：去年:-1   明年:1  今年:0
    ///   - month:  距离当前日期的前/后几个月  如：上个月:-1   下个月:1  这个月:0
    ///   - day:  距离当前日期的前/后几天 如：昨天:-1   明天:1   今天:0
    /// - Returns: 返回所要的日期
    func currentDateToWantDate(year:Int,month:Int,day:Int)->String {
        let current = Date()
        let calendar = Calendar(identifier: .gregorian)
        var comps:DateComponents?
        
        comps = calendar.dateComponents([.year,.month,.day], from: current)
        comps?.year = year
        comps?.month = month
        comps?.day = day
        
        let date = calendar.date(byAdding: comps!, to: current) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        return dateStr
    }
}
 
//MARK: -  3.0通过接口上传数据
extension FeedBackCommitViewController {
    func commitLocalData(){
        DispatchQueue.global().async {
            //先把用户输入的写入本地，
            ISLogFileManager.writeToTXTFile(with: self.contentStr);
            //如果有图片或者日志，继续获取路径信息
            if self.selectedDates.count > 0   {
                self.getTSDKlogPath()
            }
            var datas = Data()
            //选中的日期
            var resultDateArray:[String] = []
            for item  in self.selectedDates {
                resultDateArray.append(item as? String ?? "")
            }

            if let data = ISLogFileManager.getISLog(withDateArray: resultDateArray, images: self.picDatasource, sdkLogPathArray: self.sdkLogPath){
                datas.append(data)
            }
            let dataMax = datas.count
            if dataMax > LOGSIZEMAX {//日志大小限制600M
                DispatchQueue.main.async {
                    CLLog("日志超过600M")
                    MBProgressHUD.hide()
                    MBProgressHUD.showBottom(tr("日志上传失败，大小超出600M的限制"), icon: nil, view: nil)
                }
              return
            }
            guard ISLogFileManager.getLogPathThreeVersion(withDateArray: resultDateArray, images: self.picDatasource, sdkLogPathArray: self.sdkLogPath) != nil else {
                CLLog("获取日志失败")
                DispatchQueue.main.async {
                    MBProgressHUD.hide()
                    MBProgressHUD.showBottom(tr("日志上传失败"), icon: nil, view: nil)
                }
               return
            }
            self.uploadSMC3FilePath = ISLogFileManager.getLogPathThreeVersion(withDateArray: resultDateArray, images: self.picDatasource, sdkLogPathArray: self.sdkLogPath)
            CLLog("全部路径: \(self.uploadSMC3FilePath)")
            DispatchQueue.main.async {
                MBProgressHUD.hide()
                self.showAlertType = .sureUploadLogAlert
                let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
                alertTitleVC.modalTransitionStyle = .crossDissolve
                alertTitleVC.modalPresentationStyle = .overFullScreen
                alertTitleVC.customDelegate = self
                self.present(alertTitleVC, animated: true, completion: nil)
            }
        }
    }
}
