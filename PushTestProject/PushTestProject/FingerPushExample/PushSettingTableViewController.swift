//
//  PushSettingTableViewController.swift
//  FingerPushExample
//
//  Copyright (c) 2015년 kissoft. All rights reserved.
//

import UIKit

struct SettingDevices: Codable {
    let activity: String?
    let ad_activity: String?
    let appid: String?
    let appintver: String?
    let appver: String?
    let country: String?
    let device_type: String?
    let identity: String?
    let osver: String?
    let timezone: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case activity, ad_activity, appid, appintver, appver, country, device_type, identity, osver, timezone
    }
    
    static var allCases: [String] {
      return CodingKeys.allCases.map { $0.rawValue }
    }
}

private let TAG_SWITCH = 90003
private let TAG_SWITCH_AD = 90004

class PushSettingTableViewController: UITableViewController {
    
    let myTitle: String = "푸시 설정"
    var contents : SettingDevices?
    
    private var arrSectionTitle = ["설정","정보"]
    private var arrKeySetting = ["푸시수신여부","광고수신여부","identity"]
    
    private let fingerManager = finger.sharedData()
    
    private var strIdenti = ""
    
    private var switchPush = UISwitch(frame: .zero)
    private var switchPushAd = UISwitch(frame: .zero)

    // MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.title = myTitle
        self.tableView.tableFooterView = UIView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.getPushSettingInfo), for: .valueChanged)
        
        switchPush.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchPush.tag = TAG_SWITCH
        switchPushAd.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchPushAd.tag = TAG_SWITCH_AD

        configureNavigation()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getPushSettingInfo()
    }
    
    // MARK: - configure
    func configureNavigation(){
        
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.goSetting))
        self.navigationItem.rightBarButtonItem = buttonItem
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - table
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath){
        
        //설정
        let strKey = arrKeySetting[indexPath.row] 
        cell.textLabel?.text = strKey
        
        if indexPath.row == 0 {
            cell.accessoryView = switchPush
        }else if indexPath.row == 1 {
            cell.accessoryView = switchPushAd
        }else if indexPath.row == 2 {
            cell.detailTextLabel?.text = strIdenti
            if strIdenti.count > 0 {
                cell.accessoryType = .detailButton
            }
            cell.selectionStyle = .default
        }
        
        cell.layoutIfNeeded()
    }
    
    // MARK : - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                showEditAlert()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                showDeleteAlert()
            }
        }
        
    }
        
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrSectionTitle[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrKeySetting.count
        }
        
        return SettingDevices.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PushSettingCellIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.selectionStyle = .none

        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""

        if indexPath.section == 0 {
            
            configureCell(cell, indexPath: indexPath)
            
            return cell
        }
        
        let strKey = SettingDevices.allCases[indexPath.row]
        cell.textLabel?.text = strKey
        cell.detailTextLabel?.text = infoValue(infoKey: strKey)

        return cell
        
    }
    
    //MARK: - finger
    
    /** 핑거푸시 푸시 정보*/
    @objc public func getPushSettingInfo(){
        
        self.navigationItem.title = myTitle + " 확인 중"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestPushInfo { (posts, error) -> Void in
            
            if error != nil {
                log("error : \(error.debugDescription)")
            }

            if posts != nil {
                log("posts : \(posts!)")
                
                do {
                    //convert to data
                    let jsonData = try JSONSerialization.data(withJSONObject: posts as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                    log("\(jsonData)")
                    
                    do{
                        //Json decode
                        self.contents = try JSONDecoder().decode(SettingDevices.self, from: jsonData)
                        log("\(String(describing: self.contents))")
                        
                        DispatchQueue.main.async {
                            if self.contents?.activity == "A" {
                                self.switchPush.setOn(true, animated: true)
                            }else{
                                self.switchPush.setOn(false, animated: true)
                            }
                            
                            if self.contents?.ad_activity == "A" {
                                self.switchPushAd.setOn(true, animated: true)
                            }else{
                                self.switchPushAd.setOn(false, animated: true)
                            }
                            
                            self.strIdenti = self.contents?.identity ?? ""
                            
                            var arr = Array(SettingDevices.allCases)
                            log("\(arr)")
              
                            if self.contents?.activity != nil {
                                arr.remove(at: 7)
                            }
                            if self.contents?.ad_activity != nil {
                                arr.remove(at: 3)
                            }
                            if self.contents?.identity != nil {
                                arr.remove(at: 5)
                            }
                            
                            self.tableView.reloadData()

                        }
                        log("posts:\(posts!)" )
                        
                    } catch let jsonErr {
                        log("\(jsonErr)")
                    }
                } catch {
                    log("\(error.localizedDescription)")
                    
                }
            }
            
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle
            
        }
        
    }
    
    /** 아이덴티티 삭제*/
    func deleteIdentity(){
        
        self.navigationItem.title = "아이덴티티 삭제 중"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestRemoveId { (posts, error) -> Void in
            
            if error != nil {
                log("error : \(error.debugDescription)")
            }

            if posts != nil{
                log("posts : \(posts!)")

                self.strIdenti = ""
                self.tableView .reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle
        }
        
    }
    
    /** 아이덴티티 등록*/
    func regIdentity(_ str:String){
        
        self.navigationItem.title = "아이덴티티 추가 중"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestRegId(withBlock: str) { (posts, error) -> Void in
            
            if error != nil {
                log("error : \(error.debugDescription)")
            }

            if posts != nil{
                log("posts : \(posts!)")
                
                self.strIdenti = str
                self.tableView .reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle
        }
    }
    
    /**푸시 수신여부*/
    func toggleSwitch(_ isOn:Bool) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.setEnable(isOn, { (posts, error) -> Void in
            
            if posts != nil {
                log("posts : \(posts!)")
            }
            
            if error != nil {
                log("error : \(error.debugDescription)")
                self.switchPush.setOn(!isOn, animated: true)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })

    }
    
    /**광고 푸시 수신여부*/
    func toggleSwitchAd(_ isOn:Bool) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestSetAdPushEnable(isOn, { (posts, error) -> Void in
            
            if posts != nil {
                log("posts : \(posts!)")
            }
            
            if error != nil {
                log("error : \(error.debugDescription)")
                self.switchPushAd.setOn(!isOn, animated: true)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })

    }
    
    // MARK: - UISwitch
    @objc func switchChanged(_ sender :UISwitch){
        
        log("switchChanged : \(sender.isOn)")
        
        if sender.tag == TAG_SWITCH {
            
            toggleSwitch(sender.isOn)
            
        }else if sender.tag == TAG_SWITCH_AD {
            
            toggleSwitchAd(sender.isOn)
            
        }

    }
    
    // MARK: - 앱 설정 이동
    @objc func goSetting(){
        
        let url = URL(string: UIApplication.openSettingsURLString)
        
        UIApplication.shared.open(url!, options: [:]) { (success) in
            //
        }
        
    }
    
    // MARK: - alert
    func showEditAlert(){
        
        let alert = UIAlertController(title: "identity", message: strIdenti, preferredStyle: .alert)
        alert.addTextField { (textfield) in }
        let actionClose = UIAlertAction(title: "닫기", style: .cancel, handler:nil)
        alert.addAction(actionClose)
        let actionSave = UIAlertAction(title: "저장", style: .default, handler: { (action:UIAlertAction!) -> Void in
            
            let strText = (alert.textFields?.first?.text)! as String
            
            if strText.count > 0 {
                self.regIdentity(strText)
            }
            
        })
        alert.addAction(actionSave)
        self.present(alert, animated: true, completion: nil)

    }
    
    func showDeleteAlert(){
        
        let alert = UIAlertController(title: "identity", message: "삭제하시겠습니까?", preferredStyle: .actionSheet)
        let actionClose = UIAlertAction(title: "닫기", style: .cancel, handler:nil)
        alert.addAction(actionClose)
        let actionDelete = UIAlertAction(title: "삭제", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
            self.deleteIdentity()
        })
        alert.addAction(actionDelete)
        self.present(alert, animated: true, completion: nil)

    }
    
    // MARK: - SettingInfoValue 가져오기
    
    func infoValue(infoKey: String) -> String{
        
        if infoKey == "country"  {
            return contents?.country ?? ""
        } else if infoKey == "device_type"  {
            return contents?.device_type ?? ""
        } else if infoKey == "ad_activity" {
            return contents?.ad_activity ?? ""
        } else if infoKey == "appver" {
            return contents?.appver ?? ""
        } else if infoKey == "identity" {
            return contents?.identity ?? ""
        } else if infoKey == "appid" {
            return contents?.appid ?? ""
        } else if infoKey == "activity" {
            return contents?.activity ?? ""
        } else if infoKey == "timezone" {
            return contents?.timezone ?? ""
        } else if infoKey == "appintver" {
            return contents?.appintver ?? ""
        } else if infoKey == "osver" {
            return contents?.osver ?? ""
        }
        return infoKey
    }
    
}
