//
//  BPEnvType.swift
//  BPNetwork
//
//  Created by samsha on 2021/6/18.
//

import Foundation

public enum BPEnvType: Int {
    case dev     = 1
    case test    = 2
    case pre     = 3
    case release = 4
    case debug   = 5
    
    public var api: String {
        get {
            switch self {
            case .dev:
                return "http://192.168.1.155:9080/"
            case .test:
                return "http://121.36.55.155:8081/api/"
            case .pre:
                return "http://121.36.23.209/api/"
            case .release:
                return "http://121.36.23.209/api/"
            case .debug:
                return UserDefaults.standard.object(forKey: "kCustomServerDomain") as? String ?? ""
            }
        }
    }
    
    public var webApi: String {
        switch self {
        case .dev:
            return "http://192.168.1.155:8081/"
        case .test:
            return "http://121.36.55.155:8081/"
        case .pre:
            return "http://121.36.23.209/"
        case .release:
            return "http://121.36.23.209/"
        case .debug:
            return UserDefaults.standard.object(forKey: "kCustomWebDomain") as? String ?? ""
        }
    }
    
    public var title: String {
        get {
            switch self {
            case .dev:
                return "开发环境"
            case .test:
                return "测试环境"
            case .pre:
                return "预发环境"
            case .release:
                return "正式环境"
            case .debug:
                return "自定义"
            }
        }
    }
}
