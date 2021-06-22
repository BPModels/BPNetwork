//
//  BPNetworkConfig.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation
import Alamofire

public struct BPNetworkConfig {
    
    public static var share = BPNetworkConfig()
    
    /// 域名
    public var domainApi: String = ""

    /// Web域名
    public var demainWebApi: String = ""
    
    /// 添加的Header参数
    var headerParameters: [String: String] = [:]
    
    /// 更新Header，如果没有则会添加到header
    /// - Parameter parameters: header参数
    public mutating func updateHeader(parameters: [String: String]) {
        self.headerParameters = parameters
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
