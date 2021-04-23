//
//  MeetingContainerViewController.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2021/2/2.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class MeetingContainerViewController: UIViewController {

    // 接收方信息
    var meetInfo: ConfBaseInfo?
    
    // 是否从小窗口恢复
    var isResumeFromSuspend = false
    
    // 会议类型
    var sessionType: SessionType = .p2pVoice
    
    var currentVC: MeetingViewController?
    
    // 是否展示在界面上
    var isShowInWindow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CLLog("viewDidLoad")
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .all
        isShowInWindow = true
        setupChildViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CLLog("viewWillAppear")
        resetRotateDirection()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CLLog("viewWillDisappear")
        APP_DELEGATE.rotateDirection = .portrait
        UIDevice.switchNewOrientation(.portrait)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CLLog("viewDidDisappear")
    }
    
    // 设置旋转方向
    fileprivate func resetRotateDirection() {
        var orientation: UIInterfaceOrientationMask = .portrait
        var preferredOrientation: UIInterfaceOrientation = .portrait
        if sessionType == .avcMeeting {
            orientation = .landscape
            preferredOrientation = .landscapeRight
        } else if sessionType == .p2pVideo || sessionType == .svcMeeting {
            orientation = .all
        }
        
        APP_DELEGATE.rotateDirection = orientation
        UIDevice.switchNewOrientation(preferredOrientation)
    }
    
    private func setupChildViewController() {
        
        // 不是从小窗口恢复, 需要初始化
        if isResumeFromSuspend {
            CLLog("会议容器 - 从小窗口恢复")
        } else {
            currentVC = getMeetingVC()
            currentVC?.meetInfo = meetInfo
        }
        
        currentVC?.view.frame = self.view.bounds
        if let vc = currentVC {
            self.view.addSubview(vc.view)
            vc.beginAppearanceTransition(true, animated: true)
            self.addChild(vc)
        }
    }
    
    private func getMeetingVC() -> MeetingViewController {
        CLLog("会议容器 - 新建 - \(meetingDesc(type: sessionType))")
        switch sessionType {
        case .p2pVoice:
            return VoiceViewController()
        case .p2pVideo:
            return VideoViewController()
        case .avcMeeting:
            return AVCMeetingViewController()
        case .svcMeeting:
            return SVCMeetingViewController()
        case .voiceMeeting:
            return VoiceMeetingViewController()
        }
    }
    
    private func getVoiceVC(fromModel: P2PConvertModel) -> VoiceViewController {
        let vc = VoiceViewController()
        vc.meetInfo = fromModel.meetInfo
        vc.callInfo = fromModel.callInfo
        vc.isTransfer = true
        vc.silenceType = fromModel.silenceType
        vc.soundType = fromModel.soundType
        vc.isListenBtnType = fromModel.isListenBtnClick
        vc.currentCalledSeconds = fromModel.currentCalledSeconds
        return vc
    }
    
    private func getVideoVC(fromModel: P2PConvertModel) -> VideoViewController {
        let vc = VideoViewController()
        vc.meetInfo = fromModel.meetInfo
        vc.callInfo = fromModel.callInfo
        vc.isTransfer = true
        vc.soundType = fromModel.soundType
        vc.silenceType = fromModel.silenceType
        vc.isListenBtnType = fromModel.isListenBtnClick
        vc.currentCalledSeconds = fromModel.currentCalledSeconds
        return vc
    }
    
    func convertTo(type: SessionType, convertModel: P2PConvertModel? = nil) {
        
        let oldSessionType = self.sessionType
        self.sessionType = type
        CLLog("会议容器 - \(meetingDesc(type: oldSessionType)) - 转 - \(meetingDesc(type: self.sessionType))")
//        if oldSessionType == self.sessionType {
//            return
//        }
        var tempVC: MeetingViewController?
        if let model = convertModel {
            
            switch self.sessionType {
            case .p2pVoice:
                tempVC = getVoiceVC(fromModel: model)
            case .p2pVideo:
                tempVC = getVideoVC(fromModel: model)
            case .voiceMeeting:
                tempVC = getMeetingVC()
                tempVC?.meetInfo = model.meetInfo
                tempVC?.callInfo = model.callInfo
            default:
                CLLog("无定义")
            }
        } else {
            tempVC = getMeetingVC()
            tempVC?.meetInfo = meetInfo
        }
        resetRotateDirection()
        guard let newVC = tempVC else { return }
        newVC.beginAppearanceTransition(true, animated: true)
        self.addChild(newVC)
        newVC.didMove(toParent: self)
        newVC.view.frame = self.view.bounds
        self.view.addSubview(newVC.view)
        
        if (self.currentVC != nil) {
            var oldVC = self.currentVC
            if oldVC is AVCMeetingViewController {
                let curVC:AVCMeetingViewController = oldVC! as! AVCMeetingViewController
                curVC.removeAll()
            }
            if oldVC is SVCMeetingViewController {
                let curVC:SVCMeetingViewController = oldVC! as! SVCMeetingViewController
                curVC.removeAll()
            }
            oldVC?.willMove(toParent: nil)
            oldVC?.beginAppearanceTransition(false, animated: true)
            oldVC?.view.removeFromSuperview()
            oldVC?.endAppearanceTransition()
            oldVC?.removeFromParent()
            oldVC = nil
            self.currentVC = nil
            self.currentVC = newVC
        }
    }
    
    private func meetingDesc(type: SessionType) -> String {
        switch type {
        case .p2pVoice:
            return "音频点呼"
        case .p2pVideo:
            return "视频点呼"
        case .avcMeeting:
            return "AVC会议"
        case .svcMeeting:
            return "SVC会议"
        case .voiceMeeting:
            return "语音会议"
        }
    }
    
    deinit {
        isShowInWindow = false
        CLLog("MeetingContainerViewController deinit")
    }

}
