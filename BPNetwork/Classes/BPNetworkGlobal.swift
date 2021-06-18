//
//  BPNetworkGlobal.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation

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
