//
//  EAGLViewAvcManager.swift
//  HWCloudLink
//
//  Created by mac on 2021/2/5.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit

class EAGLViewAvcManager {
    
    /// 单例初始化
    static let shared = EAGLViewAvcManager()
    private init() {}
    
    /// 辅流
    lazy var viewForBFCP: EAGLView = {
        
        guard let viewForBFCP = EAGLView.getDataConfBFCP() else {
            return EAGLView()
        }
        return viewForBFCP
    }()

    /// 小画面
    lazy var viewForLocal: EAGLView = {
        
        guard let viewForLocal = EAGLView.getLocal() else {
            return EAGLView()
        }
        return viewForLocal
    }()
    
    /// 远端画面
    lazy var viewForRemote: EAGLView = {
        
        guard let viewForRemote = EAGLView.getRemote() else {
            return EAGLView()
        }
        return viewForRemote
    }()
    
    /// SVC远端画面（每一页最多三个远端画面）
    lazy var viewLeftSVCForRemotes: [EAGLView] = { () -> [EAGLView] in
        
        var viewForRemotes:[EAGLView] = []
        
        for i in 0..<4 {
            let eaView = EAGLView.init()
            viewForRemotes.append(eaView)
        }
        
        return viewForRemotes
    }()
    
    lazy var viewMidSVCForRemotes: [EAGLView] = { () -> [EAGLView] in
        
        var viewForRemotes:[EAGLView] = []
        
        for i in 0..<4 {
            let eaView = EAGLView.init()
            viewForRemotes.append(eaView)
        }
        
        return viewForRemotes
    }()
    
    lazy var viewRightSVCForRemotes: [EAGLView] = { () -> [EAGLView] in
        
        var viewForRemotes:[EAGLView] = []
        
        for i in 0..<4 {
            let eaView = EAGLView.init()
            viewForRemotes.append(eaView)
        }
        
        return viewForRemotes
    }()
    
    func getSvcRemoteView(number:Int,indexRow:Int,isAuxiliary:Bool) -> EAGLView {
        let index = (isAuxiliary ? indexRow-2 : indexRow-1) % 3
        
        if index == 0 {
            return viewLeftSVCForRemotes[number]
        }
        
        if index == 1 {
            return viewMidSVCForRemotes[number]
        }
        
        if index == 2 {
            return viewRightSVCForRemotes[number]
        }
        
        return EAGLView()
    }
}
