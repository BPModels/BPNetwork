//
//  BPUploadFilesModel.swift
//  BPNetwork
//
//  Created by samsha on 2021/7/12.
//

import Foundation
import ObjectMapper

/// 通用上传文件模型
public struct BPUpLoadFileModel: Mappable {
    
    /// 批量上传的文件
    public var files: NSMutableData?
    /// 批量上传的文件大小
    public var fileSize: Double?
    /// 文件夹ID
    public var folderId: UInt64?
    /// 组织ID
    public var orgId: UInt64?
    /// 项目ID
    public var projectId: UInt64?
    /// 关联ID
    public var relationId: UInt64?
    /// 关联类型
    public var relationType: Int?
    /// 单个上传的文件
    public var file: Data?
    /// 上传文件的类型
    /// 图片  0 ;营业执照 1 ;身份证 2 ;证书 3 ;日志文件（压缩格式：zip） 4
    public var type: Int?
//    /// 文件名，不包括后缀
//    public var name: String   = ""
//    /// 文件后缀名
//    public var suffix: String = ""
//    /// 全名+后缀（如赋值则会自动更改name和suffix）
//    public var fileName: String {
//        get {
//            return name + suffix
//        }
//        set {
//            if let dotIndex = newValue.lastIndex(of: ".") {
//                self.name   = String(newValue[newValue.startIndex..<dotIndex])
//                self.suffix = String(newValue[dotIndex..<newValue.endIndex])
//                self.suffix.removeFirst()
//            }
//        }
//    }
    
    public init() {}
    public init?(map: Map) {}
    public mutating func mapping(map: Map) {}
}

