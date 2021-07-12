//
//  BPBaseResopnse.swift
//  BaseProject
//
//  Created by 沙庭宇 on 2019/8/6.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol BPBaseResopnse: Mappable {
    /// 状态码
    var statusCode: Int { get }
    /// 状态消息
    var statusMessage: String? { get }
    /// 警告消息
    var warningDesc: String? { get }
    /// 返回对象
    var response: URLResponse? { set get }
    /// 请求对象
    var request: URLRequest? { set get }
}

/// 数据为空时使用
public struct BPStructNilResponse: BPBaseResopnse {
    public var statusCode: Int = 0
    public var statusMessage: String?
    public var warningDesc: String?
    public var response: URLResponse?
    public var request: URLRequest?
    
    /// 根据类型返回具体对象
    public var data:Any?
    /// 返回后台完整Data数据
    public var dataAny: Any?
    
    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        data      <- map["data"]
        dataAny   <- map["data"]
    }
}
/// 返回对象时使用
public struct BPStructResponse<T: Mappable> : BPBaseResopnse {
    
    public var response: URLResponse?
    public var request: URLRequest?

    private var status: Int = 0
    private var message: String?
    private var warning: String?

    /// 根据类型返回具体对象
    public var data:T?
    /// 返回后台完整Data数据
    public var dataAny: Any?

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        message   <- map["msg"]
        warning   <- map["warning"]
        data      <- map["data"]
        status    <- map["code"]
        dataAny   <- map["data"]
    }
}

extension BPStructResponse {
    public var statusCode: Int {
        return status
    }

    public var statusMessage: String? {
        return message
    }

    public var warningDesc: String? {
        return warning
    }
}

/// 返回列表时使用
public struct BPStructDataArrayResponse<T: Mappable> : BPBaseResopnse {

    public var response: URLResponse?
    public var request: URLRequest?

    private var status: Int = 0
    private var message: String?
    private var warning: String?

    public var dataArray:[T]?

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        status    <- map["code"]
        message   <- map["msg"]
        warning   <- map["warning"]
        dataArray <- map["data"]
    }

}

extension BPStructDataArrayResponse {

    public var statusCode: Int {
        return status
    }

    public var statusMessage: String? {
        return message
    }

    public var warningDesc: String? {
        return warning
    }
}
