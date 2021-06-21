//
//  BPNetworkGlobal.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation
import Alamofire


/// 上传文件Key
public let kUploadFilesKey = "uploadFileKey"
/// 网络授权变化
public var kNetworkAuth = NSNotification.Name.ZYNetworkAccessibityChanged

/// 获取当前环境
public var currentEnv: BPEnvType {
    get {
        #if DEBUG
        let envInt = UserDefaults.standard.integer(forKey: "bp_env")
        guard let env = BPEnvType(rawValue: envInt) else {
            return .test
        }
        return env
        #else
        return .release
        #endif
    }
    set {
        UserDefaults.standard.setValue(newValue.rawValue, forKey: "bp_env")
    }
}

/// 域名
public var domainApi: String {
    get {
        return currentEnv.api
    }
}

/// 是否有网络权限
var isAuth: Bool {
    let status = BPNetworkAuthManager.default.state
    return status != .restricted
}

/// 是否有网络
public var isReachable: Bool {
    get {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

/// 是否是蜂窝网络,WWAN网络
/// WWAN（Wireless Wide Area Network，无线广域网）
public var isReachableOnWWAN: Bool {
    get {
        return NetworkReachabilityManager()?.isReachableOnWWAN ?? false
    }
}

/// 是否是Wi-Fi或者以太网网络
public var isReachableOnEthernetOrWiFi: Bool {
    get {
        return NetworkReachabilityManager()?.isReachableOnEthernetOrWiFi ?? false
    }
}

//let networkManager = NetworkReachabilityManager()
