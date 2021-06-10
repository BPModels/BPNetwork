//
//  BPEnvChangeViewController.swift
//  BaseProject
//
//  Created by Fish Sha on 2020/10/22.
//  Copyright © 2020 沙庭宇. All rights reserved.
//

import Foundation

public enum BPEnvType: Int {
    case dev     = 1
    case test    = 2
    case pre     = 3
    case release = 4
    case debug   = 5
    
    var api: String {
        get {
            switch self {
            case .dev:
                return "http://192.168.1.155:9080/"
            case .test:
                return "http://121.36.55.155:8081/api/"
            case .pre:
                return "http://121.36.23.209/api/"
            case .release:
                return "http://121.36.23.209/api/"
            case .debug:
                return UserDefaults.standard.unarchivedObject(forkey: "kCustomServerDomain") as? String ?? ""
            }
        }
    }
    
    var webApi: String {
        switch self {
        case .dev:
            return "http://192.168.1.155:8081/"
        case .test:
            return "http://121.36.55.155:8081/"
        case .pre:
            return "http://121.36.23.209/"
        case .release:
            return "http://121.36.23.209/"
        case .debug:
            return UserDefaults.standard.unarchivedObject(forkey: "kCustomWebDomain") as? String ?? ""
        }
    }
    
    var title: String {
        get {
            switch self {
            case .dev:
                return "开发环境"
            case .test:
                return "测试环境"
            case .pre:
                return "预发环境"
            case .release:
                return "正式环境"
            case .debug:
                return "自定义"
            }
        }
    }
}

class BPEnvChangeViewController: BPViewController , UITableViewDelegate, UITableViewDataSource {
    
    private let cellID = "BPEnvChangeCellID"
    private let typeList: [BPEnvType] = [.dev, .test, .pre, .release, .debug]

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = AdaptSize(55)
        tableView.showsVerticalScrollIndicator   = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private var changeButton: BPButton = {
        let button = BPButton(.second)
        button.setTitle("确认切换", for: .normal)
        button.setTitleColor(.white0)
        button.setStatus(.disable)
        return button
    }()
    
    private var backButton: BPButton = {
        let button = BPButton()
        button.setTitle("返回", for: .normal)
        button.setTitleColor(UIColor.gray0)
        button.layer.cornerRadius = AdaptSize(5)
        button.layer.borderWidth  = AdaptSize(1)
        button.layer.borderColor  = UIColor.gray0.cgColor
        return button
    }()
    
    private var borderLabel: BPLabel = {
        let label = BPLabel()
        label.text          = "描边："
        label.textColor     = UIColor.black0
        label.font          = UIFont.regularFont(ofSize: AdaptSize(13))
        label.textAlignment = .center
        return label
    }()
    private var debugBar: UISwitch = UISwitch()
    
    /// 临时选中的类型
    private var tmpEnv: BPEnvType?
    /// 临时填写的服务端域名
    private var tmpServerDomain: String?
    /// 临时填写的Web端域名
    private var tmpWebDomain: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar?.title = "选择环境"
        self.customNavigationBar?.hideLeftButton()
        self.createSubviews()
        self.bindProperty()
        self.bindData()
        self.printDocumentPath()
        DispatchQueue.global().async {
            let infoLog = """
                        User Token: \(BPUserModel.share.token) \n
                        User ID: \(BPUserModel.share.id) \n
                        Organization ID: \(BPUserModel.share.organizationId ?? 0) \n
                        User Other Info: \(BPUserModel.share.getModel().toJSONString() ?? "")
                """
            BPLog("\n======================================")
            BPLog(infoLog)
            BPLog("======================================\n")
            UIPasteboard.general.string = infoLog
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                kWindow.toast("信息已添加到剪切板")
            }
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        self.view.addSubview(tableView)
        self.view.addSubview(changeButton)
        self.view.addSubview(backButton)
        self.view.addSubview(borderLabel)
        self.view.addSubview(debugBar)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(AdaptSize(100))
            make.left.right.equalToSuperview()
            make.bottom.equalTo(changeButton.snp.top).offset(AdaptSize(20))
        }
        changeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(AdaptSize(-15))
            make.bottom.equalToSuperview().offset(AdaptSize(-50) - kSafeBottomMargin)
            make.size.equalTo(CGSize(width: kScreenWidth / 3, height: AdaptSize(50)))
        }
        backButton.snp.makeConstraints { (make) in
            make.bottom.size.equalTo(changeButton)
            make.left.equalToSuperview().offset(AdaptSize(15))
        }
        borderLabel.sizeToFit()
        borderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(changeButton)
            make.bottom.equalTo(changeButton.snp.top).offset(AdaptSize(-15))
            make.size.equalTo(borderLabel.size)
        }
        debugBar.snp.makeConstraints { (make) in
            make.left.equalTo(borderLabel.snp.right)
            make.bottom.equalTo(borderLabel)
        }
    }
    
    override func bindProperty() {
        super.bindProperty()
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        self.tableView.register(BPEnvChangeCell.classForCoder(), forCellReuseIdentifier: cellID)
        self.backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.changeButton.addTarget(self, action: #selector(changeAction), for: .touchUpInside)
        self.debugBar.addTarget(self, action: #selector(barAction(bar:)), for: .valueChanged)
    }
    
    override func bindData() {
        super.bindData()
        self.debugBar.isOn = UserDefaults.standard.bool(forKey: "borderDebug")
    }
    
    // MARK: ==== Event ====
    /// 返回
    /// - Parameter logOut: 是否需要退出重新登录
    @objc
    private func backAction(logOut: Bool = false) {
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true) {
            if logOut {
                BPUserModel.share.logoutAction()
            }
        }
    }
    
    @objc
    private func changeAction() {
        BPAlertManager.share.twoButton(title: "提示", description: "切换环境需要退出重新登录，确认切换吗？", leftBtnName: "取消", leftBtnClosure: nil, rightBtnName: "确定") { [weak self] in
            guard let self = self, let newEnv = self.tmpEnv else { return }
            currentEnv = newEnv
            if currentEnv == .debug {
                // 临时转正
                UserDefaults.standard.archive(object: self.tmpServerDomain, forkey: "kCustomServerDomain")
                UserDefaults.standard.archive(object: self.tmpWebDomain, forkey: "kCustomWebDomain")
            }
            self.backAction(logOut: true)
        }.show()
    }
    
    @objc
    private func barAction(bar: UISwitch) {
        if bar.isOn {
            BPAlertManager.share.twoButton(title: "提示", description: "开启描边调试模式需要退出重新登录，确认退出吗？", leftBtnName: "取消", leftBtnClosure: {
                bar.isOn = !bar.isOn
            }, rightBtnName: "确定") {
                UserDefaults.standard.set(true, forKey: "borderDebug")
                self.backAction(logOut: true)
            }.show()
        } else {
            BPAlertManager.share.twoButton(title: "提示", description: "关闭描边调试模式需要退出重新登录，确认退出吗？", leftBtnName: "取消", leftBtnClosure: {
                bar.isOn = !bar.isOn
            }, rightBtnName: "确定") {
                UserDefaults.standard.set(false, forKey: "borderDebug")
                self.backAction(logOut: true)
            }.show()
        }
    }

    /// 打印当前项目路径
    private func printDocumentPath() {
        BPLog(BPFileManager.share.documentPath)
    }
    
    // MARK: ==== UITableViewDataSource && UITableViewDelegate ====
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = typeList[indexPath.row]
        let isSelected: Bool = {
            if let tmpEnv = self.tmpEnv {
                return type == tmpEnv
            } else {
                return type == currentEnv
            }
        }()
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? BPEnvChangeCell else {
            return UITableViewCell()
        }
        cell.setData(type: type, isSelected: isSelected, serverDomain: tmpServerDomain, webDomain: tmpWebDomain)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let newEnv = BPEnvType(rawValue: indexPath.row + 1) else {
            return
        }
        if newEnv == .debug {
            BPAlertManager.share.twoTextField(title: "设置自定义域名", firstPlaceholder: "请输入Server Domain", secondPlaceholder: "请输入Web Domain") { serverDomain, webDomain in
                // 临时选择，未确认切换
                self.tmpEnv          = newEnv
                self.tmpServerDomain = serverDomain
                self.tmpWebDomain    = webDomain
                self.changeButton.setStatus(.normal)
                tableView.reloadData()
            }.show()
            
        } else {
            // 临时选择，未确认切换
            self.tmpEnv = newEnv
            self.changeButton.setStatus(.normal)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
