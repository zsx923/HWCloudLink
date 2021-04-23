//
//  PicInPicView.swift
//  PictureInPicture
//
//  Created by mac on 2020/5/23.
//  Copyright © 2020 coderybxu. All rights reserved.
//

import UIKit

private let picInPicCollectionCellForBFCPID = "PicInPicCollectionCellForBFCP"
private let picInPicCollectionCellID = "PicInPicCollectionCell"
let kScreenWidth  = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
class PicInPicView: UIView {
    var currentBackGroudStatus = false
    
    // 界面UICollectionView
    @IBOutlet weak var collectionForPageView: UICollectionView!
    // 父类VC
    var delegate: VideoMeetingDelegate?
    // 页数控制
    @IBOutlet weak var pageControl: UIPageControl!
    // 小画面
    var localVideoView: EAGLView?
    // 快速创建
    static func picInPicView() -> PicInPicView {
        Bundle.main.loadNibNamed("PicInPicView", owner: nil, options: nil)?.first as! PicInPicView
    }
    
    ///callInfo
    private var currentTupCallInfo : CallInfo?
    
    // 判断小换面是否是用户手动隐藏或者显示过
    var isUserControlForLocalVideoView = false
    // 用户手动隐藏小画面
    var userChooseSmallViewIsHidden = false
    // 是否是会议
    var isConf = true
    var isMyshare: Bool = false
    // 大小画面切换
    var isChangeSmallView = false
    var isUpdateWindowAvialiable = true
    // 是否共享辅流
    var isAuxiliary = false {
        didSet{
            caculatePageControlNumberPages()

            pageControl?.isHidden = !isAuxiliary
            collectionForPageView.reloadData()
            updateByAuxiliaryChange()
            self.isUpdateWindowAvialiable = true
        }
    }
    // 当前的CallID
    public var currentCallId: UInt32 = 0
    //由于上面的meetingInfo 的id 变化  所以进行第一次保存  防止黑屏
    static var id: UInt32 = 0
    // 当前页数
    var currentPage : Int = 0
    // 检测横竖屏变化
    var sizeForChange : CGSize = CGSize(width: kScreenHeight, height: kScreenWidth) {
        willSet {
            layoutForMyself(sizeForChange)
        }
    }
    
    //初始化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // page control
        self.pageControl.hidesForSinglePage = true
        self.pageControl.numberOfPages = 0
        self.bringSubviewToFront(self.pageControl)
        if (ManagerService.call()?.currentCallInfo) != nil {
            PicInPicView.id = ((ManagerService.call()?.currentCallInfo)?.stateInfo.callId ?? 0)
        }
        
        currentCallId = SessionManager.shared.currentCallId
        currentTupCallInfo = ManagerService.call()?.callInfoWithcallId(String(PicInPicView.id))
        
        // 注册cell
        collectionForPageView.register(UINib(nibName: picInPicCollectionCellID, bundle: nil), forCellWithReuseIdentifier: picInPicCollectionCellID)// 大画面
        collectionForPageView.register(UINib(nibName: picInPicCollectionCellID, bundle: nil), forCellWithReuseIdentifier: picInPicCollectionCellForBFCPID) // 辅流画面
    }
    
    
    deinit {
        CLLog("PicInPicView - deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshPageControl() {
        
        self.pageControl.isHidden = !isAuxiliary
    }
    
    // 设置当前CallID并刷新页面
    func setCurrentCallIdReflesh(currentCallId: UInt32) {
        if !isConf {
            PicInPicView.id = currentCallId
            self.collectionForPageView.reloadData()
        }
    }
}

// MARK: 页面布局和屏幕旋转
extension PicInPicView {
    //布局
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layoutForMyself(sizeForChange)
//    }
    //布局
    private func layoutForMyself(_ size : CGSize) {
        collectionForPageView.size = size
        self.collectionForPageView.reloadData()
        //TODO:加了刷新窗口限制条件后出现黑屏问题，暂时屏蔽
//        self.isUpdateWindowAvialiable = false
        
    }
}

// MARK: -UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension PicInPicView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // AVC会议：当有辅流时共两页，一页辅流，一页视频画面
        return isAuxiliary ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        PicInPicView.id = ((ManagerService.call()?.currentCallInfo)?.stateInfo.callId ?? 0)
        
        if indexPath.item == 0, self.isAuxiliary {
            //有辅流时第一页肯定是辅流
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: picInPicCollectionCellForBFCPID, for: indexPath) as? PicInPicCollectionCell
            cell?.setupVideo(isAux: true)
            ManagerService.call()?.updateVideoWindow(withLocal:localVideoView, andRemote: nil, andBFCP: cell?.video, callId: PicInPicView.id)
            CLLog("辅流刷新 PicInPicViewID = \(PicInPicView.id)")
            return cell!
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: picInPicCollectionCellID, for: indexPath) as! PicInPicCollectionCell
        cell.setupVideo()
        if isChangeSmallView {
            ManagerService.call()?.updateVideoWindow(withLocal:cell.video, andRemote: self.delegate?.getLocalVideoView(), andBFCP:nil, callId: PicInPicView.id)
            CLLog("主画面刷新 PicInPicViewID = \(PicInPicView.id)")
        }else {
            if isUpdateWindowAvialiable {
               let isSucsess = ManagerService.call()?.updateVideoWindow(withLocal:self.delegate?.getLocalVideoView(), andRemote: cell.video, andBFCP:nil, callId: PicInPicView.id)
                CLLog("主画面刷新    ----   \(self.delegate?.getLocalVideoView() )  ------    \(PicInPicView.id) ----- 是否黑屏？ \(isSucsess)")
            }
        }
        // 发起通知告诉小窗口重新刷新
        NotificationCenter.default.post(name: NSNotification.Name("SUSPEN_ECCONF_ATTENDEE_UPDATE_KEY"), object: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sizeForChange.width, height: sizeForChange.height)
    }
    
    // 滑动页面结束
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if currentTupCallInfo == nil {
            return
        }
        self.currentPage = (Int)((self.collectionForPageView.contentOffset.x + sizeForChange.width / 2) / sizeForChange.width)
        
        pageControl?.currentPage = currentPage
        caculateSmallViewIsHidden()
    }
}

// MARK: - 与会者label计算，与会者数组更新，辅流变更
extension PicInPicView {
    
    // 共享和停止共享
    fileprivate func updateByAuxiliaryChange() {
        //共享结束
        if isAuxiliary == false {
            collectionForPageView.deleteItems(at: [IndexPath(item: 0, section: 0)])
            collectionForPageView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.caculatePageControlNumberPages()
                self.collectionForPageView.reloadData()
            }
        }else {  //开始共享
            caculatePageControlNumberPages()
            self.collectionForPageView.reloadData()
            self.collectionForPageView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.collectionForPageView.reloadData()
            }
        }
        pageControl?.currentPage = 0
        currentPage = 0
        caculateSmallViewIsHidden()
    }

}

//MARK: - 计算小画面是否隐藏，页数计算
extension PicInPicView {
    //计算小画面是否隐藏
    private func caculateSmallViewIsHidden() {
        if isMyshare {
            print("小画面状态：HIDEN:%d",isMyshare)
            self.localVideoView?.superview?.isHidden = true
            return
        }
        CLLog("小画面状态0：isMyshare:\(isMyshare),AUXR:\(isAuxiliary),CurrPage:\(currentPage)")
        //用户选择过
        if isUserControlForLocalVideoView {
            if userChooseSmallViewIsHidden {
                self.localVideoView?.superview?.isHidden = true
                CLLog("小画面状态1：isMyshare:\(isMyshare),AUXR:\(isAuxiliary),CurrPage:\(currentPage)")
            } else {
                self.localVideoView?.superview?.isHidden = isAuxiliary && (currentPage == 0)
                CLLog("小画面状态2：isMyshare:\(isMyshare),AUXR:\(isAuxiliary),CurrPage:\(currentPage)")
            }
        } else {
            if userChooseSmallViewIsHidden  {
                CLLog("小画面状态3：isMyshare:\(isMyshare),AUXR:\(isAuxiliary),CurrPage:\(currentPage)")
                self.localVideoView?.superview?.isHidden = true
            }else {
                self.localVideoView?.superview?.isHidden = isAuxiliary && (currentPage == 0)
                CLLog("小画面状态4：isMyshare:\(isMyshare),AUXR:\(isAuxiliary),CurrPage:\(currentPage)")
            }
        }
        if !(self.delegate?.isHiddenSmallVideoView() ?? true) {
            ManagerService.call()?.updateVideoWindow(withLocal:self.delegate?.getLocalVideoView(), andRemote: nil, andBFCP:nil, callId: PicInPicView.id)
        }
        
        SessionManager.shared.currentShowVideoType = (!pageControl.isHidden && pageControl.currentPage == 0 && self.isAuxiliary) ? .showBFCP : .showMainVideo
    }
    
    //计算总页数
    private func caculatePageControlNumberPages() {
        if isAuxiliary  {
            pageControl.numberOfPages = 2
            pageControl.isHidden = false
        }else{
            pageControl.numberOfPages = 1
            pageControl.isHidden = true
        }
        caculateSmallViewIsHidden()
    }
}
