//
//  NoticeTableViewController.swift
//  FingerPushExample
//
//  Copyright © 2020 kissoft. All rights reserved.
//

import UIKit

struct Devices: Codable {
    let code_yn: String?
    let content: String?
    let date: String?
    let image_yn: String?
    let imgUrl: String?
    let lcode: String?
    let link: String?
    let mode: String?
    let msgTag: String?
    let opened: String?
    let title: String?
    let type: String?
}

class NoticeTableViewController: UITableViewController {
    
    var contents: Array<Devices>?
    var refreshController : UIRefreshControl = UIRefreshControl()
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationbar 타이틀
        self.title = "메시지"
        
        self.tableView.tableFooterView = UIView()
        
        //refresh control
        refreshControl()
        
        //activityIndicator
        tableView.backgroundView = activityIndicatorView
        activityIndicatorView.frame = tableView.frame
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        //푸시 알림 리스트 보여주기
        requestPushList()

        configureNavigation()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    // MARK: - configure
    func configureNavigation(){
        
        let rightButtonItem = UIBarButtonItem(title: "InAppPush", style: .plain, target: self, action: #selector(self.showInAppPush))
//        let leftButtonItem = UIBarButtonItem(title: "ClearInAppPush", style: .plain, target: self, action: #selector(self.clearInAppPush))
        self.navigationItem.rightBarButtonItem = rightButtonItem
//        self.navigationItem.leftBarButtonItem = leftButtonItem
        
    }
    
    
    // MARK: - 인앱푸시
    @objc func showInAppPush(){
        
        finger.sharedData().show(inAppPush: self) { posts, event, error in
            
            if posts != nil{
                print("posts : \(posts ?? [:])")
            }
            
            if error != nil{
                print("error : \(error.debugDescription)")
            }
            
            // 인앱푸시 close event
            switch event.rawValue{
                
            case 0:

                print("InAppMessage")
                // 인엡 메세지 클릭시 사파리로 링크 이동
                if let url = URL(string: posts?["m_link_url"] as? String ?? ""){
                        UIApplication.shared.open(url)
                    }
                break
                
            case 1:
                print("NeverAgain")
                break
                
            case 2:
                print("Close")
                break
                
            case 3:
                print("Fail")
                break
                
            default:
                print("default")
                
            }
            
        }
        
    }
    
    
    // MARK: - 인앱푸시 초기화
    @objc func clearInAppPush(){
        
        UserDefaults.standard.removeObject(forKey: "finger_saved_inAppPush")
        
    }
    
    @objc func goLink(){
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = contents?[indexPath.row]
        
        //structure을 json으로
        let jsonData = try? JSONEncoder().encode(dic)
        
        //json을 dictionary로
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
            log("\(json)")

            //푸시 오픈체크
            checkPush(UserInfo: json as! NSDictionary)
            //팝업으로 핑거푸시 컨텐츠
            (self.tabBarController as! TabBarController).showPopUp(json as! [AnyHashable : Any])

        } catch let jsonErr {
            log("\(jsonErr)")
        }
                        
        //테이블 선택 시 회색 해제
        tableView.deselectRow(at: indexPath, animated: false)
        
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contents?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notice", for: indexPath)

        // Configure the cell...
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let item = contents?[indexPath.row]
        
        //날짜
        let strDate = item?.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let date = dateFormatter.date(from: strDate!)!
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let chgStrDate = dateFormatter.string(from: date)

        cell.textLabel?.text = String(format: "MESSAGE : %@", arguments: [(item?.content ?? "") as String])
        cell.detailTextLabel?.text = String(format: "MODE : %@\nDATE : %@\nImgUrl : %@", arguments: [(item?.mode ?? "") as String,chgStrDate,(item?.imgUrl ?? "") as String])

        return cell
    }
        
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - 리프레시
    func refreshControl(){
        refreshController.addTarget(self, action: #selector(requestPushList), for: .valueChanged)
        self.tableView.refreshControl = refreshController
    }
    
    //MARK: - 푸시리스트 요청
    @objc func requestPushList(){
        
        finger.sharedData()?.requestPushList({(posts, error) -> Void in
            if (posts != nil) {
                
                do {
                    
                    //Convert to Data
                    let jsonData = try JSONSerialization.data(withJSONObject: posts as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                    
                    //Json decode
                    do {
                        
                        self.contents = try JSONDecoder().decode(Array<Devices>.self, from: jsonData )
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        log("posts:\(posts!)" )
                        
                    } catch let jsonErr {
                        
                        log("\(jsonErr)" )
                    }
                } catch {
                    log("\(error.localizedDescription)")
                }
            }
            
            self.activityIndicatorView.stopAnimating()
            self.refreshController.endRefreshing()
        })
    }
    
    //MARK: - 푸시 오픈 체크
    func checkPush(UserInfo : NSDictionary){
        
        finger.sharedData().requestPushCheck(withBlock: UserInfo as? [AnyHashable : Any] , { (posts, error) -> Void in
            
            if posts != nil {
                log("\(posts!)")
            }
            
            if error != nil {
                log("\(error.debugDescription)")
            }
        })
    }
        

}
