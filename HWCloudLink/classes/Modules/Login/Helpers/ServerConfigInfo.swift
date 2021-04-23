//
//  ServerConfigInfo.swift
//  HWCloudLink
//
//  Created by wangyh1116 on 2020/12/18.
//  Copyright © 2020 薛国栋. All rights reserved.
//  add at xuege: 服务器配置信息

import Foundation

class ServerConfigInfo {
    /// 服务器配置信息对应的键<ServerConfigKeys>
    enum ServerConfigKeys: String {
        case address            // 服务器地址
        case port               // 服务器端口
        case sipUri             // SIP URI
        case udpPort            // UDP 端口
        case tlsPort            // TLS 端口
        case srtp               // SRTP加密: 0 -> OPTION, 1-> DISABLE, 2-> FORCE
        case transport          // 传输模式: 0 -> UDP, 1-> TLS, 2-> TCP
        case bfcp               // BFCP 传输类型: 0 -> UDP, 1-> TLS, 2-> TCP
        case priorityType       // 配置的优先级: 0 -> SYSTEM, 1 -> APP
        case tunnel             // 安全隧道使用模式: 0 -> DEFAULT, 1 -> DISABLE, 2 -> FORCE
        case smSecurity         // 国密: 0 -> close, 1 -> open
        case tlsCompatibility   // TLS兼容模式: 0 -> close, 1 -> open
        case httpsPort          // HTTPS
    }
    
    /// 保存单个服务器配置信息
    /// - Parameters:
    ///   - value: 配置信息<String>
    ///   - key: ServerConfigKeys
    static func set(value: String, forKey key: ServerConfigKeys) {
        UserDefaults.standard.setValue(value, forKey: "SERVER_CONFIG_INFO_\(key.rawValue)")
        UserDefaults.standard.synchronize()
    }
    
    /// 保存多个服务器参数
    /// - Parameter dic: Dictionary<ServerConfigKeys, String>
    static func setValuesWithDictionary(dic: Dictionary<ServerConfigKeys, String>) {
        for key in dic.keys {
            UserDefaults.standard.setValue(dic[key], forKey: "SERVER_CONFIG_INFO_\(key.rawValue)")
        }
        UserDefaults.standard.synchronize()
    }
    
    /// 获取单个服务器配置信息
    /// - Parameter key: ServerConfigKeys
    /// - Returns: 配置信息<String>
    static func value(forKey key: ServerConfigKeys) -> String {
        return UserDefaults.standard.string(forKey: "SERVER_CONFIG_INFO_\(key.rawValue)") ?? ""
    }
    
    /// 获取所有服务器配置信息
    /// - Returns: Array<String>
    static func valuesArray() -> Array<String> {
        let values = [
            ServerConfigInfo.value(forKey: .address),               // 服务器地址
            ServerConfigInfo.value(forKey: .port),                  // 服务器端口
            ServerConfigInfo.value(forKey: .sipUri),                // SIP URI
            ServerConfigInfo.value(forKey: .udpPort),               // UDP 端口
            ServerConfigInfo.value(forKey: .tlsPort),               // TLS 端口
            ServerConfigInfo.value(forKey: .srtp),                  // SRTP 加密
            ServerConfigInfo.value(forKey: .transport),             // 传输模式
            ServerConfigInfo.value(forKey: .bfcp),                  // BFCP 演示传输模式
            ServerConfigInfo.value(forKey: .priorityType),          // 配置的优先级
            ServerConfigInfo.value(forKey: .tunnel),                // 安全隧道使用模式
            ServerConfigInfo.value(forKey: .smSecurity),            // 国密
            ServerConfigInfo.value(forKey: .tlsCompatibility),      // TLS兼容模式
            ServerConfigInfo.value(forKey: .httpsPort)
        ]
        return values
    }
}
