//
//  BPTaskRequest.swift
//  BaseProject
//
//  Created by 沙庭宇 on 2019/8/6.
//  Copyright © 2019 沙庭宇. All rights reserved.
//

import Foundation
import Alamofire

public protocol BPTaskRequestDelegate {
    var request: BPTaskRequestDelegate { get }
    func cancel()
}

public class BPRequestModel {

    ///请求Request类型对象
    private var taskRequest: Request?

    init(request: Request) {
        self.taskRequest = request
    }
}

extension BPRequestModel: BPTaskRequestDelegate {

    public var request: BPTaskRequestDelegate {
        return self
    }

    public func cancel() {
        guard let request = self.taskRequest else {
            return
        }
        request.cancel()
    }
}
