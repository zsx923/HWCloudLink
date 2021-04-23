//
//  VideoMeetingDelegate.swift
//  HWCloudLink
//
//  Created by wangyh on 2020/12/2.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

protocol VideoMeetingDelegate {
    
    func isHiddenSmallVideoView() -> Bool
    func showSmallVideoView()
    func hideSmallVideoView()
    
    func getLocalVideoView() -> EAGLView?
}
