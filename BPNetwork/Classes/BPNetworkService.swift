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
    /// 请求前
    func requestBefore(request: BPRequest)
    /// 请求成功后
    func requestScuess(response: BPBaseResopnse?, request: BPRequest)
    /// 请求失败后
    func requestFail(request: BPRequest, error: Error)
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

/// 通用上传文件模型
public struct BPFileModel {
    public var data: Data
    public var mimeType: String = ""
    /// 文件名，不包括后缀
    public var name: String     = ""
    /// 文件后缀名
    public var suffix: String   = ""
    /// 全名+后缀（如赋值则会自动更改name和suffix）
    public var fileName: String {
        get {
            return name + suffix
        }
        set {
            if let dotIndex = newValue.lastIndex(of: ".") {
                self.name   = String(newValue[newValue.startIndex..<dotIndex])
                self.suffix = String(newValue[dotIndex..<newValue.endIndex])
                self.suffix.removeFirst()
            }
        }
    }
}

public struct BPNetworkService {
    
    static var `default` = BPNetworkService()
    
    public weak var delegate: BPNetworkDelegate?
    
    /// 最大请求数量
    var maxConcurrentOperationCount: Int = 3
    /// 请求超时时间，单位秒
    var requestTimeOut: TimeInterval     = 10
    
    private var configuration: URLSessionConfiguration {
        let _configuration = URLSessionConfiguration.default
        _configuration.timeoutIntervalForRequest = requestTimeOut
        return _configuration
    }

    private init() {
        let sessionManager:SessionManager = Alamofire.SessionManager.init(configuration: self.configuration)
        sessionManager.session.delegateQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
    
    /// 普通HTTP Request, 支持GET、POST、PUT等方式
    /// - Parameters:
    ///   - type: 定义泛型对象类型
    ///   - request: 继承BPRequest的请求对象
    ///   - success: 成功回调的闭包
    ///   - fail: 失败回调的闭包
    ///   - showLoading: 是否显示Loading动画
    /// - Returns: 返回请求体，支持取消请求
    @discardableResult
    public func request <T> (_ type: T.Type, request: BPRequest, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        // 检测网络
        guard checkNetwork() else { return nil }
        // 通知外层开始请求
        self.delegate?.requestBefore(request: request)
        switch request.method {
            case .post:
                // 发起请求，并返回请求体
                return self.httpPostRequest(type, request: request, success: { (response, httpStatusCode) in
                    self.delegate?.requestScuess(response: response, request: request)
                    // 处理Code
                    self.handleStatusCode(response, request: request, success: success, fail: fail)
                }, fail: { (error) in
                    fail?(error as NSError)
                    self.delegate?.requestFail(request: request, error: error)
                })
            case .get:
                return self.httpGetRequest(type, request: request, success: { (response, httpStatusCode) in
                    self.delegate?.requestScuess(response: response, request: request)
                    self.handleStatusCode(response, request: request, success: success, fail: fail)
                }, fail: { (error) in
                    fail?(error as NSError)
                    self.delegate?.requestFail(request: request, error: error)
                    return nil
                })
            case .put:
                return self.httpPutRequest(type, request: request, success: { (response, httpStatusCode) in
                    self.delegate?.requestScuess(response: response, request: request)
                    self.handleStatusCode(response, request: request, success: success, fail: fail)
                }, fail: { (error) in
                    fail?(error as NSError)
                    self.delegate?.requestFail(request: request, error: error)
                    return nil
                })
            default:
                break
        }
        return nil
    }
    
  
    
    // TODO: ==== Request ====
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
            let request = Alamofire.request(_request).responseObject { (response: DataResponse<T>) in
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
            self.delegate?.requestFail(request: request, error: error)
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
        let task = Alamofire.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: request.header).responseObject { (response: DataResponse <T>) in
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
        let task = Alamofire.request(url, method: HTTPMethod.put, parameters: parameters, encoding: URLEncoding.default, headers: request.header).responseObject { (response: DataResponse <T>) in
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
    
    // TODO: ==== UPLOAD ====
    /// 上传文件，支持多个文件（参数附件必须是BPFileModel类型，Key是“uploadFileKey”，或者用常量kUploadFilesKey）
    /// - Parameters:
    ///   - type: 对象类型
    ///   - request: 请求体
    ///   - uploadProgress: 上传进度回调
    ///   - success: 成功回调
    ///   - fail: 失败回调
    /// - Returns: 返回请求体，支持取消请求
    public func httpUploadRequestTask <T> (_ type: T.Type, request: BPRequest, uploadProgress: ((Progress) -> Void)?, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> Void where T: BPBaseResopnse {
        // 校验url
        guard let url = request.url else {
            return
        }
        // 校验参数（移除Value为空的参数）
        let parameters = self.requestParametersReduceValueNil(request.parameters)
        // 添加Header
        var header = request.header
        header["Content-Type"] = "multipart/form-data"
        // 通知外层开始请求
        self.delegate?.requestBefore(request: request)
        // 发起请求
        Alamofire.upload(multipartFormData: { multipartFormData in
            let fileModelList = parameters?[kUploadFilesKey] as? [BPFileModel]
            // 添加所有文件
            fileModelList?.forEach({ fileModel in
                multipartFormData.append(fileModel.data, withName: fileModel.name, fileName: fileModel.fileName, mimeType: fileModel.mimeType)
            })
        }, usingThreshold: UInt64(), to: url, method: HTTPMethod(rawValue: request.method.rawValue) ?? .post, headers: header) { result in
            switch result {
            case .success(let uploader, _, _):
                // 添加进度回调
                uploader.uploadProgress(queue: DispatchQueue.global()) { progress in
                    uploadProgress?(progress)
                    if progress.isFinished {
                        self.delegate?.requestScuess(response: nil, request: request)
                    }
                }
                // 添加完成回调
                uploader.responseObject(completionHandler: { (response: DataResponse <T>) in
                    switch response.result {
                        case .success(let x):
                            self.handleStatusCode(x, request: request, success: success, fail: fail)
                        case .failure(let error):
                            fail?(error as NSError)
                            self.delegate?.requestFail(request: request, error: error)
                    }
                })
            case .failure(let error):
                fail?(error as NSError)
                self.delegate?.requestFail(request: request, error: error)
            }
        }
    }
    
    // TODO: ==== Download ====
    /// 下载文件
    /// - Parameters:
    ///   - request: 请求体
    ///   - downloadProgress: 下载进度回调
    ///   - success: 下载成功回调
    ///   - fail: 下载失败回调
    public func httpDownloadRequestTask (request: BPRequest, downloadProgress: ((Progress) -> Void)?, success: ((_ response: DownloadResponse<Data>) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> Void {
        // 校验url
        guard let url = request.url else {
            return
        }
        // 配置下载策略（全局搜索）
        let desctination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .allDomainsMask)
        Alamofire.download(url, to: desctination).downloadProgress(queue: DispatchQueue.global()) { progress in
            // 下载进度
            downloadProgress?(progress)
        }.validate().responseData(queue: DispatchQueue.global()) { data in
            // 下载完成
            success?(data)
        }
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
