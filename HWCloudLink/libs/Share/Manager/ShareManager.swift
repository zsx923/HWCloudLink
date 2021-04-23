//
//  ShareManager.swift
//  HWCloudLink
//
//  Created by mac on 2021/1/21.
//  Copyright © 2021 陈帆. All rights reserved.
//

import UIKit
import MessageUI

class ShareManager: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    private weak var fromeVc: UIViewController!
    private var  meettingInfo: ConfBaseInfo?
    private var isMeeting = false
}

extension ShareManager {
    
    func share(meetingInfo: ConfBaseInfo?, from vc: UIViewController, isMeeting: Bool = false) {
        self.isMeeting = isMeeting
        self.meettingInfo = meetingInfo
        fromeVc = vc
        
        let shareView = ShareView(models: [])  //传控模型会使用默认模型
        shareView.shareType = {[weak self] shareType in
            switch shareType {
            case .wechat:
                CLLog("点击微信分享")
                self?.shareWechat()
            case .sms:
                CLLog("点击短信分享")
                self?.shareSMS()
            case .email:
                CLLog("点击邮箱分享")
                self?.shareEmail()
            default:
                CLLog("点击连接分享")
                self?.shareInfo()
            }
        }
        shareView.show()
    }
    
    func destroyShareView() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        if let subviewsArr = window?.subviews {
            for view in subviewsArr {
                if view.classForCoder == ShareView.classForCoder(), let shareView = view as? ShareView {
                    shareView.dismiss()
                }
            }
        }
    }
    
    /// 微信分享
    private func shareWechat() {
        if WXApi.isWXAppInstalled() {
            let req = SendMessageToWXReq()
            req.bText = true
            req.text = "测试"
            WXApi.send(req) { (isSucsess) in
                print(isSucsess)
            }
        }else{
            MBProgressHUD.showBottom(tr("尚未安装应用"), icon: nil, view: nil)
        }
    }
    
    
    /// 短信分享
    private func shareSMS() {
        if MFMessageComposeViewController.canSendText() {
            let messageCompose = MFMessageComposeViewController()
            messageCompose.messageComposeDelegate = self
            messageCompose.body = isMeeting ? creatMeeingDecriptionStr() : creatMeeingDecriptionStrNoMeeting()
            fromeVc.present(messageCompose, animated: true, completion: nil)
        }
    }
    
    /// 邮箱分享
    private func shareEmail() {
        let mailCompose = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailCompose.mailComposeDelegate = self
            mailCompose.setSubject(tr("会议邀请"))
//            mailCompose.setToRecipients(["123.com"]) //设置收件人 (数组)
            mailCompose.setMessageBody(isMeeting ? creatMeeingDecriptionStr() : creatMeeingDecriptionStrNoMeeting(), isHTML: false)
            fromeVc.present(mailCompose, animated: true, completion: nil)
        }else{
            guard let url = URL(string: "mailto:") else {
                MBProgressHUD.showBottom(tr("尚未安装应用"), icon: nil, view: nil)
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                MBProgressHUD.showBottom(tr("未配置邮箱，请配置后重试"), icon: nil, view: nil)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else {
                MBProgressHUD.showBottom(tr("尚未安装应用"), icon: nil, view: nil)
            }
        }
    }
    
    /// 复制链接分享
    private func shareInfo() {
        UIPasteboard.general.string = isMeeting ? creatMeeingDecriptionStr() : creatMeeingDecriptionStrNoMeeting()
        MBProgressHUD.showBottom(tr("会议信息已复制"), icon: nil, view: nil)
    }
    
    ///分享正在进行的会议
    private func creatMeeingDecriptionStr() -> String {
        
        if self.meettingInfo?.guestJoinUri.count != 0 {
            return isCNlanguage() ? """
                邀请您参加正在进行的会议
                主题：\(meettingInfo?.confSubject ?? "")

                点击链接加入会议：\(self.meettingInfo?.guestJoinUri ?? "")
             
                使用会议ID入会：
                会议ID：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                \(self.meettingInfo?.generalPwd.count == 0 ? "" : "会议密码：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
            """ : """
                      Invite you to a meeting
                      Meeting Subject: \(meettingInfo?.confSubject ?? "")

                      Click the link to join the meeting: \(self.meettingInfo?.guestJoinUri ?? "")
                   
                      Join the meeting with the meeting ID:
                      Meeting ID: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                      \(self.meettingInfo?.generalPwd.count == 0 ? "" : "Meeting Password: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
                   """
        }else {
            return isCNlanguage() ? """
                      邀请您参加正在进行的会议
                      主题：\(meettingInfo?.confSubject ?? "")
                      使用会议ID入会：
                      会议ID：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                      \(self.meettingInfo?.generalPwd.count == 0 ? "" : "会议密码：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
            """ : """
                Invite you to a meeting
                Meeting Subject: \(meettingInfo?.confSubject ?? "")
                Join the meeting with the meeting ID:
                Meeting ID: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                \(self.meettingInfo?.generalPwd.count == 0 ? "" : "Meeting Password: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
            """
        }
    }
    
    ///分享不是正在进行的会议
    private func creatMeeingDecriptionStrNoMeeting() -> String {
        
        if self.meettingInfo?.guestJoinUri.count != 0 {
            return isCNlanguage() ? """
                \(getMinName())邀请您参加会议
                主题：\(meettingInfo?.confSubject ?? "")
                时间：\(caculateMeetingTimer(meetInfo: meettingInfo))
            
                点击链接加入会议：\(self.meettingInfo?.guestJoinUri ?? "")
            
                使用会议ID入会：
                会议ID：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                \(self.meettingInfo?.generalPwd.count == 0 ? "" : "会议密码：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
            """ : """
                       \(getMinName()) invite you to a meeting
                       Meeting Subject: \(meettingInfo?.confSubject ?? "")
                       Meeting Time: \(caculateMeetingTimer(meetInfo: meettingInfo))
                   
                       Click the link to join the meeting: \(self.meettingInfo?.guestJoinUri ?? "")
                   
                       Join the meeting with the meeting ID:
                       Meeting ID: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                       \(self.meettingInfo?.generalPwd.count == 0 ? "" : "Meeting Password: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
                   """
        }else {
            
            return isCNlanguage() ? """
                \(getMinName())邀请您参加会议
                主题：\(meettingInfo?.confSubject ?? "")
                时间：\(caculateMeetingTimer(meetInfo: meettingInfo))
                使用会议ID入会：
                会议ID：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                \(self.meettingInfo?.generalPwd.count == 0 ? "" : "会议密码：\(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
            """ : """
                       \(getMinName()) invite you to a meeting
                       Meeting Subject: \(meettingInfo?.confSubject ?? "")
                       Meeting Time: \(caculateMeetingTimer(meetInfo: meettingInfo))
                       Join the meeting with the meeting ID:
                       Meeting ID: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.accessNumber ?? "", divideCount: 4))
                       \(self.meettingInfo?.generalPwd.count == 0 ? "" : "Meeting Password: \(SessionHelper.setMeetingIDType(meetingId: self.meettingInfo?.generalPwd ?? "", divideCount: 3))")
                   """
        }
    }
    
    /// 获取姓名
    private func getMinName() -> String {
        let loginInfo = ManagerService.loginService()?.obtainCurrentLoginInfo()
        return  NSString.verifyString(loginInfo?.userName) == "" ? (loginInfo?.account ?? "") : (loginInfo?.userName ?? "")
    }
    
    /// 计算时间
    private func caculateMeetingTimer(meetInfo: ConfBaseInfo?) -> String {
        
        if meetInfo?.endTime != nil && meetInfo?.endTime != ""  {
            // 跨天数
            let startDate = String.string2Date(meetInfo?.startTime.components(separatedBy: " ").first ?? "", dateFormat: "yyyy-MM-dd")
            let endDate = String.string2Date(meetInfo?.endTime.components(separatedBy: " ").first ?? "", dateFormat: "yyyy-MM-dd")
            let gapDay = NSCalendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            
            var startTiem = meetInfo?.startTime.replacingOccurrences(of: "-", with: "/")
            startTiem?.removeLast(3)
            var endTime = meetInfo?.endTime.components(separatedBy: " ").last
            endTime?.removeLast(3)
            var allTime = "\(startTiem ?? "")-\(endTime ?? "")"
            
            if gapDay > 0 {
                allTime = "\(allTime)+\(String(gapDay))"
                let attStr = NSMutableAttributedString.init(string: allTime)
                attStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#999999")!,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, allTime.count - 2))
                attStr.setAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#0091FF")!,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], range: NSMakeRange(allTime.count - 2, 2))
                return attStr.string
            } else {
                return allTime
            }
        } else {
            var time = meetInfo?.startTime ?? ""
            if !time.isEmpty {
                time = time.replacingOccurrences(of: "-", with: "/")
                time.removeLast(3)
                return "\(time)-" + tr("持续会议")
            }
        }
        return ""
    }
}

extension ShareManager {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            CLLog("分享邮件已发送")
        case .failed:
            CLLog("分享邮件发送失败")
        default:
            CLLog("分享邮件发送失败")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            CLLog("分享短信已发送")
        case .failed:
            CLLog("分享短信发送失败")
        default:
            CLLog("分享短信发送失败")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
