//
//  SVCMeetingBackView.swift
//  PictureInPicture
//
//  Created by mac on 2020/5/23.
//  Copyright © 2020 coderybxu. All rights reserved.
//

import UIKit

typealias SmallVideoViewHideBlock = (Bool) -> (Void)

typealias ConfigSignalLabelBlock = (String) -> (Void)

class SVCMeetingBackView: UIView {

    // 快速创建
    static func svcMeetingBackView() -> SVCMeetingBackView {
        Bundle.main.loadNibNamed("SVCMeetingBackView", owner: nil, options: nil)?.first as! SVCMeetingBackView
    }
    
    // 界面UICollectionView
    @IBOutlet weak var collectionForPageView: UICollectionView!
    @IBOutlet weak var CollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionWidthConstraint: NSLayoutConstraint!
    
    var smallVideoViewHideBlock: SmallVideoViewHideBlock?
    var configSignalLabelBlock: ConfigSignalLabelBlock?
    
    // 页数控制
    var pageControl: UIPageControl?
    // 小画面
    var currentBackGroudStatus:Bool = false
    
    // SVCManager
    public var svcManager = SVCMeetingManager()
        
    // call manager
    private var callManager = CallMeetingManager()

    // 最新的与会者数组
    var newAttendeesPageArray:[[ConfAttendeeInConf]] = []
    // 保存返回与会者ID数组
    var newAttendeesIDPageArray:[[String]] = []
    // 滑动到的当前页
    var scrollCurrentPage: Int = 0
    // 开始拖拽时当前页
    var beginDragPage: Int = 0
    // 结束拖拽时当前页
    var endDragPage: Int = 0

    // 用户手动隐藏小画面
    var userChooseSmallViewIsHidden = false
    
    // 语音激励 画廊模式下再没人说话的情况下3秒后篮框消失
    var isHiddenBlueBox: Int = 0
    // 是否显示大画面占位图
    var isShowBigLoadingImage:Bool = false
    // 当前会议是否只有自己
    var isMeetingOnlyMyselfNeedRefresh:Bool = false
    // 是否滑动后刷新
    var isScrollReload:Bool = false

    //由于上面的meetingInfo 的id 变化  所以进行第一次保存  防止黑屏
    static var id: UInt32 = 0
  
    // 检测横竖屏变化,更新页面
    var sizeForChange : CGSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
    
    // 定时器
    fileprivate weak var timer: Timer?
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        CLLog("SVCMeetingBackView deinit")
    }
    
    //初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        // 加载通知
        loadPicVideoNotification()
        // 注册cell
        // 辅流画面
        collectionForPageView.register(UINib(nibName: SVCMeetBfcpEAGLViewCell.cellID, bundle: nil), forCellWithReuseIdentifier: SVCMeetBfcpEAGLViewCell.cellID)
        // 大画面
        collectionForPageView.register(UINib(nibName: SVCMeetOneEAGLViewCell.cellID, bundle: nil), forCellWithReuseIdentifier: SVCMeetOneEAGLViewCell.cellID)
        // 两个画面
        collectionForPageView.register(UINib(nibName: SVCMeetTwoEAGLViewCell.cellID, bundle: nil), forCellWithReuseIdentifier: SVCMeetTwoEAGLViewCell.cellID)
        // 三个画面
        collectionForPageView.register(UINib(nibName: SVCMeetThreeEAGLViewCell.cellID, bundle: nil), forCellWithReuseIdentifier: SVCMeetThreeEAGLViewCell.cellID)
        // 四个画面
        collectionForPageView.register(UINib(nibName: SVCMeetFourEAGLViewCell.cellID, bundle: nil), forCellWithReuseIdentifier: SVCMeetFourEAGLViewCell.cellID)

    }
    
    private func hideSmallVideoView() {
        self.smallVideoViewHideBlock?(true)
    }

    private func showSmallVideoView() {
        self.smallVideoViewHideBlock?(false)
    }

}

// MARK: 页面布局和屏幕旋转
extension SVCMeetingBackView {
    //布局
    override func layoutSubviews() {
        super.layoutSubviews()
        if size.width > size.height { // 横屏
            self.sizeForChange = CGSize(width: size.height*(16.0/9.0), height: size.height)
        }else{ // 竖屏
            self.sizeForChange = CGSize(width: size.width, height: size.width*(16.0/9.0))
        }
        self.collectionForPageView.bounds = CGRect(x: 0, y: 0, width: self.sizeForChange.width, height: self.sizeForChange.height)
        collectionForPageView.contentSize = CGSize(width: (CGFloat)(self.collectionPageAll())*sizeForChange.width, height: sizeForChange.height)
        let rect = CGRect(x: (CGFloat)(self.scrollCurrentPage) * sizeForChange.width, y: 0, width: sizeForChange.width, height: sizeForChange.height)
        collectionForPageView.scrollRectToVisible(rect, animated: false)
        CLLog("当前CollectionView的frame：\(self.collectionForPageView.frame)")
    }
}

// MARK: -UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SVCMeetingBackView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //SVC会议：没有辅流时计算页数（大画面+画廊页数），有辅流时计算页数（辅流页面+大画面+画廊页数）
        return self.collectionPageAll()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //第0个肯定是单页面(有辅流则第一页是辅流,没有辅流则第一页是大画面)
        if indexPath.row == 0 {
            if svcManager.isAuxiliary == true {
                //有辅流时第一页肯定是辅流
                CLLog("GLVIEW-REBIND-isAuxiliary-Cell-0-reload")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SVCMeetBfcpEAGLViewCell.cellID, for: indexPath) as! SVCMeetBfcpEAGLViewCell
                if cell.video == nil {
                    cell.setupVideo()
                }else if cell.video != nil, !cell.contentView.subviews.contains(cell.video!) {
                    cell.setupVideo()
                }
                if self.scrollCurrentPage == 0 {
                    self.hideSmallVideoView()
                }
                let result = callManager.callInfo()?.updateVideoWindow(withLocal:nil, andRemote: nil, andBFCP: cell.video, callId: SVCMeetingBackView.id)
                CLLog("stream loading - \(String(describing: result)) - \(SVCMeetingBackView.id) - \(self.scrollCurrentPage) - \(String(describing: cell.video))")
                return cell
            }
            // 没有辅流时第一页是单画面，SVC是大画面
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SVCMeetOneEAGLViewCell.cellID, for: indexPath) as! SVCMeetOneEAGLViewCell
            cell.videoTopImageView.image = isShowBigLoadingImage ? UIImage.init(named: "tup_call_loading_img.jpg") : UIImage.init()
            if cell.video == nil {
                cell.setupVideo()
            }else if cell.video != nil, !cell.backView.subviews.contains(cell.video!) {
                cell.setupVideo()
            }
            if self.scrollCurrentPage == 0 {
                // 获取当前Cell需要展示的数模
                let currentAttendeeArray:[ConfAttendeeInConf] = svcManager.attendeesPageArray[indexPath.row]
                CLLog("svc meeting CollectionView bigPicture - \(SVCMeetingBackView.id) - \(indexPath.row)")
                self.svcWatchBigPictureCell(bigAttendees: currentAttendeeArray, BigPictureCell: cell)
            }
            if svcManager.isMyShare {
                self.hideSmallVideoView()
            }
            return cell
        }else{  // 第二页以后全部是画廊模式
            var currentAttendeeArray:[ConfAttendeeInConf] = []
            if svcManager.isAuxiliary == true {
                currentAttendeeArray = svcManager.attendeesPageArray[indexPath.row-1]
            }else{
                currentAttendeeArray = svcManager.attendeesPageArray[indexPath.row]
            }
            if svcManager.isMyShare {
                self.hideSmallVideoView()
            }
            if currentAttendeeArray.count == 1 {    // 大画面
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SVCMeetOneEAGLViewCell.cellID, for: indexPath) as! SVCMeetOneEAGLViewCell
                if cell.video == nil {
                    cell.setupVideo()
                }else if cell.video != nil, !cell.backView.subviews.contains(cell.video!) {
                    cell.setupVideo()
                }
                cell.videoTopImageView.image = isShowBigLoadingImage ? UIImage.init(named: "tup_call_loading_img.jpg") : UIImage.init()
                if (self.scrollCurrentPage == 0 || self.scrollCurrentPage == 1){ // 需要刷新
                    CLLog("svc meeting CollectionView bigPicture stream  - \(SVCMeetingBackView.id) - \(indexPath.row)")
                    // 先要选看后才可以关联
                    self.svcWatchBigPictureCell(bigAttendees: currentAttendeeArray, BigPictureCell: cell)
                }
                return cell
            }else if currentAttendeeArray.count == 2 { // 两个的与会者画廊
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SVCMeetTwoEAGLViewCell.cellID, for: indexPath) as! SVCMeetTwoEAGLViewCell
                cell.clearLabelName()
                if self.scrollCurrentPage != indexPath.row {
                    cell.setBackViewImage()
                }
                if self.scrollCurrentPage == indexPath.row { // 需要刷新
                    CLLog("svc meeting CollectionView gallery local - \(SVCMeetingBackView.id) - \(indexPath.row)")
                    self.svcWatchGalleryTwoVideoCell(attendeeInConfs: currentAttendeeArray, twoVideopCell: cell)
                }
                return cell
            }else if currentAttendeeArray.count == 3 {  // 三个的与会者画廊
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SVCMeetThreeEAGLViewCell.cellID, for: indexPath) as! SVCMeetThreeEAGLViewCell
                cell.clearLabelName()
                if self.scrollCurrentPage != indexPath.row {
                    cell.setBackViewImage()
                }
                if self.scrollCurrentPage == indexPath.row {
                    CLLog("svc meeting CollectionView gallery local - \(SVCMeetingBackView.id) - \(indexPath.row)")
                    self.svcWatchGalleryThreeVideoCell(attendeeInConfs: currentAttendeeArray, threeVideoCell: cell)
                }
                return cell
            }else {                                     // 四个与会者
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SVCMeetFourEAGLViewCell.cellID, for: indexPath) as! SVCMeetFourEAGLViewCell
                cell.clearLabelName()
                if self.scrollCurrentPage != indexPath.row {
                    cell.setBackViewImage()
                }
                if self.scrollCurrentPage == indexPath.row {
                    CLLog("svc meeting CollectionView gallery local -  \(SVCMeetingBackView.id) - \(indexPath.row)")
                    self.svcWatchGalleryFourVideoCell(attendeeInConfs: currentAttendeeArray, fourVideoCell: cell)
                }
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sizeForChange.width, height: sizeForChange.height)
    }
}

// MARK: - 与会者label计算，与会者数组更新，辅流变更
extension SVCMeetingBackView {
    // 更新与会者数组
    public func updataByAttendeedChange() {
       
        // 自己没入会不执行后续操作
        if svcManager.mineConfInfo == nil {
            svcManager.attendeeArray.removeAll()
            return
        }
        newAttendeesPageArray.removeAll()
        newAttendeesIDPageArray.removeAll()
        // 最新的与会者
        let newAttendeesArray:[ConfAttendeeInConf] = svcManager.attendeeArray
        //  与会者数组为0则说明与会者只有自己，return不执行下面方法操作
        if newAttendeesArray.count == 0 {
            CLLog("- svc meeting the current participant is only himself -")
            // 只有自己则不显示小画面
            self.hideSmallVideoView()
            var bigConfInfoArr:[ConfAttendeeInConf] = [] // 只有自己则大画面展示自己
            let mineConfInfo:ConfAttendeeInConf = svcManager.mineConfInfo ?? ConfAttendeeInConf()
            bigConfInfoArr.append(mineConfInfo)
            newAttendeesPageArray.append(bigConfInfoArr)
            newAttendeesIDPageArray.append([mineConfInfo.number])
            svcManager.attendeesPageArray = newAttendeesPageArray
            svcManager.attendeesIDPageArray = newAttendeesIDPageArray
            self.pageControl?.numberOfPages = currentPageControlNumber()
            self.scrollCurrentPage = svcManager.isAuxiliary == true ? 1 : 0
            self.pageControl?.currentPage = self.scrollCurrentPage
            SessionManager.shared.currentShowVideoType = .showMainVideo
            if !isMeetingOnlyMyselfNeedRefresh {
                svcManager.currentShowAttendeeArray = bigConfInfoArr
                self.reloadDataWithRow(row: nil, isDeadline: 0.0)
                isMeetingOnlyMyselfNeedRefresh = true
                CLLog("svc meeting *******************  only Mine")
            }
            // 只有一个人的情况下隐藏分页显示小圆点
            (self.collectionPageAll() <= 1) ? (self.pageControl?.isHidden = true) : (self.pageControl?.isHidden = false)
            return;
        }
        isMeetingOnlyMyselfNeedRefresh = false // 大画面只有自己是否刷新
        
        // 是否隐藏小画面
        if !userChooseSmallViewIsHidden { // 用户在没有手动隐藏时处理该回调
            if svcManager.isAuxiliary == true { // 有辅流则第一页不隐藏，其他页面隐藏
                if self.scrollCurrentPage == 1 {
                    self.showSmallVideoView()
                }else{
                    self.hideSmallVideoView()
                }
            }else {                             // 没有辅流则第一页不隐藏，其他页隐藏
                if self.scrollCurrentPage == 0 {
                    self.showSmallVideoView()
                }else {
                    self.hideSmallVideoView()
                }
            }
        }
        
        // 与会者数组不为空则说明不是只有我
        var bigConfInfoArr:[ConfAttendeeInConf] = [] // 大画面与会者数组
        //一个与会者,先判断是否有广播 有广播则大画面是广播的与会者
        if svcManager.broadcastConfInfo != nil {
            let broadcastConfInfo:ConfAttendeeInConf = svcManager.broadcastConfInfo ?? ConfAttendeeInConf()
            bigConfInfoArr.append(broadcastConfInfo)
            CLLog("svc meeting *******************  broadcastConfInfo")
        }
        // 无广播则有没有选看与会者。有选看则大画面是选看的与会者
        if svcManager.broadcastConfInfo == nil,svcManager.watchConfInfo != nil {
            let watchConfInfo:ConfAttendeeInConf = svcManager.watchConfInfo ?? ConfAttendeeInConf()
            bigConfInfoArr.append(watchConfInfo)
            CLLog("svc meeting *******************  watchConfInfo")
        }
        // 无广播无选看大画面展示上个与会者是否离会，不离会则展示展示上一个与会者
        if svcManager.broadcastConfInfo == nil,svcManager.watchConfInfo == nil, svcManager.bigPictureConfInfo != nil {
            if svcManager.bigPictureConfInfo?.number != svcManager.mineConfInfo?.number {
                let bigConfInfo:ConfAttendeeInConf = svcManager.bigPictureConfInfo ?? ConfAttendeeInConf()
                bigConfInfoArr.append(bigConfInfo)
                CLLog("svc meeting *******************  bigPictureConfInfo")
            }else{
                svcManager.bigPictureConfInfo = nil
                CLLog("svc meeting *******************  bigPictureConfInfo = nil")
            }
        }
        // 无广播，无选看，无大画面，大画面与会者中第一个
        if svcManager.broadcastConfInfo == nil,svcManager.watchConfInfo == nil, svcManager.bigPictureConfInfo == nil {
            let bigConfInfo = svcManager.attendeeArray[0]
            svcManager.bigPictureConfInfo = bigConfInfo // 全局保存该与会者
            bigConfInfoArr.append(bigConfInfo)
            CLLog("svc meeting *******************  svcManager.attendeeArray")
        }
        newAttendeesPageArray.append(bigConfInfoArr)
        newAttendeesIDPageArray.append(svcManager.getCurrentAttendeesID(attendees: bigConfInfoArr)) // 与会者ID
                
        // 二维数组每一个3个分一个小数组
        let galleryCount:Int = (newAttendeesArray.count%3 == 0) ? newAttendeesArray.count/3 : (newAttendeesArray.count/3+1)
        for gallertIndex in 0..<galleryCount {
            var bigConfInfoArr:[ConfAttendeeInConf] = [] // 与会者
            var bigconfInfoIDArr:[String] = []
            if (gallertIndex+1)*3 > newAttendeesArray.count { // 最后一个
                for confIndex in 0..<(newAttendeesArray.count-gallertIndex*3) {
                    let currentConfModel = newAttendeesArray[confIndex+gallertIndex*3]
                    bigConfInfoArr.append(currentConfModel)
                    bigconfInfoIDArr.append(currentConfModel.number)
                }
            }else { // 不是最后一个
                for confIndex in 0..<3 {
                    let currentConfModel = newAttendeesArray[confIndex+gallertIndex*3]
                    bigConfInfoArr.append(currentConfModel)
                    bigconfInfoIDArr.append(currentConfModel.number)
                }
            }
            // 画廊模式下自己不需要label_id（加载的是本端视图）
            bigConfInfoArr.insert(svcManager.mineConfInfo ?? ConfAttendeeInConf(), at: 0)
            bigconfInfoIDArr.insert(svcManager.mineConfInfo?.number ?? "0", at: 0)
            newAttendeesPageArray.append(bigConfInfoArr)
            newAttendeesIDPageArray.append(bigconfInfoIDArr)
        }
                
        // 大会模式，不是主席，与会者二维数组最多为2个 ；（主席模式显示全部）
        if svcManager.isPolicy, svcManager.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN && newAttendeesPageArray.count >= 2 {
            CLLog("- 当前大会模式 自己非主席 中断 -")
        }
        
         // 首次入会，直接刷新页面
         if svcManager.attendeesPageArray.count == 1 || svcManager.attendeesPageArray.count == 0 {
             svcManager.attendeesPageArray = newAttendeesPageArray // 全局保存最新与会者数组
             svcManager.attendeesIDPageArray = newAttendeesIDPageArray
             svcManager.currentShowAttendeeArray = newAttendeesPageArray[(bigPageCurrentIndex())]
            self.reloadDataWithRow(row: nil, isDeadline: 0.0)
             CLLog("svc meet need refresh  ---------------------- 6")
         }else{ // 有保存的与会者ID数组
            var isNeedReloadData:Bool = false // 是否需要刷新
            var isReloadRow:Int? = nil // 刷新
            
            // 大会模式下非主席当前页非第一个画廊则滑动到第一个画廊
            if svcManager.isPolicy, svcManager.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN, self.scrollCurrentPage > (bigPageCurrentIndex())+1 {
                self.collectionForPageView.scrollToItem(at: IndexPath.init(row: (bigPageCurrentIndex())+1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                self.scrollCurrentPage = (bigPageCurrentIndex())+1
                self.setPageControlNumber(currentScroll: self.scrollCurrentPage)
                isNeedReloadData = true
                isReloadRow = self.scrollCurrentPage
            }
            
            // 当前大画面
            if self.scrollCurrentPage == bigPageCurrentIndex() {
                if svcManager.isCurrentAttendeesLeftTheMeeting(attendees: svcManager.currentShowAttendeeArray) {
                    CLLog("svc meet need refresh  ---------------------- 1")
                    isNeedReloadData = true
                    svcManager.currentShowAttendeeArray = newAttendeesPageArray[(bigPageCurrentIndex())]
                }
            }
            
            // 最后一页
            if self.scrollCurrentPage == endPageCurrentIndex(),svcManager.currentShowAttendeeArray.count > 1 {
                var needAttendeesArray: [ConfAttendeeInConf] = []
                if svcManager.attendeesPageArray.count >= newAttendeesArray.count { // 有与会者离会或未变化
                    needAttendeesArray = newAttendeesPageArray.last ?? []
                }else { // 与会者入会
                    let currentIndex:Int? = (newAttendeesPageArray.count <= currentAttendeesIndex() ?? 0) ? nil : currentAttendeesIndex()
                    needAttendeesArray = (currentIndex == nil) ? newAttendeesPageArray.last ?? [] : newAttendeesPageArray[currentAttendeesIndex() ?? 0]
                }
                if svcManager.currentShowAttendeeArray.count != 4 { // 最后一页非4个
                    if svcManager.currentShowAttendeeArray.count != needAttendeesArray.count { // 最后一页与会者个数不一样，直接刷新
                        isNeedReloadData = true
                        svcManager.currentShowAttendeeArray = needAttendeesArray
                        CLLog("svc meet need refresh  ---------------------- 2")
                    }else {
                        if svcManager.isCurrentAttendeesLeftTheMeeting(attendees: svcManager.currentShowAttendeeArray) { // 展示的当前页有人离会
                            isNeedReloadData = true
                            svcManager.currentShowAttendeeArray = newAttendeesPageArray.last ?? []
                            print("svc meet need refresh  ---------------------- 3")
                        }
                    }
                }else {
                    if svcManager.isCurrentAttendeesLeftTheMeeting(attendees: svcManager.currentShowAttendeeArray) { // 展示的当前页有人离会
                        isNeedReloadData = true
                        svcManager.currentShowAttendeeArray = newAttendeesPageArray.last ?? []
                        CLLog("svc meet need refresh  ---------------------- 4")
                    }else {
                        if svcManager.attendeesPageArray.count < newAttendeesPageArray.count { // 与会者数量增加
                            svcManager.attendeesPageArray.append(newAttendeesPageArray.last ?? [])
                            svcManager.attendeesIDPageArray.append(newAttendeesIDPageArray.last ?? [])
                            collectionForPageView.insertItems(at: [IndexPath.init(row: self.scrollCurrentPage+1, section: 0)])
                            UIView.performWithoutAnimation {
                                self.reloadDataWithRow(row: self.scrollCurrentPage+1, isDeadline: 0.0)
                                CLLog("svc meet need refresh  ---------------------- 7")
                            }
                        }
                    }
                }
            }
            
            // 中间页
            if self.scrollCurrentPage > bigPageCurrentIndex(), self.scrollCurrentPage < (endPageCurrentIndex() ?? 0) {
                if svcManager.isCurrentAttendeesLeftTheMeeting(attendees: svcManager.currentShowAttendeeArray) {
                    // 展示的当前页有人离会
                    isNeedReloadData = true
                    svcManager.currentShowAttendeeArray = newAttendeesPageArray.count <= (currentAttendeesIndex() ?? 0) ? (newAttendeesPageArray.last ?? []) : newAttendeesPageArray[currentAttendeesIndex() ?? 0]
                    CLLog("svc meet need refresh  ---------------------- 5")
                }
            }
            
            // 需要刷新则刷新
            if isNeedReloadData {
                svcManager.attendeesPageArray = newAttendeesPageArray
                svcManager.attendeesIDPageArray = newAttendeesIDPageArray
                self.scrollCurrentPage = (self.scrollCurrentPage > collectionPageAll()-1) ? collectionPageAll()-1 : self.scrollCurrentPage
                self.reloadDataWithRow(row: isReloadRow, isDeadline: 0.5)
            }
         }
        
         // pageControl设置
         svcManager.attendeesPageArray.count <= 1 ? (pageControl?.isHidden = true) : (pageControl?.isHidden = false)
         pageControl?.numberOfPages = currentPageControlNumber()
         pageControl?.currentPage = currentPageControlShowIndex(currentScrolPage: self.scrollCurrentPage)
         if self.scrollCurrentPage == 0 {
             SessionManager.shared.currentShowVideoType = svcManager.isAuxiliary ? .showBFCP : .showMainVideo
         }

        // 判断SVC当前展示的视频画面
        var currentPage:Int = self.scrollCurrentPage
        if svcManager.isAuxiliary, currentPage > 0 {
            currentPage -= 1
        }
        
        let count = (svcManager.attendeesPageArray.count <= (currentPage)) ? (svcManager.attendeesPageArray.last ?? [])?.count : svcManager.attendeesPageArray[currentPage].count
        if let showVideoType = MeetingVideoType.init(rawValue: count ?? 0) {
            SessionManager.shared.currentShowVideoType = showVideoType
        }
    }
    
    // 共享和停止共享
    public func updataByAuxiliaryChange() {
        self.scrollCurrentPage = 0
        self.pageControl?.numberOfPages = currentPageControlNumber()
        self.pageControl?.currentPage = currentPageControlShowIndex(currentScrolPage: self.scrollCurrentPage)
        SessionManager.shared.currentShowVideoType = svcManager.isAuxiliary ? .showBFCP : .showMainVideo
        if svcManager.isAuxiliary == false { // 停止辅流
            CLLog("svc meet need refresh  ---------------------- 9 \(Thread.current)")
            self.isShowBigLoadingImage = false
            self.collectionForPageView.deleteItems(at: [IndexPath.init(row: 0, section: 0)])
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.collectionForPageView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
                self.svcWatchBigPictureCell(bigAttendees: self.svcManager.attendeesPageArray.first ?? [ConfAttendeeInConf()], BigPictureCell: nil)
            }
        }else {  //开始共享
            CLLog("svc meet need refresh  ---------------------- 10 \(Thread.current)")
            self.isShowBigLoadingImage = false
            self.reloadDataWithRow(row: nil, isDeadline: 0.0)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.collectionForPageView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                self.hideSmallVideoView()
            }
        }
    }
}

//MARK: 处理画面刷新等问题
extension SVCMeetingBackView {
    // 小窗口放大到辅流页面操作
    public func smallWindowToBfcpStreamCell() {
        if collectionForPageView.visibleCells.count == 0 {
            return
        }
        if !(collectionForPageView.visibleCells[0] is SVCMeetBfcpEAGLViewCell) {
            self.reloadDataWithRow(row: nil, isDeadline: 0)
            return
        }
        let currentCell:SVCMeetBfcpEAGLViewCell = collectionForPageView.visibleCells.first as! SVCMeetBfcpEAGLViewCell
        if !currentCell.contentView.contains(currentCell.video!) {
            currentCell.setupVideo()
        }
    }
    // 小窗口放大到大画面操作
    public func smallWindowTobigPictureCell() {
        if collectionForPageView.visibleCells.count == 0 {
            return
        }
        if !(collectionForPageView.visibleCells[0] is SVCMeetOneEAGLViewCell) {
            self.reloadDataWithRow(row: nil, isDeadline: 0)
            return
        }
        let currentCell:SVCMeetOneEAGLViewCell = collectionForPageView.visibleCells.first as! SVCMeetOneEAGLViewCell
        if !currentCell.backView.contains(currentCell.video!) {
            currentCell.setupVideo()
        }
        currentCell.setName(string: svcManager.bigPictureConfInfo?.name ?? "")
    }
    // 大画面数据处理
    public func svcWatchBigPictureCell(bigAttendees:[ConfAttendeeInConf],BigPictureCell:SVCMeetOneEAGLViewCell?) {
        // 当前页面不是自己时刷新小画面
        if self.scrollCurrentPage == bigPageCurrentIndex(), self.svcManager.attendeeArray.count > 0, !self.userChooseSmallViewIsHidden {
            self.showSmallVideoView()
        }else{
            self.hideSmallVideoView()
        }
        // 获取当前cell
        var currentCell:SVCMeetOneEAGLViewCell?
        if BigPictureCell != nil {
            currentCell = BigPictureCell
        }else{
            if collectionForPageView.visibleCells.count == 0 {
                return
            }
            if !(collectionForPageView.visibleCells[0] is SVCMeetOneEAGLViewCell) {
                self.reloadDataWithRow(row: nil, isDeadline: 0)
               return
            }
            currentCell = collectionForPageView.visibleCells.first as? SVCMeetOneEAGLViewCell
        }
        svcManager.isReloadSmallWindow = false
        isShowBigLoadingImage = false
        // 先要选看后才可以关联
        svcManager.svcWatchAttendeesAndAddRemoveSvcVideoWindow(currentAttendeeArray: bigAttendees, Remotes: [currentCell?.video], callId: SVCMeetingBackView.id, isBigPicture: true, indexRow: bigPageCurrentIndex(), ssrcType: .ssrcFlashback) { (watchResult, attendess) in // 用户选看接口回调
            if watchResult, attendess == nil {
                currentCell?.clearBackViewImage()
            }
        } mcuWatchCompletion: { (mcuResult, attendees) in // mcu通知返回选看回调
            if mcuResult,attendees?.count != 0 {
                currentCell?.setName(string: attendees?[0].name ?? "")
            }
        } bindCompletion: { [weak self] (bindResult, attendees) in // 远端接口绑定回调
            guard let self = self else {return}
            if bindResult, self.scrollCurrentPage == self.bigPageCurrentIndex(), attendees?.count != 0 {
                currentCell?.clearBackViewImage()
                currentCell?.setName(string: attendees?[0].name ?? "")
                if attendees?.count == self.svcManager.currentShowAttendeeArray.count {
                    self.svcManager.currentShowAttendeeArray = attendees ?? bigAttendees
                    self.newAttendeesPageArray[0] = self.svcManager.currentShowAttendeeArray
                    self.newAttendeesIDPageArray[0] = self.svcManager.getCurrentAttendeesID(attendees: self.svcManager.currentShowAttendeeArray)
                    
                }
                self.svcManager.bigPictureConfInfo = self.svcManager.currentShowAttendeeArray.first
            }
            CLLog("CollectionView One end - \(String(bindResult)) - \(self.scrollCurrentPage)")
        }
    }
    
    // 画廊两个数据处理
    public func svcWatchGalleryTwoVideoCell(attendeeInConfs:[ConfAttendeeInConf],twoVideopCell:SVCMeetTwoEAGLViewCell?)  {
        // 获取当前cell
        var currentCell:SVCMeetTwoEAGLViewCell?
        if twoVideopCell != nil {
            currentCell = twoVideopCell
        }else{
            if collectionForPageView.visibleCells.count == 0 {
                return
            }
            if !(collectionForPageView.visibleCells[0] is SVCMeetOneEAGLViewCell) {
                self.reloadDataWithRow(row: nil, isDeadline: 0)
               return
            }
            currentCell = collectionForPageView.visibleCells.first as? SVCMeetTwoEAGLViewCell
        }
        // 设置cell一些数据
        currentCell?.setupVideo(indexRow: self.scrollCurrentPage, isAuxiliary: svcManager.isAuxiliary)
        currentCell?.svcDelegate = self
        currentCell?.setOneName(string: attendeeInConfs[0].name)
        self.hideSmallVideoView()
        callManager.updateVideoWindow(localView: currentCell?.oneVideo, callId: SVCMeetingBackView.id)
        svcManager.isNeedRefreshLoc = true
        currentCell?.oneBackView.image = UIImage.init()
        // 先要选看后才可以关联
        svcManager.svcWatchAttendeesAndAddRemoveSvcVideoWindow(currentAttendeeArray: [attendeeInConfs[1]], Remotes: [currentCell?.twoVideo], callId: SVCMeetingBackView.id, isBigPicture: false, indexRow: self.scrollCurrentPage, ssrcType: .ssrcFlashback) { (watchResult, attendess) in
            if watchResult, attendess == nil {
                currentCell?.clearBackViewImage()
            }
        } mcuWatchCompletion: { (mcuResult, attendees) in
            if mcuResult,attendees?.count != 0 {
                currentCell?.setTwoName(string: ((attendees?.count ?? 0) >= 2) ? (attendees?[1].name ?? "") : (currentCell?.twoName.text ?? attendeeInConfs[1].name))
            }
        } bindCompletion: { [weak self] (bindResult, attendees) in
            guard let self = self else {return}
            if bindResult,attendees?.count != 0 {
                currentCell?.clearBackViewImage()
                currentCell?.setTwoName(string: ((attendees?.count ?? 0) >= 2) ? (attendees?[1].name ?? "") : (currentCell?.twoName.text ?? attendeeInConfs[1].name))
                // 数据相等
                if attendees?.count == self.svcManager.currentShowAttendeeArray.count {
                    self.svcManager.currentShowAttendeeArray = attendees ?? attendeeInConfs
                    self.svcManager.attendeesPageArray[self.currentAttendeesIndex() ?? 0] = self.svcManager.currentShowAttendeeArray
                    self.svcManager.attendeesIDPageArray[self.currentAttendeesIndex() ?? 0] = self.svcManager.getCurrentAttendeesID(attendees: self.svcManager.currentShowAttendeeArray)
                }
            }
            CLLog("svc meeting CollectionView Two end - \(String(bindResult)) - \(self.scrollCurrentPage)")
        }
    }
    
    // 画廊三个数据处理
    public func svcWatchGalleryThreeVideoCell(attendeeInConfs:[ConfAttendeeInConf],threeVideoCell:SVCMeetThreeEAGLViewCell?)  {
        // 获取当前cell
        var currentCell:SVCMeetThreeEAGLViewCell?
        if threeVideoCell != nil {
            currentCell = threeVideoCell
        }else{
            if collectionForPageView.visibleCells.count == 0 {
                return
            }
            if !(collectionForPageView.visibleCells[0] is SVCMeetThreeEAGLViewCell) {
                self.reloadDataWithRow(row: nil, isDeadline: 0)
               return
            }
            currentCell = collectionForPageView.visibleCells.first as? SVCMeetThreeEAGLViewCell
        }
        // 设置cell一些数据
        self.hideSmallVideoView()
        currentCell?.setupVideo(indexRow: self.scrollCurrentPage, isAuxiliary: svcManager.isAuxiliary)
        currentCell?.svcDelegate = self
        currentCell?.setOneName(string: attendeeInConfs[0].name)
        callManager.updateVideoWindow(localView: currentCell?.oneVideo, callId: SVCMeetingBackView.id)
        svcManager.isNeedRefreshLoc = true
        currentCell?.oneBackView.image = UIImage.init()
        // 先要选看后才可以关联
        svcManager.svcWatchAttendeesAndAddRemoveSvcVideoWindow(currentAttendeeArray: [attendeeInConfs[1],attendeeInConfs[2]], Remotes: [currentCell?.twoVideo,currentCell?.threeVideo], callId: SVCMeetingBackView.id, isBigPicture: false, indexRow: self.scrollCurrentPage, ssrcType: .ssrcFlashback) { (watchResult, attendess) in
            if watchResult, attendess == nil {
                currentCell?.clearBackViewImage()
            }
        } mcuWatchCompletion: { (mcuResult, attendees) in
            if mcuResult,attendees?.count != 0 {
                currentCell?.setTwoName(string: ((attendees?.count ?? 0) >= 2) ? (attendees?[1].name ?? "") : (currentCell?.twoName.text ?? attendeeInConfs[1].name))
                currentCell?.setThreeName(string: ((attendees?.count ?? 0) >= 3) ? (attendees?[2].name ?? "") : (currentCell?.threeName.text ?? attendeeInConfs[2].name))
            }
        } bindCompletion: { [weak self] (bindResult, attendees) in
            guard let self = self else {return}
            if bindResult,attendees?.count != 0 {
                currentCell?.clearBackViewImage()
                currentCell?.setTwoName(string: ((attendees?.count ?? 0) >= 2) ? (attendees?[1].name ?? "") : (currentCell?.twoName.text ?? attendeeInConfs[1].name))
                currentCell?.setThreeName(string: ((attendees?.count ?? 0) >= 3) ? (attendees?[2].name ?? "") : (currentCell?.threeName.text ?? attendeeInConfs[2].name))
                // 数据相等
                if attendees?.count == self.svcManager.currentShowAttendeeArray.count {
                    self.svcManager.currentShowAttendeeArray = attendees ?? attendeeInConfs
                    self.svcManager.attendeesPageArray[self.currentAttendeesIndex() ?? 0] = self.svcManager.currentShowAttendeeArray
                    self.svcManager.attendeesIDPageArray[self.currentAttendeesIndex() ?? 0] = self.svcManager.getCurrentAttendeesID(attendees: self.svcManager.currentShowAttendeeArray)
                }
            }
            
            CLLog("svc meeting CollectionView Three end - \(String(bindResult)) - \(self.scrollCurrentPage)")
        }
    }
    
    // 画廊四个数据处理
    public func svcWatchGalleryFourVideoCell(attendeeInConfs:[ConfAttendeeInConf],fourVideoCell:SVCMeetFourEAGLViewCell?)  {
        // 获取当前cell
        var currentCell:SVCMeetFourEAGLViewCell?
        if fourVideoCell != nil {
            currentCell = fourVideoCell
        }else{
            if collectionForPageView.visibleCells.count == 0 {
                return
            }
            if !(collectionForPageView.visibleCells[0] is SVCMeetFourEAGLViewCell) {
                self.reloadDataWithRow(row: nil, isDeadline: 0)
               return
            }
            currentCell = collectionForPageView.visibleCells.first as? SVCMeetFourEAGLViewCell
        }
        // 设置cell一些数据
        self.hideSmallVideoView() // 隐藏小画面
        currentCell?.setupVideo(indexRow: self.scrollCurrentPage, isAuxiliary: svcManager.isAuxiliary)
        currentCell?.svcDelegate = self
        currentCell?.setOneName(string: attendeeInConfs[0].name)
        callManager.updateVideoWindow(localView: currentCell?.oneVideo, callId: SVCMeetingBackView.id)
        svcManager.isNeedRefreshLoc = true
        currentCell?.oneBackView.image = UIImage.init()
        // 先要选看后才可以关联
        svcManager.svcWatchAttendeesAndAddRemoveSvcVideoWindow(currentAttendeeArray: [attendeeInConfs[1],attendeeInConfs[2],attendeeInConfs[3]], Remotes: [currentCell?.twoVideo,currentCell?.threeVideo,currentCell?.fourVideo], callId: SVCMeetingBackView.id, isBigPicture: false, indexRow: self.scrollCurrentPage, ssrcType: .ssrcFlashback) { (watchResult, attendess) in
        } mcuWatchCompletion: { (mcuResult, attendees) in
            if mcuResult,attendees?.count != 0 {
                currentCell?.setTwoName(string: ((attendees?.count ?? 0) >= 2) ? (attendees?[1].name ?? "") : (currentCell?.twoName.text ?? attendeeInConfs[1].name))
                currentCell?.setThreeName(string: ((attendees?.count ?? 0) >= 3) ? (attendees?[2].name ?? "") : (currentCell?.threeName.text ?? attendeeInConfs[2].name))
                currentCell?.setFourName(string: ((attendees?.count ?? 0) >= 4) ? (attendees?[3].name ?? "") : (currentCell?.fourName.text ?? attendeeInConfs[3].name))
            }
        } bindCompletion: { [weak self] (bindResult, attendees) in
            guard let self = self else {return}
            if bindResult,attendees?.count != 0 {
                currentCell?.clearBackViewImage()
                currentCell?.setTwoName(string: ((attendees?.count ?? 0) >= 2) ? (attendees?[1].name ?? "") : (currentCell?.twoName.text ?? attendeeInConfs[1].name))
                currentCell?.setThreeName(string: ((attendees?.count ?? 0) >= 3) ? (attendees?[2].name ?? "") : (currentCell?.threeName.text ?? attendeeInConfs[2].name))
                currentCell?.setFourName(string: ((attendees?.count ?? 0) >= 4) ? (attendees?[3].name ?? "") : (currentCell?.fourName.text ?? attendeeInConfs[3].name))
                // 数据相等
                if attendees?.count == self.svcManager.currentShowAttendeeArray.count {
                    self.svcManager.currentShowAttendeeArray = attendees ?? attendeeInConfs
                    self.svcManager.attendeesPageArray[self.currentAttendeesIndex() ?? 0] = self.svcManager.currentShowAttendeeArray
                    self.svcManager.attendeesIDPageArray[self.currentAttendeesIndex() ?? 0] = self.svcManager.getCurrentAttendeesID(attendees: self.svcManager.currentShowAttendeeArray)
                }
            }
            CLLog("svc meeting CollectionView FourView end - \(String(bindResult)) - \(self.scrollCurrentPage)")
        }
    }
    
    // 刷新CollectionView,所有的刷新延迟0.5秒
    func reloadDataWithRow(row:Int?,isDeadline:Double) {
        DispatchQueue.main.asyncAfter(deadline: .now()+isDeadline) {
            if row == nil {
                self.collectionForPageView.reloadData()
            }else{
                self.collectionForPageView.reloadItems(at: [IndexPath.init(row: row ?? 0, section: 0)])
            }
        }
    }
}
// scrollView代理
extension SVCMeetingBackView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.svcManager.isPolicy,svcManager.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN {
            if scrollView.contentOffset.x > sizeForChange.width*CGFloat(bigPageCurrentIndex()+1) {
                collectionForPageView.scrollToItem(at: IndexPath.init(row: bigPageCurrentIndex()+1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            }
            return
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.svcManager.isPolicy, self.svcManager.mineConfInfo?.role != .CONF_ROLE_CHAIRMAN, scrollView.contentOffset.x >= sizeForChange.width*CGFloat(bigPageCurrentIndex()+1) {
            MBProgressHUD.showBottom(tr("进入大会模式，当前不支持自由选看"), icon: nil, view: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if !self.isScrollReload {
                self.scrollViewDidEndDecelerating(scrollView)
            }
        }
    }
    
    // 滑动页面结束
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrollReload = true
        var scrollPage = (Int)((self.collectionForPageView.contentOffset.x + sizeForChange.width / 2.0) / sizeForChange.width)
        if scrollPage == self.scrollCurrentPage {
            self.isScrollReload = false
            return
        }
        
        self.scrollCurrentPage = scrollPage
        svcManager.attendeesPageArray = newAttendeesPageArray // 全局保存
        svcManager.attendeesIDPageArray = newAttendeesIDPageArray // 全局保存
        
        if scrollCurrentPage > bigPageCurrentIndex() {
            svcManager.isReloadSmallWindow = true
        }
        
        if scrollPage > (endPageCurrentIndex() ?? 0) {
            self.collectionForPageView.scrollToItem(at: IndexPath.init(row: (endPageCurrentIndex() ?? 0)-1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            scrollPage = (endPageCurrentIndex() ?? 0)
            self.scrollCurrentPage = scrollPage
        }
        
        CLLog("svc meeting current page - \(self.scrollCurrentPage)")
        self.isShowBigLoadingImage = true // 设置大画面显示占位图
        // 设置pageControl为当前页
        self.pageControl?.currentPage = self.currentPageControlShowIndex(currentScrolPage: self.scrollCurrentPage)
        // 滑动结束先隐藏，是否显示后面判断
        if svcManager.isAuxiliary == true {
            if self.scrollCurrentPage != 1 {
                self.hideSmallVideoView()
            }else{
                self.showSmallVideoView()
            }
            SessionManager.shared.currentShowVideoType = self.pageControl?.currentPage == 0 ? .showBFCP : .showMainVideo
        }else{
            if self.scrollCurrentPage != 0 {
                self.hideSmallVideoView()
            }else{
                self.showSmallVideoView()
            }
        }
        // 滑动结束刷新页面
        if svcManager.isAuxiliary { // 有辅流
            if self.scrollCurrentPage == 0 { // 辅流页面
                SessionManager.shared.currentShowVideoType = .showBFCP
                self.isScrollReload = false
                return
            }
            if self.scrollCurrentPage == 1 { // 画中画页面
                self.svcWatchBigPictureCell(bigAttendees: svcManager.attendeesPageArray[currentAttendeesIndex() ?? 0], BigPictureCell: nil)
                self.isScrollReload = false
                return
            }
        }
        // 判断SVC当前展示的视频画面
        let count = svcManager.attendeesPageArray[svcManager.isAuxiliary ? self.scrollCurrentPage - 1 :
                                                self.scrollCurrentPage].count
        if let showVideoType = MeetingVideoType.init(rawValue: count) {
            SessionManager.shared.currentShowVideoType = showVideoType
        }
        // 有辅流滑动到第一页也不刷新
        CLLog("svc meet need refresh  ---------------------- 8")
        self.svcManager.currentShowAttendeeArray = svcManager.attendeesPageArray[currentAttendeesIndex() ?? 0]
        self.reloadDataWithRow(row: nil, isDeadline: 0.0)
        self.isScrollReload = false
    }
}

// 双击选看代理
extension SVCMeetingBackView : svcMeetTwoEAGLViewCellDelegate, svcMeetThreeEAGLViewCellDelegate, svcMeetFourEAGLViewCellDelegate {
    
    @objc func svcMeetTwoEAGLViewCellDoubleClick(index: Int) {
        if svcManager.isConNotDoubleClickToWatchInfo() { // 不能选看条件
            return
        }
        CLLog("svc meeting click two EAGLView Cell - \(index)")
        if svcManager.currentShowAttendeeArray.count - 1 < index {
            return
        }
        let confInfo:ConfAttendeeInConf = self.svcManager.currentShowAttendeeArray[index]
        NotificationCenter.default.post(name: NSNotification.Name.init(BeWatchSuccessAttendees), object: confInfo)
    }
    
    @objc func svcMeetThreeEAGLViewCellDoubleClick(index: Int) {
        if svcManager.isConNotDoubleClickToWatchInfo() {  // 不能选看条件
            return
        }
        CLLog("svc meeting click three EAGLView Cell - \(index)")
        if svcManager.currentShowAttendeeArray.count - 1 < index {
            return
        }
        let confInfo:ConfAttendeeInConf = self.svcManager.currentShowAttendeeArray[index]
        NotificationCenter.default.post(name: NSNotification.Name.init(BeWatchSuccessAttendees), object: confInfo)
    }
    
    @objc func svcMeetFourEAGLViewCellDoubleClick(index: Int) {
        if svcManager.isConNotDoubleClickToWatchInfo()  {  // 不能选看条件
            return
        }
        CLLog("svc meeting click four EAGLView Cell - \(index)")
        if svcManager.currentShowAttendeeArray.count - 1 < index {
            return
        }
        let confInfo:ConfAttendeeInConf = self.svcManager.currentShowAttendeeArray[index]
        NotificationCenter.default.post(name: NSNotification.Name.init(BeWatchSuccessAttendees), object: confInfo)
    }
}

//MARK: 一些处理 后续整理
extension SVCMeetingBackView {
    
    // 设置当前画廊下所有篮框为透明色
    func setCurrentCellVideoBackColor(hiddenTime:Int) {
        if isHiddenBlueBox >= hiddenTime { // 显示3秒时进入
            // 获取当前cell
            if collectionForPageView.visibleCells.count == 0 {
                return
            }
            // 当前展示的Cell
            let currentCell = collectionForPageView.visibleCells[0]
            // 当前页面设置为无颜色
            if currentCell is SVCMeetTwoEAGLViewCell {
                let twoVideoCell = currentCell as! SVCMeetTwoEAGLViewCell
                twoVideoCell.oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                twoVideoCell.twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                return
            }
            if currentCell is SVCMeetThreeEAGLViewCell {
                let ThreeVideoCell = currentCell as! SVCMeetThreeEAGLViewCell
                ThreeVideoCell.oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                ThreeVideoCell.twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                ThreeVideoCell.threeBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                return
            }
            if currentCell is SVCMeetFourEAGLViewCell {
                let fourVideoCell = currentCell as! SVCMeetFourEAGLViewCell
                fourVideoCell.oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                fourVideoCell.twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                fourVideoCell.threeBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
                fourVideoCell.fourBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor
            }
        }
    }
}


//MARK: -通知
extension SVCMeetingBackView {
    
    // 加载会议功能通知
    func loadPicVideoNotification() {
        // 当前与会者说话列表
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSpeakerList(notification:)), name: NSNotification.Name.init(rawValue: CALL_S_CONF_EVT_SPEAKER_IND), object: nil)
        // 选看的通知,从与会者页面回调通知
        NotificationCenter.default.addObserver(self, selector: #selector(beWatchRefresh(notification:)), name: NSNotification.Name(rawValue: BeWatchSuccessAttendees), object: nil)
    }
    
    // 选看和取消选看 (接口请求成功后的回调)
    @objc private func beWatchRefresh(notification:Notification) {
        // 二维数组中大画面数组
        svcManager.lastTimeSpeckConfInfo = nil
        self.isShowBigLoadingImage = false
        var bigAttendeesArr:[ConfAttendeeInConf] = []
        var bigAttendeesIDArr:[String] = []
        if notification.object != nil { // svc选看
            // 当前需要选看的与会者
            var watchAttendee:ConfAttendeeInConf = ConfAttendeeInConf.init()
            watchAttendee = notification.object as! ConfAttendeeInConf
            svcManager.watchConfInfo = watchAttendee // 当前记录的选看置为空
            bigAttendeesArr = [watchAttendee]
            bigAttendeesIDArr = [watchAttendee.number]
            CLLog("svc meeting WatchAttendee:ID - \(NSString.encryptNumber(with: watchAttendee.number) ?? "") WatchAttendee:name\(NSString.encryptNumber(with: watchAttendee.name) ?? "")")
            // 替换二维数组大画面数组
            newAttendeesPageArray[0] = bigAttendeesArr
            newAttendeesIDPageArray[0] = bigAttendeesIDArr
            svcManager.attendeesPageArray[0] = bigAttendeesArr
            svcManager.attendeesIDPageArray[0] = bigAttendeesIDArr
            // 不是大画面则滑动到大画面
            CLLog("svc meeting currentPage \(self.scrollCurrentPage), need Page\(bigPageCurrentIndex())")
            if self.scrollCurrentPage != bigPageCurrentIndex(), self.svcManager.watchConfInfo != nil {
                collectionForPageView.scrollToItem(at: IndexPath.init(row: bigPageCurrentIndex(), section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                // 设置pageControl
                self.scrollCurrentPage = bigPageCurrentIndex()
                self.pageControl?.currentPage = bigPageCurrentIndex()
            }
            CLLog("svc meet need refresh  ---------------------- 11")
            // 直接刷新页面
            newAttendeesPageArray[0] = bigAttendeesArr
            newAttendeesIDPageArray[0] = svcManager.getCurrentAttendeesID(attendees: bigAttendeesArr)
            svcManager.bigPictureConfInfo = bigAttendeesArr.first
            svcManager.currentShowAttendeeArray = bigAttendeesArr
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.svcWatchBigPictureCell(bigAttendees: bigAttendeesArr, BigPictureCell: nil)
            }
        }else{                          // svc取消选看
            self.svcManager.watchConfInfo = nil
        }
    }
    
    // 广播与会者和取消广播
    @objc func broadcoatAttendee(isBroadAtt:Bool) {
        svcManager.lastTimeSpeckConfInfo = nil
        self.isShowBigLoadingImage = false
        var bigAttendeesArr:[ConfAttendeeInConf] = []
        var bigAttendeesIDArr:[String] = []
        if isBroadAtt == true { // 广播与会者
            let confModel:ConfAttendeeInConf = svcManager.broadcastConfInfo ?? ConfAttendeeInConf()
            bigAttendeesArr = [confModel]
            bigAttendeesIDArr = [confModel.number]
            // 将广播对像的放到二维数组第一个
            newAttendeesPageArray[0] = bigAttendeesArr
            newAttendeesIDPageArray[0] = bigAttendeesIDArr
            svcManager.attendeesPageArray[0] = bigAttendeesArr
            svcManager.attendeesIDPageArray[0] = bigAttendeesIDArr
            CLLog("svc meeting broadcast Attendee ID:\(NSString.encryptNumber(with: bigAttendeesArr.first?.number) ?? "") name:\(NSString.encryptNumber(with: bigAttendeesArr.first?.name) ?? "")")
        }else {
            svcManager.broadcastConfInfo = nil
            if svcManager.watchConfInfo != nil { // 广播前有选看 大画面显示选看 没有则显示第一个人
                let confModel:ConfAttendeeInConf = svcManager.watchConfInfo ?? ConfAttendeeInConf()
                bigAttendeesArr = [confModel]
                bigAttendeesIDArr = [confModel.number]
                newAttendeesPageArray[0] = bigAttendeesArr
                newAttendeesIDPageArray[0] = bigAttendeesIDArr
                svcManager.attendeesPageArray[0] = bigAttendeesArr
                svcManager.attendeesIDPageArray[0] = bigAttendeesIDArr
                CLLog("svc meeting cancle broadcast watchAtt ID:\(NSString.encryptNumber(with: svcManager.watchConfInfo?.number) ?? "") name:\(NSString.encryptNumber(with: svcManager.watchConfInfo?.name) ?? "")")
            }
        }
        // 不是取消广播不是大画面则滑动到大画面
        CLLog("svc meeting currentPage \(self.scrollCurrentPage), need Page\(bigPageCurrentIndex())")
        if self.scrollCurrentPage != bigPageCurrentIndex(), self.svcManager.broadcastConfInfo != nil {
            collectionForPageView.scrollToItem(at: IndexPath.init(row: bigPageCurrentIndex(), section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            // 设置pageControl
            self.scrollCurrentPage = bigPageCurrentIndex()
            self.pageControl?.currentPage = bigPageCurrentIndex()
        }
        
        // 小窗口模式下不做处理
        if self.svcManager.isSmallWindow {
            CLLog("--- 小画面下不执行后续操作 ---")
            return
        }
        // 取消广播，无选看不执行后续操作
        if svcManager.broadcastConfInfo == nil, svcManager.watchConfInfo == nil {
            CLLog("--- 取消广播，无选看不执行后续操作 ---")
            return
        }
        
        // 直接刷新页面
        CLLog("svc meet need refresh  ---------------------- 12")
        newAttendeesPageArray[0] = bigAttendeesArr
        newAttendeesIDPageArray[0] = svcManager.getCurrentAttendeesID(attendees: bigAttendeesArr)
        svcManager.bigPictureConfInfo = bigAttendeesArr.first
        svcManager.currentShowAttendeeArray = bigAttendeesArr
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.svcWatchBigPictureCell(bigAttendees: bigAttendeesArr, BigPictureCell: nil)
        }
    }
    
    // 说话列表通知  (修改说话人的边框为蓝色)
    @objc func notificationSpeakerList(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: [ConfCtrlSpeaker]],let speaks = userInfo[CALL_S_CONF_EVT_SPEAKER_IND] else {
            CLLog("语音激励 --------   speaks  nil")
            return
        }
        // 获取当前cell
        if collectionForPageView.visibleCells.count == 0 {
            return
        }
        // 当前有辅流页面大画面前不执行一下操作
        if svcManager.isAuxiliary == true && self.scrollCurrentPage == 0 {
            return
        }
        // 每一次执为0
        isHiddenBlueBox = 0
        // 当前展示的Cell
        let currentCell = collectionForPageView.visibleCells[0]
        // 获取当前页面展示的与会者
        if svcManager.attendeesPageArray.count < (currentAttendeesIndex() ?? 0) + 1 {
            return
        }
        let currentAttends = svcManager.attendeesPageArray[currentAttendeesIndex() ?? 0]
        // 取出声音最大的与会者号码
        let sortArray = speaks.sorted(by: { $0.speaking_volume > $1.speaking_volume })
        let maxValue = sortArray.first?.number ?? "0"
        CLLog("语音激励 --------   speaks  max  \(maxValue)")
        // 当前页面有声音的出现篮框
        if currentCell is SVCMeetTwoEAGLViewCell {
            let twoVideoCell = currentCell as! SVCMeetTwoEAGLViewCell
            if currentAttends.count == 2 {
                currentAttends[0].number == maxValue ? (twoVideoCell.oneBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (twoVideoCell.oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
                currentAttends[1].number == maxValue ? (twoVideoCell.twoBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (twoVideoCell.twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
            }
        }else if currentCell is SVCMeetThreeEAGLViewCell {
            let ThreeVideoCell = currentCell as! SVCMeetThreeEAGLViewCell
            if currentAttends.count == 3 {
                currentAttends[0].number == maxValue ? (ThreeVideoCell.oneBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (ThreeVideoCell.oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
                currentAttends[1].number == maxValue ? (ThreeVideoCell.twoBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (ThreeVideoCell.twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
                currentAttends[2].number == maxValue ? (ThreeVideoCell.threeBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (ThreeVideoCell.threeBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
            }
        }else if currentCell is SVCMeetFourEAGLViewCell {
            let fourVideoCell = currentCell as! SVCMeetFourEAGLViewCell
            if currentAttends.count == 4 {
                currentAttends[0].number == maxValue ? (fourVideoCell.oneBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (fourVideoCell.oneBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
                currentAttends[1].number == maxValue ? (fourVideoCell.twoBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (fourVideoCell.twoBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
                currentAttends[2].number == maxValue ? (fourVideoCell.threeBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (fourVideoCell.threeBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
                currentAttends[3].number == maxValue ? (fourVideoCell.fourBackView.layer.borderColor = UIColorRGBA_Selft(r: 13, g: 148, b: 255, a: 1).cgColor) : (fourVideoCell.fourBackView.layer.borderColor = UIColor.black.withAlphaComponent(0.0).cgColor)
            }
        }

        // 语音激励。(当前在大画面情况下，没有广播和选看的情况下大画面显示声音最大的那个人的画面,在有辅流时)
        if self.scrollCurrentPage != bigPageCurrentIndex() || svcManager.broadcastConfInfo != nil || svcManager.watchConfInfo != nil {
            CLLog("- 不在大画面 有广播 有选看 不执行语音激励 -")
            CLLog("当前是否在大画面 - \(self.scrollCurrentPage == bigPageCurrentIndex())")
            CLLog("当前广播对象 - \((svcManager.broadcastConfInfo != nil ? svcManager.broadcastConfInfo?.name : "nil") ?? "")")
            CLLog("当前选看对象 - \((svcManager.watchConfInfo != nil ? svcManager.watchConfInfo?.name : "nil") ?? "")")
            return
        }
        // 声音最大的是自己则不改变大画面
        if svcManager.mineConfInfo?.number == maxValue {
            CLLog("- 当前语音激励最大声音是自己 不执行语音激励 -")
            return
        }
        // 上一次激励的与会者和这一次一样，也不执行以下操作
        if svcManager.lastTimeSpeckConfInfo != nil, svcManager.lastTimeSpeckConfInfo?.number == maxValue {
            CLLog("- 当前激励与会者为上次展示的与会者 -")
            return
        }
        // 改变大画面
        self.isShowBigLoadingImage = false
        // 找出声音对应的与会者
        let attendees:ConfAttendeeInConf = svcManager.allAttendeeDictionary[maxValue] ?? ConfAttendeeInConf()
        if attendees.number == nil || attendees.number == "" {
            return
        }
        svcManager.lastTimeSpeckConfInfo = attendees // 保存上一下语音激励的对象
        var bigAttends:[ConfAttendeeInConf] = []
        var bigAttendsID:[String] = []
        bigAttends.append(attendees)
        bigAttendsID = svcManager.getCurrentAttendeesID(attendees: bigAttends)
        
        svcManager.attendeesPageArray[0] = bigAttends
        svcManager.attendeesIDPageArray[0] = bigAttendsID
        CLLog("svc meeting Voice stimulation start - \(SVCMeetingBackView.id) - bigAttend:\(svcManager.getCurrentOnLinkAttendeesNameAndId(attendees: bigAttends)) - MaxAttendeesID:\(String(maxValue))")
        
        // 刷新页面
        CLLog("svc meet need refresh  ---------------------- 13")
        newAttendeesPageArray[0] = bigAttends
        newAttendeesIDPageArray[0] = svcManager.getCurrentAttendeesID(attendees: bigAttends)
        svcManager.bigPictureConfInfo = bigAttends.first
        svcManager.currentShowAttendeeArray = bigAttends
        self.svcWatchBigPictureCell(bigAttendees: bigAttends, BigPictureCell: nil)
    }

}
// 处理当前那一页
extension SVCMeetingBackView {
    // 大画面是第几页
    func bigPageCurrentIndex() -> Int {
        return svcManager.isAuxiliary == true ? 1 : 0
    }
    // 最后一页是第几页
    func endPageCurrentIndex() -> Int? {
        return svcManager.isAuxiliary == true ? svcManager.attendeesPageArray.count : svcManager.attendeesPageArray.count-1
    }
    // 当前画廊在二维数字中的位置
    func currentAttendeesIndex() -> Int? {
        return svcManager.isAuxiliary ? self.scrollCurrentPage-1 : self.scrollCurrentPage
    }
    // pageControl多少个点
    func currentPageControlNumber() -> Int {
        var allAttPage:Int = (svcManager.attendeeArray.count%3 == 0) ? svcManager.attendeeArray.count/3 : (svcManager.attendeeArray.count/3+1)
        allAttPage = svcManager.isAuxiliary ? allAttPage+2 : allAttPage+1
        allAttPage = allAttPage > 3 ? 3 : allAttPage
        return allAttPage
    }
    // pageControl显示那个点
    func currentPageControlShowIndex(currentScrolPage:Int) -> Int {
        var allAttPage:Int = (svcManager.attendeeArray.count%3 == 0) ? svcManager.attendeeArray.count/3 : (svcManager.attendeeArray.count/3+1)
        allAttPage = svcManager.isAuxiliary ? allAttPage+2 : allAttPage+1
        if currentScrolPage == 0 {
            return 0
        }
        if currentScrolPage >= allAttPage-1, currentScrolPage > 1 {
            return 2
        }
        return 1
    }
    // 一共多少页
    func collectionPageAll() -> Int {
        if svcManager.mineConfInfo == nil { // 自己为空返回0
            return 0
        }
        return svcManager.isAuxiliary == true ? svcManager.attendeesPageArray.count+1 : svcManager.attendeesPageArray.count
    }
    // 实际应该多少页
    func needCollectionPageAll() -> Int {
        var allAttPage:Int = (svcManager.attendeeArray.count%3 == 0) ? svcManager.attendeeArray.count/3 : (svcManager.attendeeArray.count/3+1)
        allAttPage = svcManager.isAuxiliary ? allAttPage+2 : allAttPage+1
        return allAttPage
    }
    // 设置当前PageControl是那一页
    func setPageControlNumber(currentScroll:Int) {
        if currentScroll == 0 {
            self.pageControl?.currentPage = 0
        }else if currentScroll == endPageCurrentIndex() {
            self.pageControl?.currentPage = 2
        }else {
            self.pageControl?.currentPage = 1
        }
    }
}

// 测试扩展
extension SVCMeetingBackView {

    // 视频质量帧率
    func loadStreamData() {
        guard let streamInfo = ManagerService.call()?.getStreamInfo(withCallId: svcManager.currentCallInfo?.stateInfo.callId ?? 0) else {
            CLLog("svc meeting streamInfo 为nil")
            return
        }
        // 过滤无用数据
        var dataSource : [VideoStream] = []
        dataSource.removeAll()
        for (_,stream) in streamInfo.svcArray.enumerated() {
            if stream.decoderSize != "" {
                dataSource.append(stream)
            }
        }
        // 获取当前视频信息对应远端视频名字
        var streamArr:[VideoStream] = []
        for (_,streamInfo) in dataSource.enumerated() {
            for (_,attConf) in self.svcManager.currentShowAttendeeArray.enumerated() {
                if attConf.lable_id == streamInfo.decodeSsrc {
                    streamInfo.decodeAttConfName = (attConf.name == "" || attConf.name == nil) ? "name" : attConf.name
                    streamArr.append(streamInfo)
                    break
                }
            }
        }
        // 拼接字符串
        var streamStr:String = "视频帧率为0"
        for (_,streamInfo) in streamArr.enumerated() {
            let attStr = "Name:" + streamInfo.decodeAttConfName + "  recvFrameRate:" + "\(streamInfo.recvFrameRate)" + "  decoderSize:" + "\(streamInfo.decoderSize)" + "  decodeSsrc:" + "\(streamInfo.decodeSsrc)"
            if streamStr == "视频帧率为0" {
                streamStr = attStr
            }else{
                streamStr = streamStr + "\n" + attStr
            }
        }
        CLLog("svc video streamInfo test - \(String(self.scrollCurrentPage)) \n\(streamStr)")
    }
}
