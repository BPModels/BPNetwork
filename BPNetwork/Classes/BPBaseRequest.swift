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

protocol BPRequest {
    var method: BPHTTPMethod { get }
    var header: [String : String] { get }
    var parameters: [String : Any?]? { get }
    var url: URL { get }
    var path: String { get }
    /// Get 请求的参数
    var getTypeParameter: String  { get }
}

extension BPRequest {

    public var header: [String : String] {
//        let uniqueId = UIDevice.IDFA == "00000000-0000-0000-0000-000000000000" ? UIDevice.IDFV ?? "" : UIDevice.IDFA
        let _header = ["Content-Type"   : "application/json",
                       "Connection"     : "keep-alive",
                       "token"          : "BPUserModel.share.token",
                       "From-Type"      : "2",// iOS
                       "BP-OS-VERSION"  : "UIDevice.OSVersion",
                       "BP-APP-VERSION" : "Bundle.appVersion",
                       "BP-APP-BUILD"   : "Bundle.appBuild",
                       "BP-CHANNEL-ID"  : "AppStore",
                       "BP-CLIENT-ID"   : "100",
                       "BP-MODEL"       : "UIDevice.deviceName",
                       "BP-TIMESTAMP"   : "(Int(Date().timeIntervalSince1970))",
                       "org_id"         : "(BPUserModel.share.organizationId ?? 0)",
                       "project_id"     : "(BPUserModel.share.projectId ?? 0)",
                       "unique_id"      : "uniqueId"
        ]
        
        return _header
    }

    public var parameters: [String : Any?]? {
        return nil
    }
    
    public var getTypeParameter: String {
        return ""
    }

    public var baseURL: URL {
        return URL(string: currentEnv.api)!
    }

    public var method: BPHTTPMethod {
        return .get
    }

    public var url: URL {
        var baseUrlStr = baseURL.absoluteString + path
        if method == .get || method == .put{
            baseUrlStr += "/" + getTypeParameter
        }
        baseUrlStr = baseUrlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: baseUrlStr)!
    }

    public var path: String { return "" }
}

