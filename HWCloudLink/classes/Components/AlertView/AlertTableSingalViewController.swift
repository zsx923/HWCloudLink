//
// AlertTableSingalViewController.swift
// HWCloudLink
// Notes：
//
// Created by 陈帆 on 2020/4/17.
// Copyright © 2020 陈帆. All rights reserved.
//

import UIKit

class AlertTableSingalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    static let vcID = "AlertTableSingalViewController"
    static let ROW_COUNT = 1    // row count
    
    var callId: UInt32 = 0
    
    var isSvc: Bool = false
    var isAvc: Bool = false
        
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var leftContent: NSLayoutConstraint!
    @IBOutlet weak var rightContent: NSLayoutConstraint!
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var timer: Timer?
    
    var isHaveAuxiliaryData = false // 是否有辅流
    
    fileprivate var dataArray:[[Any]] = []
    
    var isVideoNetCheck: Bool = true
    
    var svcManager = SVCMeetingManager()
    
    //检测横竖屏
    var interfaceOrientationChange: UIInterfaceOrientation = .portrait
    {
        didSet{
            if tableView != nil {
                tableView.reloadData()
                self.setContentViewHeight()
            }
        }
    }
    
    private let contentViewTopSize = 40
    private var maxContentViewHeight: CGFloat = SCREEN_WIDTH - 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationShareData(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_DECODE_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationStopShareData(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_AUX_DATA_STOPPED), object: nil)

        // Do any additional setup after loading the view.
        setViewUI()
        
        setInitData()
        
        // 设置定时器
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] (timer) in
            guard let self = self else { return }
            self.setInitData()
        })
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    // set view height
    func setContentViewHeight() {
        self.leftContent.constant = 20
        self.rightContent.constant = 20
        
        var viewHeightTemp = viewHeight.constant
        
        maxContentViewHeight =  interfaceOrientationChange == .portrait ? SCREEN_HEIGHT - 60 : SCREEN_WIDTH - 60
        if isVideoNetCheck { // 视频会议
            switch SessionManager.shared.currentShowVideoType {
            case .showBFCP:
                viewHeightTemp = SingalSevenHeaderFooterView.CELL_HEIGHT * 3 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_TWO_ROW) * TableSingalViewCell.CELL_HEIGHT +      // section2
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section3
            case .showMainVideo:
                viewHeightTemp = SessionManager.shared.bfcpStatus == .noBFCP ?
                    SingalSevenHeaderFooterView.CELL_HEIGHT * 2 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section2
                    : SingalSevenHeaderFooterView.CELL_HEIGHT * 3 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section2
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section3
            case .showFourVideo:
                viewHeightTemp = SessionManager.shared.bfcpStatus == .noBFCP ?
                    SingalSevenHeaderFooterView.CELL_HEIGHT * 2 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_FIVE_ROW) * TableSingalViewCell.CELL_HEIGHT       // section2
                    : SingalSevenHeaderFooterView.CELL_HEIGHT * 3 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_FIVE_ROW) * TableSingalViewCell.CELL_HEIGHT +     // section2
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section3
            case .showThreeVideo:
                viewHeightTemp = SessionManager.shared.bfcpStatus == .noBFCP ?
                    SingalSevenHeaderFooterView.CELL_HEIGHT * 2 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_FOUR_ROW) * TableSingalViewCell.CELL_HEIGHT       // section2
                    : SingalSevenHeaderFooterView.CELL_HEIGHT * 3 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_FOUR_ROW) * TableSingalViewCell.CELL_HEIGHT +     // section2
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section3
            case .showTwoVideo:
                viewHeightTemp = SessionManager.shared.bfcpStatus == .noBFCP ?
                    SingalSevenHeaderFooterView.CELL_HEIGHT * 2 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section2
                    : SingalSevenHeaderFooterView.CELL_HEIGHT * 3 +  // header title height
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section1
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT +    // section2
                    CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT      // section3
            }
        } else {  // 语音会议
            viewHeightTemp = SingalSevenHeaderFooterView.CELL_HEIGHT +
                CGFloat(TableSingalViewCell.LABEL_THREE_ROW) * TableSingalViewCell.CELL_HEIGHT
        }
        // 防止高度超过最大值
        viewHeightTemp = viewHeightTemp > maxContentViewHeight ? maxContentViewHeight : viewHeightTemp
        
        // 设置动画
        if viewHeightTemp != viewHeight.constant {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }
                self.viewHeight.constant = CGFloat(self.contentViewTopSize) + viewHeightTemp
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: 加入共享辅流回调通知
    @objc func notificationShareData(notification: Notification) {
       isHaveAuxiliaryData = true
    }
    
    // MARK: 停止共享辅流回调通知
    @objc func notificationStopShareData(notification: Notification) {
        isHaveAuxiliaryData = false
    }
    
    deinit {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        NotificationCenter.default.removeObserver(self)
        CLLog("AlertTableSingalViewController deinit")
    }
    
    func setViewUI() {
        self.closeBtn.tintColor = UIColor.white
        self.closeBtn.setImage(UIImage.init(named: "session_singal_close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        
        // 背景点击
        let backBtn = UIButton.init(frame: self.view.bounds)
        backBtn.addTarget(self, action: #selector(closeBtnClick(_:)), for: UIControl.Event.touchUpInside)
        self.view.insertSubview(backBtn, at: 0)
       
        self.tableView.allowsSelection = false
        self.tableView.register(TableSingalViewCell.classForCoder(),
                                forCellReuseIdentifier: TableSingalViewCell.CELL_TWO_LABEL_ROW_ID)
        self.tableView.register(TableSingalViewCell.classForCoder(),
                                forCellReuseIdentifier: TableSingalViewCell.CELL_THREE_LABEL_ROW_ID)
        self.tableView.register(TableSingalViewCell.classForCoder(),
                                forCellReuseIdentifier: TableSingalViewCell.CELL_FOUR_LABEL_ROW_ID)
        self.tableView.register(TableSingalViewCell.classForCoder(),
                                forCellReuseIdentifier: TableSingalViewCell.CELL_FIVE_LABEL_ROW_ID)
        
        self.tableView.register(SingalHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: SingalHeaderFooterView.CELL_ID)
        self.tableView.register(SingalSevenHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: SingalSevenHeaderFooterView.CELL_ID)
        self.tableView.bounces = false
    }
    
    func setInitData() {
        // 获取信息
        guard let streamInfo = ManagerService.call()?.getStreamInfo(withCallId: callId) else {return}
        
        self.dataArray.removeAll()
        self.dataArray.append([streamInfo.voiceStream]) // 语音
        if isSvc {
            var svcStreamArr:[VideoStream] = []
            let videoInfo = VideoStream.init()
            // 本地发送
            for (_,videoData) in streamInfo.svcArray.enumerated() {
                if videoData.encoderSize.count != 0 {
                    videoInfo.encodeName = videoData.encodeName
                    videoInfo.sendBitRate = videoData.sendBitRate
                    videoInfo.encoderSize = videoData.encoderSize
                    videoInfo.sendFrameRate = videoData.sendFrameRate
                    videoInfo.sendLossFraction = videoData.sendLossFraction
                    videoInfo.sendDelay = videoData.sendDelay
                    videoInfo.sendJitter = videoData.sendJitter
                    break
                }
            }
                        
            //  远端所有视频信息
            for (_,videoData) in streamInfo.svcArray.enumerated() {
                if videoData.decoderSize.count != 0 {
                    videoData.encodeName = videoInfo.encodeName
                    videoData.sendBitRate = videoInfo.sendBitRate
                    videoData.encoderSize = videoInfo.encoderSize
                    videoData.sendFrameRate = videoInfo.sendFrameRate
                    videoData.sendLossFraction = videoInfo.sendLossFraction
                    videoData.sendDelay = videoInfo.sendDelay
                    videoData.sendJitter = videoInfo.sendJitter
                    svcStreamArr.append(videoData)
                }
            }
            
            // svc找出远端对应的与会者名字
            var streamArr:[VideoStream] = []
            for (_,stream) in svcStreamArr.enumerated() {
                for (_,confInfo) in svcManager.currentShowAttendeeArray.enumerated() {
                    if confInfo.lable_id == stream.decodeSsrc {
                        stream.decodeAttConfName = confInfo.name
                        break
                    }
                }
                streamArr.append(stream)
            }
            self.dataArray.append(streamArr)
        } else {
            self.dataArray.append([streamInfo.videoStream]) // 视频
        }
        if isHaveAuxiliaryData {
            self.dataArray.append([streamInfo.bfcpVideoStream]) // 辅流
        }
        
        self.tableView.reloadData()
        self.setContentViewHeight()
    }
    
    @IBAction func closeBtnClick(_ sender: Any) {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func destroyVC() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.dismiss(animated: false, completion: nil)
    }
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isVideoNetCheck {
            return 1
        }
        return SessionManager.shared.bfcpStatus != .noBFCP ? 3:2
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlertTableSingalViewController.ROW_COUNT
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = TableSingalViewCell.CELL_THREE_LABEL_ROW_ID
        switch SessionManager.shared.currentShowVideoType {
        case .showBFCP:
            cellIdentifier = TableSingalViewCell.CELL_THREE_LABEL_ROW_ID
        case .showMainVideo:
            cellIdentifier = TableSingalViewCell.CELL_THREE_LABEL_ROW_ID
        case .showFourVideo:
            cellIdentifier = TableSingalViewCell.CELL_FIVE_LABEL_ROW_ID
        case .showThreeVideo:
            cellIdentifier =  TableSingalViewCell.CELL_FOUR_LABEL_ROW_ID
        case .showTwoVideo:
            cellIdentifier = TableSingalViewCell.CELL_THREE_LABEL_ROW_ID
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.section == 1 ? cellIdentifier : TableSingalViewCell.CELL_THREE_LABEL_ROW_ID) as! TableSingalViewCell
        cell.setCellData(indexPath: indexPath, dataSource: self.dataArray)
        return cell
        
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowCount = TableSingalViewCell.LABEL_THREE_ROW  // 显示行数
        if indexPath.section != 1 {
            return CGFloat(rowCount) * TableSingalViewCell.CELL_HEIGHT
        }
        
        switch SessionManager.shared.currentShowVideoType {
        case .showBFCP:
            rowCount = TableSingalViewCell.LABEL_THREE_ROW
        case .showMainVideo:
            rowCount = TableSingalViewCell.LABEL_THREE_ROW
        case .showFourVideo:
            rowCount = TableSingalViewCell.LABEL_FIVE_ROW
        case .showThreeVideo:
            rowCount = TableSingalViewCell.LABEL_FOUR_ROW
        case .showTwoVideo:
            rowCount = TableSingalViewCell.LABEL_THREE_ROW
        }
        
        return CGFloat(rowCount) * TableSingalViewCell.CELL_HEIGHT
    }
    
    // MARK: header Title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < self.dataArray.count else {
            CLLog("dataArray data error.")
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SingalSevenHeaderFooterView.CELL_ID) as! SingalSevenHeaderFooterView
        if section == 0 { // 音频
            headerView.label.text = tr("音频质量")
        }
        if section == 1 { // 视频
            headerView.label.text = tr("视频质量")
        }
        if section == 2  { // 辅流
            headerView.label.text = tr("演示质量")
        }
        return headerView
        
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SingalSevenHeaderFooterView.CELL_HEIGHT
    }
    
    // MARK: footer Title
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    // MARK: footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
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
