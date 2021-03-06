//
//  CCPAuthorization.swift
//  CCPAuthorization
//
//  Created by clobotics_ccp on 2019/8/22.
//  Copyright © 2019 cool-ccp. All rights reserved.
//
import Foundation
import UserNotifications
import Photos
import AssetsLibrary
import MediaPlayer
import CoreTelephony
import AVFoundation

public enum CCPAuthorizationStatus {
    case notDetermind
    case denied
    case authorized
}

public typealias CCPAuthorizationCallback = (CCPAuthorizationStatus) -> ()

public enum CCPAuthorization {
    case album
    case camera
    case bluetooth //ios13.0后更新
    case calendar
    case contact
    case faceID //可用于判断touchID
    case locationInUse
    case locationAlays
    case net
    case notification(UNAuthorizationOptions)
    case microphone
    case reminder
    
    case health//NSHealthShareUsageDescription
    case motion //NSMicrophoneUsageDescription
    case siri //NSSiriUsageDescription
    case speechRecognition //NSSpeechRecognitionUsageDescription
    case clinicalHealthRecords //NSHealthClinicalHealthRecordsShareUsageDescription
    case homeKit //NSHomeKitUsageDescription
    
}


extension CCPAuthorization {
    //用户拒绝时显示alert插件。如果自定义插件，需要遵守CCPAlertPlugin协议
    static var alertPlugin: CCPAlertPlugin = CCPAlertPluginDefault()
    //用户拒绝时是否显示alert插件
    static var needAlertWhenDenied = true
    //保存上一次获取到的状态，如果上一次的状态为notDetermind，不弹出用户拒绝时显示的alert插件
    static var lastStatus: CCPAuthorizationStatus = .notDetermind
    
    public func mediaPlayerApply() {
        hw_openMediaPlayerServiceWithBlock { (status) in
            
        }
    }
    ///  权限申请
    ///
    /// - Parameters:
    ///   - callback: 申请回调
    ///   - callbackQueue: 回调队列, default is main
    public func apply(_ callback: CCPAuthorizationCallback? = nil, callbackQueue: DispatchQueue = .main) {
        CCPAuthorization.lastStatus = status        
        let executeCallback: CCPAuthorizationCallback = { status in
            callbackQueue.async {
                if CCPAuthorization.needAlertWhenDenied && status == .denied && CCPAuthorization.lastStatus != .notDetermind  {
                    CCPAuthorization.alertPlugin.alert(self)
                }
                callback?(status)
            }
        }
                
        switch self {
        case .album:
            album(executeCallback)
        case .camera:
            camera(executeCallback)
        case .microphone:
            microphone(executeCallback)
        case .contact:
            contact(executeCallback)
        case .calendar:
            calendar(executeCallback)
        case .reminder:
            reminder(executeCallback)
        case .faceID:
            FaceIDAuthorization.faceID(executeCallback)
        case .notification(let opts):
            notification(opts, executeCallback)
        default:
            ()
        }
    }
    
    
    /// 当前权限状态
    public var status: CCPAuthorizationStatus {
        switch self {
        case .album:
            return albumStatus
        case .camera:
            return cameraStatus
        case .microphone:
            return microphoneStatus
        case .contact:
            return contactStatus
        case .calendar:
            return calendarStatus
        case .reminder:
            return reminderStatus
        case .faceID:
            return FaceIDAuthorization.faceIDStatus
        case .notification:
            return notificationStatus() ?? .notDetermind
        default:
            return .notDetermind
        }
    }
}

internal extension CCPAuthorization {
    func granted(_ isGranted: Bool, _ callback: CCPAuthorizationCallback?) {
        isGranted ? callback?(.authorized) : callback?(status)
    }
    // MARK: - 开启媒体资料库/Apple Music 服务
    /// 开启媒体资料库/Apple Music 服务
    @available(iOS 9.3, *)
    func hw_openMediaPlayerServiceWithBlock(_ isSet:Bool? = nil,_ action :@escaping ((Bool)->())) {
        let authStatus = MPMediaLibrary.authorizationStatus()
        if authStatus == MPMediaLibraryAuthorizationStatus.notDetermined {
            MPMediaLibrary.requestAuthorization { (status) in
                if (status == MPMediaLibraryAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        action(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        action(false)
                         if isSet == true {hw_OpenURL()}
                    }
                }
            }
        } else if authStatus == MPMediaLibraryAuthorizationStatus.authorized {
            action(true)
        } else {
            action(false)
             if isSet == true {hw_OpenURL()}
        }
    }
    
    // MARK: - 跳转系统设置界面
    func hw_OpenURL() {
        let title = "访问受限"
        var message = "请点击“前往”，允许访问权限"
        let appName: String = (Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? "") as! String //App 名称
        message = "请在iPhone的\"设置-隐私-媒体与Apple Music\"选项中，允许\"\(appName)\"访问您的媒体库"
        let url = URL(string: UIApplication.openSettingsURLString)
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
        let settingsAction = UIAlertAction(title:"前往", style: .default, handler: {
            (action) -> Void in
            if  UIApplication.shared.canOpenURL(url!) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url!, options: [:],completionHandler: {(success) in})
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}



