//
//  BPNetworkAuthManager.swift
//  Tenant
//
//  Created by 沙庭宇 on 2021/1/21.
//

import Foundation

/// 网络授权管理
class BPNetworkAuthManager: NSObject {
    
    static let `default` = BPNetworkAuthManager()
    
    var state: ZYNetworkAccessibleState?
    
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkChange(_:)), name: kNetworkAuth, object: nil)
    }
    
    func check() {
        ZYNetworkAccessibity.start()
        ZYNetworkAccessibity.setAlertEnable(true)
    }
    
    @objc func networkChange(_ notification: Notification) {
        self.state = ZYNetworkAccessibity.currentState()
    }
}
