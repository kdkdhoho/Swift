//
//  AppInfoTableViewController.swift
//  FingerPushExample
//
//  Copyright (c) 2015년 kissoft. All rights reserved.
//

import UIKit

struct AppInfo: Codable {
    let info : [String:[AppInfoDevices]]
}

struct AppInfoDevices: Codable {
    let android_upd_link: String?
    let ios_upd_link: String?
    let android_int_version: String?
    let ios_int_version: String?
    let android_version: String?
    let ios_version: String?
    let android_last_int_version: String?
    let ios_last_int_version: String?
    let app_name: String?
    let appid: String?
    let beandroid: String?
    let beios: String?
    let beupdalert_a: String?
    let beupdalert_i: String?
    let category: String?
    let environments: String?
    let icon: String?
    let user_id: String?
    let ver_update_date_a: String?
    let ver_update_date_i: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case android_upd_link, ios_upd_link, android_int_version, ios_int_version, android_version, ios_version, android_last_int_version, ios_last_int_version, app_name, appid, beandroid, beios, beupdalert_a, beupdalert_i, category, environments, icon, user_id, ver_update_date_a, ver_update_date_i
    }

    static var allCases: [String] {
      return CodingKeys.allCases.map { $0.rawValue }
    }
}


class AppInfoTableViewController: UITableViewController {

    let myTitle: String = "앱 정보"
    var contents : AppInfoDevices?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.navigationItem.title = myTitle
        self.tableView.tableFooterView = UIView()

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.getAppInfo), for: .valueChanged)
        
        configureNavigation()
        
        getAppInfo()

    }
    
    // MARK: - configure
    func configureNavigation(){
        
        let buttonItem = UIBarButtonItem(title: "DemoApp", style: .plain, target: self, action: #selector(self.goAppStore))
        self.navigationItem.rightBarButtonItem = buttonItem
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - table
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath){

        let key = AppInfoDevices.allCases[indexPath.row]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = infoValue(infoKey: key)
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return AppInfoDevices.allCases.count

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppInfoCellIdentifier", for: indexPath)
        
        // Configure the cell...
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
        
    // MARK: - finger
    /**앱 정보 가져오기*/
    @objc private func getAppInfo(){
        
        self.navigationItem.title = myTitle + " 확인 중"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        finger.sharedData().requestGetAppReport { (posts, error) -> Void in
            
            if posts != nil {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: posts as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                    log("\(jsonData)")
                    
                    do{
                        self.contents = try JSONDecoder().decode(AppInfoDevices.self, from: jsonData)
                        log("\(String(describing: self.contents))")

                        DispatchQueue.main.async {
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
    
    // MARK: - 앱 설정 이동
    @objc func goAppStore(){
        
        let iTunesLink = "https://itunes.apple.com/app/apple-store/id970392368?mt=8"
        let url = URL(string: iTunesLink)
        
        UIApplication.shared.open(url!, options: [:]) { (success) in
            //
        }

    }
    
    // MARK: - InfoValue 가져오기
    
    func infoValue(infoKey: String) -> String{
        
        if infoKey == "category"  {
            return contents?.category ?? ""
        } else if infoKey == "beandroid"  {
            return contents?.beandroid ?? ""
        } else if infoKey == "ver_update_date_a" {
            return contents?.ver_update_date_a ?? ""
        } else if infoKey == "ios_upd_link" {
            return contents?.ios_upd_link ?? ""
        } else if infoKey == "android_upd_link" {
            return contents?.android_upd_link ?? ""
        } else if infoKey == "app_name" {
            return contents?.app_name ?? ""
        } else if infoKey == "beios" {
            return contents?.beios ?? ""
        } else if infoKey == "ios_version" {
            return contents?.ios_version ?? ""
        } else if infoKey == "appid" {
            return contents?.appid ?? ""
        } else if infoKey == "android_int_version" {
            return contents?.android_int_version ?? ""
        } else if infoKey == "android_version" {
            return contents?.android_version ?? ""
        } else if infoKey == "environments" {
            return contents?.environments ?? ""
        } else if infoKey == "icon" {
            return contents?.icon ?? ""
        } else if infoKey == "beupdalert_i" {
            return contents?.beupdalert_i ?? ""
        } else if infoKey == "ios_last_int_version" {
            return contents?.ios_last_int_version ?? ""
        } else if infoKey == "android_last_int_version" {
            return contents?.android_last_int_version ?? ""
        } else if infoKey == "user_id" {
            return contents?.user_id ?? ""
        } else if infoKey == "ver_update_date_i" {
            return contents?.ver_update_date_i ?? ""
        } else if infoKey == "beupdalert_a" {
            return contents?.beupdalert_a ?? ""
        } else if infoKey == "ios_int_version" {
            return contents?.ios_int_version ?? ""
        }
        return infoKey
    }
}
