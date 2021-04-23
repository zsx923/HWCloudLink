//
//  ListenTypeChageAble.swift
//  HWCloudLink
//
//  Created by mac on 2020/7/14.
//  Copyright © 2020 陈帆. All rights reserved.
//

import UIKit
import AVFoundation

enum ListenType {
    case earphone
    case elephone
    case other
}

let listenTypeChangeNotifiName = "listenTypeChangeNotifiName"
let listenTypeChangeNotifikey = "listenTypeChangeNotifikey"

protocol ListenTypeChageAble {
    func listenTypeChange(_ listenType: ListenType)
}

class ListenTypeChage {
    
    var delegate: ListenTypeChageAble?
   
    var listenType: ListenType = .elephone
    
    static var shared: ListenTypeChage {
        struct Static {
            static let instance: ListenTypeChage = ListenTypeChage()
        }
        return Static.instance
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ListenTypeChage {
    
    //判断是否插着耳机
    var isHeadSetPlugging: Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
            
            if desc.portType == .headphones {
                return true
            }
        }
        return false
    }
    
    func addObseveListenChang() {
        
    }
    
    @objc private func listenChang(notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String : AVAudioSession.RouteChangeReason] else {
            return
        }
        
        let routeChangeReason = userInfo[AVAudioSessionRouteChangeReasonKey]
        switch routeChangeReason {
        case .newDeviceAvailable:
            listenType = .earphone
            CLLog("耳机模式")
        case .oldDeviceUnavailable:
            listenType = .elephone
            CLLog("听筒模式")
        default:
            listenType = .other
        }
        
       //通知设备变化(通知)
        NotificationCenter.default.post(name: NSNotification.Name(listenTypeChangeNotifiName), object: nil, userInfo: [listenTypeChangeNotifikey:listenType])
        //通知设备变化(代理)
        if delegate != nil {
            delegate?.listenTypeChange(listenType)
        }
    }
}
