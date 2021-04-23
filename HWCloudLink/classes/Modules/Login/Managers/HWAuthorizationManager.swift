//
//  HWAuthorizationManager.swift
//  HWCloudLink
//
//  Created by Jabien on 2020/8/22.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import AVFoundation

class HWAuthorizationManager: NSObject, TextTitleViewDelegate {
    
    static var shareInstanst : HWAuthorizationManager {
        return HWAuthorizationManager()
    }
    
    // 判断是否授权摄像头权限（无弹框）
    func authorizeToCameraphone(completion:@escaping (Bool) -> Void) {
        CLLog("authorize to Cameraphone")
        var isAuth = true
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                isAuth = granted
            }
            isAuth = false
        case .restricted:
            isAuth = false
        case .denied:
            isAuth = false
        default:
            isAuth = true
        }
        CLLog("摄像头权限 -\(isAuth ? "true" : "false")")
        completion(isAuth)
    }
    
    func isAuthorizeCameraphone() -> Bool {
        var isAuth = true
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                isAuth = granted
            }
            isAuth = false
        case .restricted:
            isAuth = false
        case .denied:
            isAuth = false
        default:
            isAuth = true
        }
        return isAuth
    }
    
    
    // 判断是否授权麦克风权限（无弹框）
    func authorizeToMicrophone(completion:@escaping (Bool) -> Void) {
        var isAuth = true
        let recordingSession = AVAudioSession.sharedInstance()
        switch recordingSession.recordPermission{
        case AVAudioSession.RecordPermission.granted:
            //已授权
            isAuth = true
            break
        case AVAudioSession.RecordPermission.denied:
            //拒绝授权
            isAuth = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            //请求授权
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    isAuth = allowed
                }
            }
        @unknown default:
            isAuth = false
            CLLog("authorize to microphone error.")
        }
        CLLog("麦克风权限-\(isAuth ? "true" : "false")")
        completion(isAuth)
    }
    
    func isAuthorizeToMicrophone() -> Bool {
        var isAuth = true
        let recordingSession = AVAudioSession.sharedInstance()
        switch recordingSession.recordPermission{
        case AVAudioSession.RecordPermission.granted:
            //已授权
            isAuth = true
            break
        case AVAudioSession.RecordPermission.denied:
            //拒绝授权
            isAuth = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            //请求授权
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    isAuth = allowed
                }
            }
        @unknown default:
            isAuth = false
        }
        return isAuth
    }
    
    // 麦克风权限弹框
    func alertAuthorizeToCameraphone(completion:@escaping (Bool) -> Void) {
        CLLog("authorize to Cameraphone")
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .notDetermined { // 请求授权
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                completion(granted)
            }
        } else if authStatus == .restricted || authStatus == .denied { // 未授权 需要弹框
            // 弹出授权框
            let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
            alertTitleVC.modalTransitionStyle = .crossDissolve
            alertTitleVC.modalPresentationStyle = .overFullScreen
            alertTitleVC.accessibilityValue = "100"
            alertTitleVC.customDelegate = self
            ViewControllerUtil.getCurrentViewController().present(alertTitleVC, animated: true, completion: nil)
            completion(false)
        }else{
            completion(true)
        }
    }
    
    // 麦克风权限弹框
    func alertAuthorizeToMicrophone(showVC:UIViewController,completion:@escaping (Bool) -> Void) {
        let recordingSession = AVAudioSession.sharedInstance()
        switch recordingSession.recordPermission{
        case AVAudioSession.RecordPermission.granted:
            //已授权
            completion(true)
            break
        case AVAudioSession.RecordPermission.denied:
            //拒绝授权
            // 弹出授权框
            let alertTitleVC = TextTitleViewController.init(nibName: "TextTitleViewController", bundle: nil)
            alertTitleVC.modalTransitionStyle = .crossDissolve
            alertTitleVC.modalPresentationStyle = .overFullScreen
            alertTitleVC.accessibilityValue = "200"
            alertTitleVC.customDelegate = self
            showVC.present(alertTitleVC, animated: true, completion: nil)
            completion(false)
            break
        case AVAudioSession.RecordPermission.undetermined:
            //请求授权
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        @unknown default:
            CLLog("authorize to microphone error.")
        }
    }
    
    // MARK - TextTitleViewDelegate
    
    func textTitleViewViewDidLoad(viewVC: TextTitleViewController) {
        if viewVC.accessibilityValue == "100" {
            viewVC.showTitleLabel.text = tr("打开摄像头需要开启摄像头权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
        if viewVC.accessibilityValue == "200" {
            viewVC.showTitleLabel.text = tr("打开麦克风需要开启麦克风权限")
            viewVC.showLeftBtn.setTitle(tr("取消"), for: .normal)
            viewVC.showRightBtn.setTitle(tr("确定"), for: .normal)
        }
    }
    
    func textTitleViewLeftBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        
    }
    
    func textTitleViewRightBtnClick(viewVC: TextTitleViewController, sender: UIButton) {
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
}
