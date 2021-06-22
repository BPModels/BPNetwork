//
//  BPBaseRequest.swift
//  BaseProject
//
//  Created by 沙庭宇 on 2019/8/6.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation
import UIKit

public enum BPHTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

/// 请求对象，具体业务类可以实现具体值
public protocol BPRequest {
    
    /// 请求方法类型
    var method: BPHTTPMethod { get }
    
    /// 请求头
    var header: [String : String] { get }
    
    /// 请求POST参数
    var parameters: [String : Any?]? { get }
    
    /// 请求GET参数
    var getTypeParameter: String  { get }
    
    /// 域名地址
    var url: URL? { get }
    
    /// 路由地址
    var path: String { get }
    
}

/// 默认实现
public extension BPRequest {

    var header: [String : String] {
        var _header: [String: String] = [
                        "Content-Type"   : "application/json",
                        "Connection"     : "keep-alive",
                        "BP-CHANNEL-ID"  : "AppStore",
                        "BP-TIMESTAMP"   : "\(Date().timeIntervalSince1970)"
        ]
        // 增加自定义Header参数
        let otherHeader = BPNetworkConfig.share.headerParameters
        otherHeader.forEach { (key: String, value: String) in
            _header[key] = value
        }
        return _header
    }

    var parameters: [String : Any?]? {
        return nil
    }
    
    var getTypeParameter: String {
        return ""
    }

    var method: BPHTTPMethod {
        return .get
    }

    var url: URL? {
        var urlStr = BPNetworkConfig.share.domainApi + path
        if method == .get || method == .put {
            urlStr += "/" + getTypeParameter
        }
        guard let _urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let _url = URL(string: _urlStr) else {
            return nil
        }
        return _url
    }

    var path: String { return "" }
}

