//
//  ErrorMsgOfLogin.swift
//  HWCloudLink
//
//  Created by cos on 2020/12/12.
//  Copyright © 2020 陈帆. All rights reserved.
//

import Foundation

extension LoginViewController {
    /// 获取错误提示信息
    /// - Parameters:
    ///   - error: error <NSError>
    ///   - type: 类型：true(登录)，false(修改密码)
    /// - Returns: 提示信息
    static func loginFailMsgWith(error: NSError, type: Bool) -> String {
        let codeStr = Tools.toHex(Int64(error.code))
        let passwordErrorStr1 = Tools.toHex(Int64(TSDK_E_LOGIN_ERR_AUTH_NAME_OR_PWD_ERROR.rawValue))
        let passwordErrorStr2 = Tools.toHex(Int64(TSDK_E_CALL_ERR_REASON_CODE_FORBIDDEN.rawValue))
        let isPasswordError : Bool = codeStr == passwordErrorStr1 || codeStr == passwordErrorStr2
        var errorString = LoginViewController.loginFailMsgWith(code: UInt32(error.code), type: type)
        // 账号或密码错误 && 剩余输入次数大于0
        if isPasswordError && Int(error.userInfo["residualRetryTimes"] as? String ?? "0") ?? 0 > 0 {
            let text = String(format: tr("账号或者密码错误，剩余%@次锁定"), error.userInfo["residualRetryTimes"] as! String)
            errorString = text
        }
        // 账号已被锁定
        if Int(error.userInfo["lockInterval"] as? String ?? "0") ?? 0 > 0 {
            errorString = tr("帐号已被锁定")
        }
        
        return errorString
    }
    
    
    /// 账号修改密码失败回调（服务器正在同步账号）
    /// - Parameter error: error信息
    /// - Returns: 服务器是否正在同步账号
    static func loginFailAccountSyncMsgWith(error: NSError) -> Bool {
        let codeStr = Tools.toHex(Int64(error.code))

        /* modify at chenfan 2021/02/04 : SMC3.0首次登录修改密码后登录失败提示处理
         (错误码为TSDK_E_CALL_ERR_REASON_CODE_FORBIDDEN 并且首次密码界面回来的) */
        if codeStr == Tools.toHex(Int64(TSDK_E_CALL_ERR_REASON_CODE_FORBIDDEN.rawValue)) {
            if LoginViewController.isFirstChangePassword {
                return true
            }
        }
        
        return false
    }
    
    /// 首次修改密码帐号已被锁定
    /// - Parameter error: error信息
    static func loginFailFirstChangePWDWith(error: Error?, vc: UIViewController) {
        if LoginViewController.isFirstChangePassword {
            guard let errorTemp = error as NSError? else {
                MBProgressHUD.showBottom(tr("密码修改成功"), icon: nil, view: nil)
                return
            }
            
            let codeStr = Tools.toHex(Int64(errorTemp.code))
            switch codeStr {
            case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_AUTH_NAME_OR_PWD_ERROR.rawValue)):
                // 帐号已被锁定  - 回退到登录界面
                if let topVC = vc.navigationController?.viewControllers.last {
                    topVC.navigationController?.popViewController(animated: true)
                    LoginViewController.isFirstChangePassword = false
                }
            default:
                MBProgressHUD.showBottom(tr("密码修改成功"), icon: nil, view: nil)
            }
        }
        
    }
    
    
    
    /// 获取错误提示信息
    /// - Parameters:
    ///   - code: 错误码
    ///   - type: 类型：true(登录)，false(修改密码)
    /// - Returns: 提示信息
    static func loginFailMsgWith(code: UInt32, type: Bool) -> String {
        let codeStr = Tools.toHex(Int64(code))
        switch codeStr {
        // MARK: - 登录失败
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NETWORK_ERROR.rawValue)),
             Tools.toHex(Int64(TSDK_E_CALL_ERR_REASON_CODE_TCP_ESTFAIL.rawValue)),
             Tools.toHex(Int64(TSDK_E_LOGIN_ERR_AUTH_FAILED.rawValue)):
            return type ? tr("登录失败，请检查登录配置或联系管理员") : tr("密码修改失败")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_TIMEOUT.rawValue)),
             Tools.toHex(Int64(TSDK_E_CALL_ERR_ACCESS_ERROR.rawValue)),
             Tools.toHex(Int64(TSDK_E_CALL_ERR_REASON_CODE_REQUESTTIMEOUT.rawValue)):
            return tr("网络连接超时")
        case Tools.toHex(Int64(TSDK_E_CALL_ERR_REASON_CODE_TEMPORARILYUNAVAILABLE.rawValue)):
            return tr("此帐号已在其他终端登录")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_SERVICE_ERROR.rawValue)):
            return tr("服务器异常")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_ACCOUNT_LOCKED.rawValue)):
            return tr("帐号已被锁定")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_SEARCH_SERVER_FAIL.rawValue)):
            return tr("查询服务器地址失败")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_AUTH_ACCOUNT_DIACTIVE.rawValue)):
            return tr("账号未激活,请确认是否绑定终端号码")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_DNS_ERROR.rawValue)):
            return tr("DNS解析异常")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_ACCOUNT_EXPIRE.rawValue)):
            return tr("用户密码已过期，请联系管理员")

        // MARK: - 修改密码
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NOT_SUPPORT_MOD_PWD.rawValue)):
            return tr("系统不支持修改密码")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_WRONG_OLD_PWD.rawValue)):
            return tr("旧密码错误")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_INVAILD_NEW_PWD_LEN.rawValue)):
            return tr("新密码长度非法")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_INVAILD_NEW_PWD_LEVEL.rawValue)):
            return tr("新密码复杂度不满足要求")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NEW_PWD_CANNOT_SAME_WITH_HISTROY_PWD.rawValue)):
            return tr("新密码不能与近期使用过的密码相同")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NEW_PWD_REPEAT_CHAR_NUM_IS_BIG.rawValue)):
            return tr("新密码不能包含3个以上重复字符")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_MOD_PWD_TOO_FREQUENTLY.rawValue)):
            return tr("上次修改密码后5分钟内不能更新密码")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NEW_PWD_CANNOT_CONTAIN_ACCOUNT.rawValue)):
            return tr("密码不能包含帐号或其逆序帐号")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NEW_PWD_CONTAIN_TOO_MANY_SAME_CHAR_WITH_OLD_PWD.rawValue)):
            return tr("新密码相较于旧密码至少要有两个不同的字符")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_USER_IS_LOCKED.rawValue)):
            return tr("帐号已被锁定")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_NEW_PWD_CANNOT_SAME_WITH_OLD_PWD.rawValue)):
            return tr("新密码不能与旧密码相同")
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_BUTT.rawValue)),
             Tools.toHex(Int64(TSDK_E_LOGIN_ERR_USER_WEAK_PASSWORD.rawValue)):
            return tr("密码过于简单或不安全")

        // MARK: - 类型：true(登录)，false(修改密码)
        case Tools.toHex(Int64(TSDK_E_LOGIN_ERR_AUTH_NAME_OR_PWD_ERROR.rawValue)),
             Tools.toHex(Int64(TSDK_E_CALL_ERR_REASON_CODE_FORBIDDEN.rawValue)):
            return type ? tr("帐号或密码错误, 请重新输入") : tr("用户名或者密码错误")
        default:
            return type ? tr("登录失败，请检查登录配置或联系管理员") : tr("密码修改失败")
        }
    }
}
