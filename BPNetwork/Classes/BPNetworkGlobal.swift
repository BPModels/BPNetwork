//
//  BPNetworkGlobal.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation
import Alamofire
import CoreTelephony

/// 上传文件Key
public let kUploadFilesKey = "uploadFileKey"
/// 网络授权变化
public var kNetworkAuth = NSNotification.Name.ZYNetworkAccessibityChanged

/// 是否有网络权限
public var isAuth: Bool {
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
        return NetworkReachabilityManager()?.isReachableOnCellular ?? false
    }
}

/// 是否是Wi-Fi或者以太网网络
public var isReachableOnEthernetOrWiFi: Bool {
    get {
        return NetworkReachabilityManager()?.isReachableOnEthernetOrWiFi ?? false
    }
}

/// 获得网络类型描述
public var networkType: String {
    get {
        if isReachableOnWWAN {
            let info = CTTelephonyNetworkInfo()
            if let currentRadioAccessTechnology = info.currentRadioAccessTechnology {
                if #available(iOS 14.1, *) {
                    if currentRadioAccessTechnology == CTRadioAccessTechnologyNR || currentRadioAccessTechnology == CTRadioAccessTechnologyNRNSA {
                        return "5G"
                    }
                }
                switch currentRadioAccessTechnology {
                case CTRadioAccessTechnologyGPRS,
                     CTRadioAccessTechnologyCDMA1x:
                    return "2G"
                case CTRadioAccessTechnologyEdge:
                    return "2.5G"
                case CTRadioAccessTechnologyWCDMA,
                     CTRadioAccessTechnologyHSUPA,
                     CTRadioAccessTechnologyCDMAEVDORev0,
                     CTRadioAccessTechnologyCDMAEVDORevA,
                     CTRadioAccessTechnologyCDMAEVDORevB:
                    return "3G"
                case CTRadioAccessTechnologyHSDPA,
                     CTRadioAccessTechnologyeHRPD:
                    return "3.5G"
                case CTRadioAccessTechnologyLTE:
                    return "4G"
                default:
                    return "Unknown G"
                }
            }

        } else if isReachableOnEthernetOrWiFi {
            return "WiFi"
        }
        return "Unknown"
    }
}
