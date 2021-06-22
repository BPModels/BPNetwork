//
//  BPNetworkConfig.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation
import Alamofire

public struct BPNetworkConfig {
    
    public static let share = BPNetworkConfig()
    
    /// 域名
    public var domainApi: String = ""

    /// Web域名
    public var demainWebApi: String = ""
    
    /// 添加的Header参数
    var headerParameters: [String: String] = [:]
    
    /// 添加Header，如果没有则会添加到header
    /// - Parameter parameters: header参数
    public mutating func registerHeader(parameters: [String: String]) {
        self.headerParameters = parameters
    }
    
    /// 更新Header参数
    /// - Parameters:
    ///   - key: 参数Key
    ///   - value: 参数Value
    public mutating func updateHeader(key: String, value: String) {
        headerParameters[key] = value
    }
    
    /// 开启网络监听
    public func startNetworkListener(update: ((NetworkReachabilityManager.NetworkReachabilityStatus) ->Void)?) {
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { (status: NetworkReachabilityManager.NetworkReachabilityStatus) in
            update?(status)
        })
    }
    
    /// 关闭网络监听
    public func stopNetworkListener() {
        NetworkReachabilityManager.default?.stopListening()
    }
    
}
