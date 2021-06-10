//
//  BPEnvChangeCell.swift
//  Tenant
//
//  Created by samsha on 2021/5/31.
//

import UIKit

class BPEnvChangeCell: UITableViewCell {
    
    private var titleLabel: BPLabel = {
        let label = BPLabel()
        label.text          = ""
        label.textColor     = UIColor.black0
        label.font          = UIFont.mediumFont(ofSize: AdaptSize(18))
        label.textAlignment = .left
        return label
    }()
    private var serverApiLabel: BPLabel = {
        let label = BPLabel()
        label.text          = ""
        label.textColor     = UIColor.gray0
        label.font          = UIFont.regularFont(ofSize: AdaptSize(14))
        label.textAlignment = .left
        return label
    }()
    private var webApiLabel: BPLabel = {
        let label = BPLabel()
        label.text          = ""
        label.textColor     = UIColor.gray0
        label.font          = UIFont.regularFont(ofSize: AdaptSize(14))
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createSubviews()
        self.bindProperty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(serverApiLabel)
        self.contentView.addSubview(webApiLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(AdaptSize(15))
            make.top.equalToSuperview().offset(AdaptSize(10))
            make.right.equalToSuperview().offset(AdaptSize(-15))
            make.height.equalTo(titleLabel.font.lineHeight)
        }
        serverApiLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(AdaptSize(5))
            make.height.equalTo(serverApiLabel.font.lineHeight)
        }
        webApiLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(serverApiLabel.snp.bottom)
            make.height.equalTo(webApiLabel.font.lineHeight)
            make.bottom.equalToSuperview().offset(AdaptSize(-15))
        }
    }
    
    private func bindProperty() {
        self.selectionStyle = .none
        self.accessoryType  = .disclosureIndicator
    }
    
    
    // MARK: ==== Event ====
    
    /// 设置显示内容
    /// - Parameters:
    ///   - type: 类型
    ///   - isSelected: 是否选中
    ///   - serverDomain: 临时自定义服务端域名
    ///   - webDomain: 临时自定义Web端域名
    func setData(type: BPEnvType, isSelected: Bool, serverDomain: String? = nil, webDomain: String?) {
        if type == .debug {
            if let serverApi = serverDomain {
                self.serverApiLabel.text = "Server: " + serverApi
            } else {
                self.serverApiLabel.text = "Server: " + type.api
            }
            if let webApi = webDomain {
                self.webApiLabel.text = "Web:    " + webApi
            } else {
                self.webApiLabel.text = "Web:    " + type.webApi
            }
        } else {
            self.serverApiLabel.text = "Server: " + type.api
            self.webApiLabel.text    = "Web:    " + type.webApi
        }
        self.titleLabel.text      = type.title
        
        if isSelected {
            self.titleLabel.textColor = UIColor.blue0
            self.titleLabel.font      = UIFont.mediumFont(ofSize: AdaptSize(24))
        } else {
            self.titleLabel.textColor = UIColor.black0
            self.titleLabel.font      = UIFont.mediumFont(ofSize: AdaptSize(18))
        }
    }
}
