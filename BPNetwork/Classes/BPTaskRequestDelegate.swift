//
//  BPTaskRequest.swift
//  BaseProject
//
//  Created by 沙庭宇 on 2019/8/6.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation
import Alamofire

protocol BPTaskRequestDelegate {
    var request: BPTaskRequestDelegate { get }
    func cancel()
}

class BPRequestModel {

    ///请求Request类型对象
    private var taskRequest: Request?

    init(request: Request) {
        self.taskRequest = request
    }
}

extension BPRequestModel: BPTaskRequestDelegate {

    var request: BPTaskRequestDelegate {
        return self
    }

    func cancel() {
        guard let request = self.taskRequest else {
            return
        }

        request.cancel()
    }
}
