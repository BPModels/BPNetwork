//
//  ViewController.swift
//  BPNetwork
//
//  Created by TestEngineerFish on 06/09/2021.
//  Copyright (c) 2021 TestEngineerFish. All rights reserved.
//

import UIKit
@_exported import BPNetwork

class ViewController: UIViewController {
    var request: BPRequest = BPMessageRequest.messageHome
    var requestInfo = BPMessageRequest.info
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.getRequest()
//        BPNetworkService.default.httpUploadRequestTask(BPStructNilResponse.self, request: request) { progress in
//            print("progress")
//            self.view.backgroundColor = .gray
//        } success: { response in
//            print("success")
//            self.view.backgroundColor = .green
//        } fail: { error in
//            print("error")
//            self.view.backgroundColor = .red
//        }
    }
    
    private func getRequest() {
        BPNetworkService.default.request(BPStructResponse<BPModel>.self, request: requestInfo) { response in
            print("response")
        } fail: { error in
            print("error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

import ObjectMapper

struct BPModel: Mappable {
    
    init() {}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {}
}

enum BPMessageRequest: BPRequest {
    /// 消息首页
    case messageHome
    case info
    
    var method: BPHTTPMethod {
        switch self {
        case .messageHome:
            return .post
        case .info:
            return .get
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        case .messageHome:
            let mBytes:[UInt8]  =  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
            let data:Data = Data(bytes: mBytes, count: mBytes.count);
            var model = BPUpLoadFileModel()
            model.files = [("first", data), ("second", data)]
            model.fileSize = 1111.11
            model.folderId = 222222
            model.orgId = 333333
            model.projectId = 444444
            model.relationId = 555555
            model.relationType = 6
            model.file = ("onley", data)
            model.type = 0
            return [kUploadFilesKey : model]
        default:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .messageHome:
            return "https://192.168.1.112/organization/baseInfo/organization/baseInfo/organization/baseInfo"
        case .info:
            return "http://aider.meizu.com/app/weather/listWeather?cityIds=101240101"
        }
    }
    
    var getTypeParameter: String {
        switch self {
        case .messageHome:
            return "test"
        default:
            return ""
        }
    }
}

