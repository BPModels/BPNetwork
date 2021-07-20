# BPNetwork



[![Swift](https://img.shields.io/badge/Swift-%3E=5.0-Orange?style=flat-square)](https://img.shields.io/badge/Swift-%3E=5.0-Orange?style=flat-square)

[![Platform](https://img.shields.io/badge/Platforms-iOS-Green?style=flat-square)](https://img.shields.io/badge/Platforms-iOS-Green?style=flat-square)




## Example

> To run the example project, clone the repo, and run `pod install` from the Example directory first.



## Requirements



## Installation



BPFile is available through [CocoaPods](https://cocoapods.org). To install

it, simply add the following line to your Podfile:



```ruby
pod 'BPNetwork'
```


## Author



TestEngineerFish, 916878440@qq.com



---

## 使用

网络请求前需要先设置域名

```swift
    /// 域名
BPNetworkConfig.share.domainApi    = "http://www.baidu.com"
    /// Web域名
BPNetworkConfig.share.demainWebApi = "http://www.baidu.com"
```

请求的头文件更新

```swift
        /// 更新Header，如果没有则会添加到header
    /// - Parameter parameters: header参数
    public mutating func updateHeader(parameters: [String: String])
```

网络请求 **BPNetworkService**

> Type类型需要继承自 **BPBaseResopnse**，一般对象使用 **BPStructResponse<Model>.self**, 数组对象使用 **BPStructDataArrayResponse<Model>.self**, 需要直接获取值，或者不需要返回值时 **BPStructNilResponse.self** 
>
> 其中 **Model** 需要替换为继承自 **Mappable** 的对象

```swift
    // MARK: ==== GET、POST、PUT ====
    /// 普通HTTP Request, 支持GET、POST、PUT等方式
    /// - Parameters:
    ///   - type: 定义泛型对象类型
    ///   - request: 继承BPRequest的请求对象
    ///   - success: 成功回调的闭包
    ///   - fail: 失败回调的闭包
    /// - Returns: 返回请求体，支持取消请求
    @discardableResult
    public func request <T> (_ type: T.Type, request: BPRequest, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate? where T: BPBaseResopnse

    // MARK: ==== Upload ====
    /// 上传文件，支持多个文件（参数附件必须是BPFileModel类型，Key是“uploadFileKey”，或者用常量kUploadFilesKey）
    /// - Parameters:
    ///   - type: 对象类型
    ///   - request: 请求体
    ///   - uploadProgress: 上传进度回调
    ///   - success: 成功回调
    ///   - fail: 失败回调
    /// - Returns: 返回请求体，支持取消请求
    @discardableResult
    public func httpUploadRequestTask <T> (_ type: T.Type, request: BPRequest, uploadProgress: ((Progress) -> Void)?, success: ((_ response: T) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate? where T: BPBaseResopnse

    // MARK: ==== Download ====
    /// 下载文件
    /// - Parameters:
    ///   - request: 请求体
    ///   - downloadProgress: 下载进度回调
    ///   - success: 下载成功回调
    ///   - fail: 下载失败回调
    @discardableResult
    public func httpDownloadRequestTask (request: BPRequest, downloadProgress: ((Progress) -> Void)?, success: ((_ response: AFDownloadResponse<Data>) -> Void)?, fail: ((_ responseError: NSError) -> Void)?) -> BPTaskRequestDelegate?

```

通过协议接收回调（在AppDelegate的扩展中实现）

```swift
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
```










