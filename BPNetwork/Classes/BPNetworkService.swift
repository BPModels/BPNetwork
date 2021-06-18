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

struct BPNetworkService {
    
    static let `default` = BPNetworkService()
    
    private let maxConcurrentOperationCount: Int = 3
    private let requestTimeOut: TimeInterval     = 60
    
    private var configuration: URLSessionConfiguration {
        let _configuration = URLSessionConfiguration.default
        _configuration.timeoutIntervalForRequest = requestTimeOut
        return _configuration
    }
    
    
    let networkManager = NetworkReachabilityManager()
    private init() {
        let sessionManager:SessionManager = Alamofire.SessionManager.init(configuration: self.configuration)
        sessionManager.session.delegateQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
    
    /// 普通HTTP Request, 支持GET、POST方式
    /// - Parameters:
    ///   - type: 只是定义泛型对象类型,没有其他作用
    ///   - request: 请求对象
    ///   - success: 成功回调的闭包
    ///   - fail: 失败回调的闭包
    @discardableResult
    func request <T> (_ type: T.Type, request: BPRequest, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?, showLoading: Bool = true) -> BPTaskRequestDelegate? where T: BPBaseResopnse {
        guard checkNetwork() else { return nil }
        let parameters = requestParametersReduceValueNil(request.parameters)
        switch request.method {
            case .post:
                var _request = URLRequest(url: request.url)
                _request.httpMethod          = request.method.rawValue
                _request.allHTTPHeaderFields = request.header

                do {
                    if let _parameters = parameters {
                        try _request.httpBody = JSONSerialization.data(withJSONObject: _parameters, options: [])
                    }
                    self.httpPostRequest(type, request: _request, success: { (response, httpStatusCode) in
                        self.handleStatusCodeLogicResponseObject(response, statusCode: httpStatusCode, request: request, success: success, fail: fail)
                    }, fail: { (error) in
                        fail?(error as NSError)
                        //BPRequestLog"【❌Fail】 POST = request url:%@", request.url.absoluteString, parameters?.toJson() ?? "")
                        return nil
                    }, showLoading: showLoading)
                } catch let parseError {
                    fail?(parseError as NSError)
                    //BPRequestLog"【❌Fail】 POST = request url:%@", request.url.absoluteString, parameters?.toJson() ?? "")
                    return nil
                }
            case .get:
                self.httpGetRequest(type, request: request, header: request.header, success: { (response, httpStatusCode) in
                    self.handleStatusCodeLogicResponseObject(response, statusCode: httpStatusCode, request: request, success: success, fail: fail)
                }, fail: { (error) in
                    fail?(error as NSError)
                    //BPRequestLog"【❌Fail】 GET = request url:%@", request.url.absoluteString, parameters?.toJson() ?? "")
                    return nil
                }, showLoading: showLoading)
            case .put:
                self.httpPutRequest(type, request: request, header: request.header, success: { (response, httpStatusCode) in
                    self.handleStatusCodeLogicResponseObject(response, statusCode: httpStatusCode, request: request, success: success, fail: fail)
                }, fail: { (error) in
                    fail?(error as NSError)
                    //BPRequestLog"【❌Fail】 PUT = request url:%@", request.url.absoluteString, parameters?.toJson() ?? "")
                    return nil
                }, showLoading: showLoading)
            default:
                break
        }
        return nil
    }
    
    public func httpDownloadRequestTask <T> (_ type: T.Type, request: BPRequest, localSavePath: String, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> Void where T: BPBaseResopnse {
        
        //        let requestParameters = self.requestParametersReduceValueNil(request.parameters)
        //
        //        Alamofire.download(request.url, method: HTTPMethod(rawValue: request.method.rawValue) ?? .get, parameters: requestParameters, headers: request.handleHeader(parameters: requestParameters, headers: request.header)) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
        //            let path = YYFileManager.share.createPath(documentPath: localSavePath)
        //            return (URL(fileURLWithPath: path), [.removePreviousFile, .createIntermediateDirectories])
        //            }.downloadProgress { (progress) in
        //                DispatchQueue.main.async {
        //                    DDLogInfo("progress.completedUnitCount is \(progress.completedUnitCount)")
        //                }
        //            }.response { (defaultDownloadResponse) in
        //
        //        }
    }
    
    // TODO: ==== POST ====
    @discardableResult
    private func httpPostRequest <T> (_ type: T.Type, request: URLRequest, success:@escaping (_ response: T, _ httpStatusCode: Int) -> Void?, fail: @escaping (_ error: NSError) -> Void?, showLoading: Bool) -> BPTaskRequestDelegate where T: BPBaseResopnse {
        if showLoading {
            //kWindow.showLoading()
        }
        
        let urlStr = request.url?.absoluteString ?? ""
        //BPRequestLogString(format: "【POST】 = request url:%@ params:%@", urlStr, request.allHTTPHeaderFields?.toJson() ?? ""))
        let request = Alamofire.request(request).responseObject { (response: DataResponse<T>) in
            switch response.result {
                case .success(var x):
                    x.response = response.response
                    x.request  = response.request
                    success(x, (response.response?.statusCode) ?? 0)
                    if showLoading {
                        //kWindow.hideLoading()
                    }
                case .failure(let error):
                    fail(error as NSError)
                    //BPRequestLogString(format: "【❌Fail】 POST = request url:%@, error:%@", urlStr, (error as NSError).message))
                    if showLoading {
                        //kWindow.hideLoading()
                    }
            }
        }
        
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: request)
        return taskRequest
    }
    
    // TODO: ==== GET ====
    @discardableResult
    private func httpGetRequest <T>(_ type: T.Type, request: BPRequest, header:[String:String], success:@escaping (_ response: T, _ httpStatusCode: Int) -> Void, fail: @escaping (_ error: NSError) -> Void?, showLoading: Bool) -> BPTaskRequestDelegate where T: BPBaseResopnse {
        if showLoading {
            //kWindow.showLoading()
        }
        
        let urlStr = request.url.absoluteString
        //BPRequestLogString(format: "【Get】 = request url:%@ params:%@", urlStr, request.parameters?.toJson() ?? ""))
        let request = Alamofire.request(request.url, method: HTTPMethod.get, parameters: requestParametersReduceValueNil(request.parameters), encoding: URLEncoding.default, headers: header).responseObject { (response: DataResponse <T>) in
            switch response.result {
                case .success(var x):
                    x.response = response.response
                    x.request  = response.request
                    success(x, (response.response?.statusCode) ?? 0)
                    if showLoading {
                        //kWindow.hideLoading()
                    }
                case .failure(let error):
                    fail(error as NSError)
                    //BPRequestLogString(format: "【❌Fail】 POST = request url:%@, error:%@", urlStr, (error as NSError).message))
                    if showLoading {
                        //kWindow.hideLoading()
                    }
            }
        }
        
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: request)
        return taskRequest
    }
    
    // TODO: ==== PUT ====
    @discardableResult
    private func httpPutRequest <T>(_ type: T.Type, request: BPRequest, header:[String:String], success:@escaping (_ response: T, _ httpStatusCode: Int) -> Void, fail: @escaping (_ error: NSError) -> Void?, showLoading: Bool) -> BPTaskRequestDelegate where T: BPBaseResopnse {
        if showLoading {
            //kWindow.showLoading()
        }
        
        let urlStr = request.url.absoluteString
        //BPRequestLogString(format: "【Get】 = request url:%@ params:%@", urlStr, request.parameters?.toJson() ?? ""))
        let request = Alamofire.request(request.url, method: HTTPMethod.put, parameters: requestParametersReduceValueNil(request.parameters), encoding: URLEncoding.default, headers: header).responseObject { (response: DataResponse <T>) in
            switch response.result {
                case .success(var x):
                    x.response = response.response
                    x.request  = response.request
                    success(x, (response.response?.statusCode) ?? 0)
                    if showLoading {
                        //kWindow.hideLoading()
                    }
                case .failure(let error):
                    fail(error as NSError)
                    //BPRequestLogString(format: "【❌Fail】 POST = request url:%@, error:%@", urlStr, (error as NSError).message))
                    if showLoading {
                        //kWindow.hideLoading()
                    }
            }
        }
        
        let taskRequest: BPTaskRequestDelegate = BPRequestModel(request: request)
        return taskRequest
    }

    
    // TODO: ==== UPLOAD ===
    public func httpUploadRequestTask <T> (_ type: T.Type, request: BPRequest, mimeType: String = "image/jpeg", fileName: String = "photo", success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?, showLoading: Bool = true) -> Void where T: BPBaseResopnse {
        if showLoading {
            //kWindow.showLoading()
        }
        var requestHeader = request.header
        requestHeader["Content-Type"] = "multipart/form-data"
        
        let requestParameters = self.requestParametersReduceValueNil(request.parameters)
        guard var parameters  = requestParameters else { return }
        let urlStr = request.url.absoluteString
        //BPRequestLogString(format: "【Upload】 = request url:%@", urlStr))
        //MARK: 上传
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            var fileData: Any?
            var name: String = ""
            if parameters.keys.contains("file") {
                fileData = parameters["file"]
                name     = "file"
            }
            
            if let _fileData = fileData, _fileData is String {
                multipartFormData.append(URL(fileURLWithPath:(_fileData as! String)), withName: name, fileName: fileName, mimeType: mimeType)
            }else if let _fileData = fileData, fileData is Data {
                multipartFormData.append(_fileData as! Data, withName: name, fileName: fileName, mimeType: mimeType)
            }
            parameters.removeValue(forKey: name)
            
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key )
            }
        }, usingThreshold: UInt64.init(), to: request.url, method: HTTPMethod(rawValue: request.method.rawValue) ?? .post , headers: request.header) { (result) in
            switch result {
                case .success(let upload, _, _):
                    upload.responseObject(completionHandler: { (response: DataResponse <T>) in
                        switch response.result {
                            case .success(let x):
                                self.handleStatusCodeLogicResponseObject(x, statusCode: (response.response?.statusCode) ?? 0, request: request, success: success, fail: fail)
                            case .failure(let error):
                                fail?(error as NSError)
                                //BPRequestLogString(format: "【❌Fail】 POST = request url:%@, error:%@", urlStr, (error as NSError).message))
                        }
                    })
                    if showLoading {
                        //kWindow.hideLoading()
                    }
                case .failure(let error):
                    fail?(error as NSError)
                    //BPRequestLogString(format: "【❌Fail】 POST = request url:%@, error:%@", urlStr, (error as NSError).message))
                    if showLoading {
                        //kWindow.hideLoading()
                    }
            }
        }
    }
    
    /**
     *  请求状态码逻辑处理
     */
    private func handleStatusCodeLogicResponseObject <T> (_ response: T, statusCode: Int, request: BPRequest, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> Void where T: BPBaseResopnse {
//        let baseResponse       = response as BPBaseResopnse
//        let responseStatusCode = baseResponse.statusCode
//        let urlStr             = request.url.absoluteString
//        switch responseStatusCode {
//        case 200:
//            success?(response)
//            if let responseData: BPStructResponse = baseResponse as? BPStructResponse<T> {
//                //BPRequestLogString(format: "【Success】 request url: %@, respnseObject: %@", urlStr, responseData.data?.toJSON() ?? ""))
//            }
//        case 10101004:
//            /// Token已失效
//            BPAlertManager.share.oneButton(title: "提示", description: "用户信息已失效，请重新登录", buttonName: "好的") {
//                BPUserModel.share.logoutAction()
//            }.show()
//        case 10101016:
//            /// 用户不存在
//            BPAlertManager.share.oneButton(title: "提示", description: "用户信息已失效，请重新登录", buttonName: "好的") {
//                BPUserModel.share.logoutAction()
//            }.show()
//        case 10101024:
//            /// 该账号已在其他移动设备登录
//            BPAlertManager.share.oneButton(title: "提示", description: "该账号已在其他移动设备登录，请注意账号安全。", buttonName: "重新登录") {
//                BPUserModel.share.logoutAction()
//            }.show()
//        default:
            if let errorMsg = baseResponse.statusMessage {
                if errorMsg == "登录状态已过期" {
                    /// 登录状态已过期
                    BPAlertManager.share.oneButton(title: "提示", description: "用户信息已失效，请重新登录", buttonName: "好的") {
                        BPUserModel.share.logoutAction()
                    }.show()
                } else {
                    fail?(NSError(domain: "com.tenant.httpError", code: responseStatusCode, userInfo: [NSLocalizedDescriptionKey : errorMsg]))
                    //BPRequestLogString(format: "【❌Fail】 POST = request url:%@, error:%@", urlStr, errorMsg))
                }
            }
//        }
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
    
    // MARK: ==== Tools ====
    private func checkNetwork() -> Bool {
        guard !isReachable else {
            return true
        }
        if !isAuth {
            BPAuthorizationManager.share.showAlert(type: .network)
            //BPLog("【网络权限被关闭】")
        }
        return false
    }
}
