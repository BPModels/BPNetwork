//
//  BPNetworkService.swift
//  BaseProject
//
//  Created by 沙庭宇 on 2019/8/6.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

/// 网络请求回调协议
public protocol BPNetworkDelegate: NSObjectProtocol {
    /// 处理状态码（如果返回true，则不调用success或fail回调）
    /// - Parameter code: 状态吗
    /// - Returns: 是否已处理
    func handleStatusCode(code: Int) -> Bool
    /// 处理错误内容（如果返回true，则不调用success或fail回调）
    /// - Parameter message: 错误内容
    /// - Returns: 是否已处理
    func handleErrorMessage(message: String) -> Bool
    /// 无网络
    func noNetwork()
    /// 无网络权限
    func noAuthNetwork()
}

public struct BPNetworkService {
    
    public static var `default` = BPNetworkService()
    
    public weak var delegate: BPNetworkDelegate?
    
    // MARK: ==== Request ====
    /// 普通HTTP Request, 支持GET、POST、PUT等方式
    /// - Parameters:
    ///   - type: 定义泛型对象类型
    ///   - request: 继承BPRequest的请求对象
    ///   - success: 成功回调的闭包
    ///   - fail: 失败回调的闭包
    /// - Returns: 返回请求体，支持取消请求
    @discardableResult
    public func request <T> (_ type: T.Type, request: BPRequest, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        // 检测网络
        guard checkNetwork() else { return nil }
        switch request.method {
        case .post:
            // 发起请求，并返回请求体
            return self.httpPostRequest(type, request: request, success: { (response, httpStatusCode) in
                // 处理Code
                self.handleStatusCode(response, request: request, success: success, fail: fail)
            }, fail: { (error) in
                fail?(error as NSError)
            })
        case .get:
            return self.httpGetRequest(type, request: request, success: { (response, httpStatusCode) in
                self.handleStatusCode(response, request: request, success: success, fail: fail)
            }, fail: { (error) in
                fail?(error as NSError)
                return nil
            })
        case .put:
            return self.httpPutRequest(type, request: request, success: { (response, httpStatusCode) in
                self.handleStatusCode(response, request: request, success: success, fail: fail)
            }, fail: { (error) in
                fail?(error as NSError)
                return nil
            })
        default:
            break
        }
        return nil
    }
    
    
    
    // TODO: ---- POST ----
    @discardableResult
    private func httpPostRequest <T> (_ type: T.Type, request: BPRequest, success:@escaping (_ response: T, _ httpStatusCode: Int) -> Void, fail: @escaping (_ error: NSError) -> Void) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        // 校验url
        guard let url = request.url else {
            return nil
        }
        // 校验参数（移除Value为空的参数）
        let parameters = requestParametersReduceValueNil(request.parameters)
        // 添加Header
        var _request = URLRequest(url: url)
        _request.httpMethod          = request.method.rawValue
        _request.allHTTPHeaderFields = request.header
        do {
            // 添加参数
            if let _parameters = parameters {
                try _request.httpBody = JSONSerialization.data(withJSONObject: _parameters, options: [])
            }
            // 发起请求
            let request = AF.request(_request).responseObject { (response: DataResponse<T, AFError>) in
                switch response.result {
                case .success(var x):
                    x.response = response.response
                    x.request  = response.request
                    success(x, (response.response?.statusCode) ?? 0)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
            
            // 返回请求体
            let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: request)
            return taskRequest
        } catch let error {
            fail(error as NSError)
            return nil
        }
    }
    
    // TODO: ---- GET ----
    @discardableResult
    private func httpGetRequest <T>(_ type: T.Type, request: BPRequest, success:@escaping (_ response: T, _ httpStatusCode: Int) -> Void, fail: @escaping (_ error: NSError) -> Void?) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        // 校验url
        guard let url = request.url else {
            return nil
        }
        // 校验参数（移除Value为空的参数）
        let parameters = requestParametersReduceValueNil(request.parameters)
        // 发起请求
        let task = AF.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: HTTPHeaders(request.header)).responseObject { (response: DataResponse <T, AFError>) in
            switch response.result {
            case .success(var x):
                x.response = response.response
                x.request  = response.request
                success(x, (response.response?.statusCode) ?? 0)
            case .failure(let error):
                fail(error as NSError)
            }
        }
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: task)
        return taskRequest
    }
    
    // TODO: ---- PUT ----
    @discardableResult
    private func httpPutRequest <T>(_ type: T.Type, request: BPRequest, success:@escaping (_ response: T, _ httpStatusCode: Int) -> Void, fail: @escaping (_ error: NSError) -> Void?) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        // 校验url
        guard let url = request.url else {
            return nil
        }
        // 校验参数（移除Value为空的参数）
        let parameters = requestParametersReduceValueNil(request.parameters)
        // 发起请求
        let task = AF.request(url, method: HTTPMethod.put, parameters: parameters, encoding: URLEncoding.default, headers: HTTPHeaders(request.header)).responseObject { (response: DataResponse <T, AFError>) in
            switch response.result {
            case .success(var x):
                x.response = response.response
                x.request  = response.request
                success(x, (response.response?.statusCode) ?? 0)
            case .failure(let error):
                fail(error as NSError)
            }
        }
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: task)
        return taskRequest
    }
    
    // MARK: ==== UPLOAD ====
    /// 上传文件，支持多个文件（参数附件必须是BPFileModel类型，Key是“uploadFileKey”，或者用常量kUploadFilesKey）
    /// - Parameters:
    ///   - type: 对象类型
    ///   - request: 请求体
    ///   - uploadProgress: 上传进度回调
    ///   - success: 成功回调
    ///   - fail: 失败回调
    /// - Returns: 返回请求体，支持取消请求
    @discardableResult
    public func httpUploadRequestTask <T> (_ type: T.Type, request: BPRequest, uploadProgress: ((Progress) -> Void)?, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        // 校验url
        guard let url = request.url else {
            return nil
        }
        // 校验参数（移除Value为空的参数）
        let parameters = self.requestParametersReduceValueNil(request.parameters)
        // 添加Header
        var header = request.header
        header["Content-Type"] = "multipart/form-data"
        // 发起请求
        let task = AF.upload(multipartFormData: { multipartFormData in
            guard let model = parameters?[kUploadFilesKey] as? BPUpLoadFileModel else {
                return
            }
            // 批量上传的文件
            model.files.forEach { dataTuple in
                let name = dataTuple.0
                let data = dataTuple.1
                multipartFormData.append(data, withName: "files", fileName: name, mimeType: "application/octet-stream; charset=utf-8")
            }
            /// 单个上传的文件
            if let dataTuple = model.file {
                let name = dataTuple.0
                let data = dataTuple.1
                multipartFormData.append(data, withName: "file", fileName: name, mimeType: "application/octet-stream; charset=utf-8")
            }
            /// 批量上传的文件大小
            if let size = model.fileSize, let data = "\(size)".data(using: .utf8) {
                multipartFormData.append(data, withName: "fileSize")
            }
            /// 文件夹ID
            if let folderId = model.folderId, let data = "\(folderId)".data(using: .utf8) {
                multipartFormData.append(data, withName: "folderId")
            }
            /// 组织ID
            if let orgId = model.orgId, let data = "\(orgId)".data(using: .utf8) {
                multipartFormData.append(data, withName: "orgId")
            }
            /// 项目ID
            if let projectId = model.projectId, let data = "\(projectId)".data(using: .utf8) {
                multipartFormData.append(data, withName: "projectId")
            }
            /// 关联ID
            if let relationId = model.relationId, let data = "\(relationId)".data(using: .utf8) {
                multipartFormData.append(data, withName: "relationId")
            }
            /// 关联ID
            if let relationType = model.relationType, let data = "\(relationType)".data(using: .utf8) {
                multipartFormData.append(data, withName: "relationType")
            }
            /// 关联ID
            if let type = model.type, let data = "\(type)".data(using: .utf8) {
                multipartFormData.append(data, withName: "type")
            }
        }, to: url, usingThreshold: UInt64(), method: HTTPMethod(rawValue: request.method.rawValue) , headers: HTTPHeaders(header), interceptor: nil, fileManager: FileManager.default).uploadProgress { progress in
            uploadProgress?(progress)
        }.responseObject { (response: DataResponse<T, AFError>) in
            switch response.result {
            case .success(let x):
                self.handleStatusCode(x, request: request, success: success, fail: fail)
            case .failure(let error):
                fail?(error as NSError)
            }
        }
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: task)
        return taskRequest
    }
    
    // MARK: ==== Download ====
    /// 下载文件
    /// - Parameters:
    ///   - request: 请求体
    ///   - downloadProgress: 下载进度回调
    ///   - success: 下载成功回调
    ///   - fail: 下载失败回调
    @discardableResult
    public func httpDownloadRequestTask (request: BPRequest, downloadProgress: ((Progress) -> Void)?, success: ((_ response: AFDownloadResponse<Data>) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate? {
        // 校验url
        guard let url = request.url else {
            return nil
        }
        // 配置下载策略（全局搜索）
        let desctination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .allDomainsMask)
        let task = AF.download(url, to: desctination).downloadProgress(queue: DispatchQueue.global()) { progress in
            // 下载进度
            downloadProgress?(progress)
        }.validate().responseData(queue: DispatchQueue.global()) { data in
            // 下载完成
            success?(data)
        }
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: task)
        return taskRequest
    }
    
    // MARK: ==== Tools ====
    
    /// 检查网络是否正常
    /// - Returns: 是否正常
    private func checkNetwork() -> Bool {
        guard isAuth else {
            self.delegate?.noAuthNetwork()
            return false
        }
        guard isReachable else {
            self.delegate?.noNetwork()
            return false
        }
        return true
    }
    
    /// 请求状态码逻辑处理
    /// - Parameters:
    ///   - response: 请求返回对象
    ///   - request: 请求对象
    ///   - success: 成功回调
    ///   - fail: 失败回调
    private func handleStatusCode <T> (_ response: T, request: BPRequest, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> Void where T: BPBaseResopnse {
        let baseResponse       = response as BPBaseResopnse
        let responseStatusCode = baseResponse.statusCode
        let processedCode = self.delegate?.handleStatusCode(code: responseStatusCode) ?? false
        // 发送通知
        NotificationCenter.default.post(name: Notification.Name("kBPSendRequestLog"), object: nil, userInfo: ["request" : request, "response" : response])
        // 如果调用方未处理状态码
        if !processedCode {
            if responseStatusCode == 200 {
                success?(response)
            } else {
                if let errorMsg = baseResponse.statusMessage {
                    let processedMsg = self.delegate?.handleErrorMessage(message: errorMsg) ?? false
                    // 如果调用方未处理错误内容
                    if !processedMsg {
                        // 通过回调返回错误信息
                        fail?(NSError(domain: "com.tenant.httpError", code: responseStatusCode, userInfo: [NSLocalizedDescriptionKey : errorMsg]))
                    }
                }
            }
        }
    }
    
    /// 确保参数key对应的Value不为空
    private func requestParametersReduceValueNil(_ requestionParameters: [String : Any?]?) -> [String : Any]? {
        guard let parameters = requestionParameters else {
            return nil
        }
        let _parameters = parameters.reduce([String : Any]()) { (dict, e) in
            guard let value = e.1 else { return dict }
            var dict = dict
            dict[e.0] = value
            return dict
        }
        return _parameters
    }
}
