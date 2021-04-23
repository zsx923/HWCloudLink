//
//  UIViewController+FF.swift
//  SideSlideDemo
//
//  Created by 冯琦帆 on 2018/7/17.
//  Copyright © 2018年 冯琦帆. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    
    func suspend(coverImageName: String, type: SuspendType, svcManager:SVCMeetingManager?) {
    
    UIView.animate(withDuration: 0.25, animations: {
        if self is VideoViewController {
            let VMvc:VideoViewController = self as! VideoViewController
            VMvc.navBackView.isHidden = true
            VMvc.bottomView.isHidden = true
            VMvc.showRecordTimeLabel.isHidden = true
            VMvc.leaveBtn.isHidden = true
            VMvc.view.alpha = 0
            self.view.layer.cornerRadius = 2
            self.view.layer.masksToBounds = true
            self.view.frame = CGRect.init(origin: SuspendTool.sharedInstance.origin, size: SuspendTool.videoSuspendSize)
            self.view.layoutIfNeeded()
        }else if self is VoiceViewController {
            let Callvc:VoiceViewController = self as! VoiceViewController
            Callvc.view.alpha = 0
            self.view.layer.cornerRadius = 2
            self.view.layer.masksToBounds = true
            self.view.frame = CGRect.init(origin: SuspendTool.sharedInstance.voiceOrigin, size: SuspendTool.voiceSuspendSize)
            self.view.layoutIfNeeded()
        }else if self is VoiceMeetingViewController {
            let Callvc:VoiceMeetingViewController = self as! VoiceMeetingViewController
            Callvc.view.alpha = 0
            self.view.layer.cornerRadius = 2
            self.view.layer.masksToBounds = true
            self.view.frame = CGRect.init(origin: SuspendTool.sharedInstance.voiceOrigin, size: SuspendTool.voiceSuspendSize)
            self.view.layoutIfNeeded()
        }else if self is SVCMeetingViewController {
            let VMvc:SVCMeetingViewController = self as! SVCMeetingViewController
            VMvc.navBackView.isHidden = true
            VMvc.bottomView.isHidden = true
            VMvc.showRecordTimeLabel.isHidden = true
            VMvc.leaveBtn.isHidden = true
            VMvc.showTopVoiceBtn.isHidden = true
            VMvc.pageControl.isHidden = true
            VMvc.view.alpha = 0
            self.view.layer.cornerRadius = 2
            self.view.layer.masksToBounds = true
            self.view.frame = CGRect.init(origin: SuspendTool.sharedInstance.origin, size: SuspendTool.videoSuspendSize)
            self.view.layoutIfNeeded()
        }else if self is AVCMeetingViewController {
            let VMvc:AVCMeetingViewController = self as! AVCMeetingViewController
            VMvc.navBackView.isHidden = true
            VMvc.bottomView.isHidden = true
            VMvc.showRecordTimeLabel.isHidden = true
            VMvc.leaveBtn.isHidden = true
            VMvc.showTopVoiceBtn.isHidden = true
            VMvc.videoStreamView?.pageControl.isHidden = true
            VMvc.view.alpha = 0
            self.view.layer.cornerRadius = 2
            self.view.layer.masksToBounds = true
            self.view.frame = CGRect.init(origin: SuspendTool.sharedInstance.origin, size: CGSize.init(width: SuspendTool.videoSuspendSize.height, height: SuspendTool.videoSuspendSize.width))
            self.view.layoutIfNeeded()
        }
    }) { (complete) in
        self.dismiss(animated: false) {
            var isAvc = false
            if self is VideoViewController {
                let VMvc:VideoViewController = self as! VideoViewController
                VMvc.navBackView.isHidden = false
                VMvc.bottomView.isHidden = false
                VMvc.showRecordTimeLabel.isHidden = false
                VMvc.leaveBtn.isHidden = false
                VMvc.view.alpha = 1
                VMvc.navigationController?.navigationBar.alpha = 1
            }else if self is VoiceViewController {
                let Callvc:VoiceViewController = self as! VoiceViewController
                Callvc.navigationController?.navigationBar.alpha = 1
                Callvc.view.alpha = 1
            }else if self is VoiceMeetingViewController {
                let Callvc:VoiceMeetingViewController = self as! VoiceMeetingViewController
                Callvc.navigationController?.navigationBar.alpha = 1
                Callvc.view.alpha = 1
            }else if self is SVCMeetingViewController {
                let VMvc:SVCMeetingViewController = self as! SVCMeetingViewController
                VMvc.navBackView.isHidden = false
                VMvc.bottomView.isHidden = false
                VMvc.showRecordTimeLabel.isHidden = false
                VMvc.leaveBtn.isHidden = false
                VMvc.showTopVoiceBtn.isHidden = false
                VMvc.pageControl.isHidden = false
                VMvc.view.alpha = 1
                VMvc.navigationController?.navigationBar.alpha = 1
                // 移除所有与会者
//                VMvc.videoStreamView.removeAllAttendeeVideoView()
            }else if self is AVCMeetingViewController {
                let VMvc:AVCMeetingViewController = self as! AVCMeetingViewController
                VMvc.navBackView.isHidden = false
                VMvc.bottomView.isHidden = false
                VMvc.showRecordTimeLabel.isHidden = false
                VMvc.leaveBtn.isHidden = false
                VMvc.showTopVoiceBtn.isHidden = false
                VMvc.videoStreamView?.refreshPageControl()
                VMvc.view.alpha = 1
                VMvc.navigationController?.navigationBar.alpha = 1
                isAvc = true
            }
            if type == .video {
                SuspendTool.showVideoSuspendWindow(rootViewController: self, isAvc: isAvc, svcManager: svcManager)
            }
            if type == .voice {
                SuspendTool.showVoiceSuspendWindow(rootViewController: self)
            }
            if type == .auxvid {
                SuspendTool.showAuxShareSuspendWindo(rootViewController: self, isAvc: true)
            }
        }
    }
  }

    
    func spread(from window:UIWindow) {
        if self is VoiceViewController {
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.view.frame = CGRect(x: 0, y: 0, width: window.width, height: window.height)
            window.addSubview(self.view)
        }
        UIView.animate(withDuration: 0.25, animations: {
            window.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
            let View = window.subviews.first
            View?.frame = window.bounds
            View?.layoutIfNeeded()
        }) { [weak self] (complete) in
            guard let self = self else { return }
            if self is VoiceViewController {
                
                guard let currentVC = self as? VoiceViewController else { return }
                let containerVC = MeetingContainerViewController()
                containerVC.sessionType = .p2pVoice
                containerVC.isResumeFromSuspend = true
                containerVC.currentVC = currentVC
                
                SessionManager.shared.meetingMainVC = containerVC
                
                let navigationVC = BaseNavigationController(rootViewController: containerVC)
                navigationVC.modalPresentationStyle = .overFullScreen
                navigationVC.modalTransitionStyle = .coverVertical
                
                UIViewController.currentViewController().present(navigationVC, animated: false) {
                    NotificationCenter.default.removeObserver(window)
                    window.alpha = 0.0
                    window.isHidden = true
                    SuspendTool.remove()
                }
                return
            }
            if self is VoiceMeetingViewController {
                guard let currentVC = self as? VoiceMeetingViewController else { return }
                let containerVC = MeetingContainerViewController()
                containerVC.sessionType = .voiceMeeting
                containerVC.isResumeFromSuspend = true
                containerVC.currentVC = currentVC
                
                SessionManager.shared.meetingMainVC = containerVC
                
                let navigationVC = BaseNavigationController(rootViewController: containerVC)
                navigationVC.modalPresentationStyle = .overFullScreen
                navigationVC.modalTransitionStyle = .coverVertical
                
                UIViewController.currentViewController().present(navigationVC, animated: false) {
                    NotificationCenter.default.removeObserver(window)
                    window.alpha = 0.0
                    window.isHidden = true
                    SuspendTool.remove()
                }
                return
            }
            if self is VideoViewController {
                guard let currentVC = self as? VideoViewController else { return }
                let containerVC = MeetingContainerViewController()
                containerVC.sessionType = .p2pVideo
                containerVC.isResumeFromSuspend = true
                containerVC.currentVC = currentVC
                
                SessionManager.shared.meetingMainVC = containerVC
                
                let navigationVC = BaseNavigationController(rootViewController: containerVC)
                navigationVC.modalPresentationStyle = .overFullScreen
                navigationVC.modalTransitionStyle = .coverVertical
                
                currentVC.addOrientationObserver()
                UIViewController.currentViewController().present(navigationVC, animated: false) {
                    window.alpha = 0.0
                    window.isHidden = true
                    SuspendTool.remove()
                    if let callId = currentVC.callInfo?.stateInfo.callId {
                        currentVC.updateVideoConfig(callId: callId)
                    }
                }
                return
            }
            if self is AVCMeetingViewController {
                
                guard let currentVC:AVCMeetingViewController = self as? AVCMeetingViewController else { return }
                let containerVC = MeetingContainerViewController()
                containerVC.sessionType = .avcMeeting
                containerVC.isResumeFromSuspend = true
                containerVC.currentVC = currentVC
                
                SessionManager.shared.meetingMainVC = containerVC
                
                let navigationVC = BaseNavigationController(rootViewController: containerVC)
                navigationVC.modalPresentationStyle = .overFullScreen
                navigationVC.modalTransitionStyle = .coverVertical
                
                currentVC.addOrientationObserver()
                UIViewController.currentViewController().present(navigationVC, animated: false) {
                    window.alpha = 0.0
                    window.isHidden = true
                    SuspendTool.remove()
                    currentVC.updateBotomSmalIV()
                    currentVC.videoStreamView?.collectionForPageView.reloadData()
                }
                return
            }
            if self is SVCMeetingViewController {
                guard let currentVC = self as? SVCMeetingViewController else { return }
                let containerVC = MeetingContainerViewController()
                containerVC.sessionType = .svcMeeting
                containerVC.isResumeFromSuspend = true
                containerVC.currentVC = currentVC
                
                SessionManager.shared.meetingMainVC = containerVC
                
                let navigationVC = BaseNavigationController(rootViewController: containerVC)
                navigationVC.modalPresentationStyle = .overFullScreen
                navigationVC.modalTransitionStyle = .coverVertical
                
                currentVC.addOrientationObserver()
                UIViewController.currentViewController().present(navigationVC, animated: false) {
                    // 发送点击放大视频通知,打开后需要刷新页面
                    NotificationCenter.default.post(name: NSNotification.Name.init(SVCSmallWindowZoomChange), object: nil)
                    
                    window.alpha = 0.0
                    window.isHidden = true
                    SuspendTool.remove()
                }
                return
            }
        }
    }

  static func currentViewController() -> UIViewController {
    let windowTemp = (UIApplication.shared.delegate?.window)!
    
    // 获取根控制器
    var currentViewController = windowTemp?.rootViewController
    while true {
        if ((currentViewController?.presentedViewController) != nil) {
            currentViewController = currentViewController?.presentedViewController
        } else if (currentViewController?.isKind(of: UINavigationController.classForCoder()))! {
            let navigationVC = currentViewController as! UINavigationController
            currentViewController = navigationVC.children.last
        } else if (currentViewController?.isKind(of: UITabBarController.classForCoder()))! {
            let tabbarVC = currentViewController as! UITabBarController
            currentViewController = tabbarVC.selectedViewController
        } else {
            let childVCCount = currentViewController?.children.count;
            if childVCCount! > 0 {
                currentViewController = currentViewController?.children.last
            }
            return currentViewController!
        }
    }
    
    return currentViewController!
  }

}
