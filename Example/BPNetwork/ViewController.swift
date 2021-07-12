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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        BPNetworkService.default.httpUploadRequestTask(BPStructNilResponse.self, request: request) { progress in
            print("progress")
        } success: { response in
            print("success")
        } fail: { error in
            print("error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

enum BPMessageRequest: BPRequest {
    /// 消息首页
    case messageHome
    
    
    var method: BPHTTPMethod {
        switch self {
        case .messageHome:
            return .post
        }
    }
    
    var parameters: [String : Any?]? {
        let mBytes:[UInt8]  =  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        let data:Data = Data(bytes: mBytes, count: mBytes.count);
        var model = BPUpLoadFileModel()
        model.files = NSMutableData(data: data)
        model.files?.append(data)
        model.fileSize = 1111.11
        model.folderId = 222222
        model.orgId = 333333
        model.projectId = 444444
        model.relationId = 555555
        model.relationType = 6
        model.file = data
        model.type = 0
        return [kUploadFilesKey : model]
    }
    
    var path: String {
        switch self {
        case .messageHome:
            return "http://192.168.1.112/organization/baseInfo/organization/baseInfo/organization/baseInfo"
        }
    }
    
    var getTypeParameter: String {
        switch self {
        case .messageHome:
            return "test"
        }
    }
}

