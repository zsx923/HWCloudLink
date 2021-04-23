//
//  MeetingViewController.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/2.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import ReplayKit

typealias UpdateCallSecondsBlock = (Int, Bool) -> Void


class MeetingViewController: UIViewController {

    //接收方信息
    var meetInfo: ConfBaseInfo?
    //呼叫方信息
    var callInfo: CallInfo?
    
    var alertText: String =  ""
    
    // 释放主持人的number
    fileprivate var number = "0"

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Notification
    
    func registerNotifications() {

        // TODO : 取消点呼和会议各个页面继承的系统 耳机\听筒状态监听继承
        //        将各个系统子页面的监听业务 抽到父类中统一监听和继承方式（统一监听TUP  MSGID = 2014 接口）
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNoStream(noti:)), name: NSNotification.Name.init(rawValue: CALL_S_CALL_EVT_NO_STREAM_DURATION), object: nil)
        
//        self.registerExtensionRecordStatusUpdate()
    }
    
    @objc private func notificationNoStream(noti: Notification) {
        guard let resultStr = noti.userInfo?[CALL_S_CALL_EVT_NO_STREAM_DURATION] as? NSString  else { return }

        CLLog("无码流时长======\(resultStr)")

        switch resultStr {
        case "10", "20":
            MBProgressHUD.show(tr("当前网络异常"), icon: nil, view: CLWindow)
        case "30":
            self.noStreamAlertAction()
            passiveStopShareScreen()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noStreamAlertNoti"), object: nil)
            }
        default:
            return
        }
    }
    
    func noStreamAlertAction() {
        // 子类重写
    }
    func showReplayKitUI()  {
        //子类重写
    }
    func showBottomHUD(_ title: String) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            MBProgressHUD.showBottom(title, icon: nil, view: nil)
        }
    }
    func showBottomHUD(_ title: String, view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            MBProgressHUD.showBottom(title, icon: nil, view: view)
        }
    }
    
    func isComing() -> Bool {
        return self.meetInfo?.isComing ?? false
    }
    
     func alertAuthRequest(_ str: String) {
        // 弹出授权框
        let alertTitleVC = TextTitleViewController()
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.customDelegate = self
        alertTitleVC.accessibilityValue = str
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    // 释放主席弹窗提示
    func releaseChairmanWithAlert(num: String?) {
        self.number = num ?? "0"
        
        let alertTitleVC = TextTitleViewController(nibName: "TextTitleViewController", bundle: nil)
        alertTitleVC.modalTransitionStyle = .crossDissolve
        alertTitleVC.modalPresentationStyle = .overFullScreen
        alertTitleVC.customDelegate = self
        alertTitleVC.accessibilityValue = "ReleaseChairman"
        self.present(alertTitleVC, animated: true, completion: nil)
    }
    
    func requestMuteAlert() {
        CLLog("requestMuteAlert")
        alertAuthRequest("Mute")
    }
    
    func requestCameraAlert() {
        CLLog("requestCameraAlert")
        alertAuthRequest("Camera")
    }
    
    // 靠近耳朵息屏
    func closeToTheEarScreen(isProximityMonitoringEnabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        let curDevice = UIDevice.current
        curDevice.isProximityMonitoringEnabled = isProximityMonitoringEnabled
        if !isProximityMonitoringEnabled {
            return
        }
        NotificationCenter.default.addObserver(forName: UIDevice.proximityStateDidChangeNotification, object: nil, queue: OperationQueue.main) { (_) in
            if curDevice.proximityState == true {
                
            } else {
                
            }
        }
    }
}

extension MeetingViewController: TextTitleViewDelegate {
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        switch viewVC.accessibilityValue {
        case "Camera":
            viewVC.showTitleLabel.text = tr("打开摄像头需要开启摄像头权限")
        case "Mute":
            viewVC.showTitleLabel.text = tr("打开麦克风需要开启麦克风权限")
        case "auxReq":
            viewVC.showTitleLabel.text = tr("有人正在共享，是否要取代？")
        case "ReleaseChairman":
            viewVC.showTitleLabel.text = tr("会议将无主持人，是否释放")
        default: break
        }
        
        viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
        viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
    }
    
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        if viewVC.accessibilityValue == "auxReq" {
            viewVC.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        if viewVC.accessibilityValue == "auxReq" {
            self.showReplayKitUI()
            return
        }
        if viewVC.accessibilityValue == "ReleaseChairman" {
            CLLog("释放主持人,账号 = \(String(describing: number))")
            let result = ManagerService.confService()?.confCtrlReleaseChairman(self.number) ?? false
            if !result {
                MBProgressHUD.showBottom(tr("释放主持人失败"), icon: nil, view: nil)
            }
            return
        }
        
        viewVC.dismiss(animated: true, completion: nil)
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

extension MeetingViewController {
    //被动结束扩展进程
   private func passiveStopShareScreen() -> Void {
        let cfnotification = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(cfnotification, CFNotificationName.init("STOPSHARED" as CFString), nil, nil, true)
        ManagerService.call()?.stopSendAuxData(withCallId:UInt32(self.meetInfo?.callId ?? 0))
    }
}
