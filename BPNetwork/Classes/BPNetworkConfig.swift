//
//  BPNetworkConfig.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation

public struct BPNetworkConfig {
    
    /// 添加的Header参数
    var headerParameters: [String: String] = [:]
    
    public static let share = BPNetworkConfig()
    
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
}
