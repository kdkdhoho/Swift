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
    var opened: String?
    let title: String?
    let type: String?
}

class NoticeTableViewController: UITableViewController {
    
    var contents: Array<Devices>?
    var refreshController : UIRefreshControl = UIRefreshControl()
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationbar 타이틀
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
    
    //MARK: - 푸시리스트 요청
    @objc func requestPushList() {
        finger.sharedData()?.requestPushList({(posts, error) -> Void in
            if (posts != nil) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: posts as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                    
                    do {
                        self.contents = try JSONDecoder().decode(Array<Devices>.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
//                        print("posts:\(posts!)")
                    } catch let jsonErr {
                        print("\(jsonErr)" )
                    }
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            
            self.activityIndicatorView.stopAnimating()
            self.refreshController.endRefreshing()
        })
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
        let dic = contents?[indexPath.row]
//        print("<Result: \(dic)")
        
        //structure을 json으로
        let jsonData = try? JSONEncoder().encode(dic)
        
        //json을 dictionary로
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
            
            /* 반응 여부 갱신 */
            if(dic?.opened == "N") {
                self.checkPush(UserInfo: json as! NSDictionary)
                self.contents?[indexPath.row].opened = "Y"
                
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }
            
        } catch let jsonErr {
            print("jsonErr = \(jsonErr)")
        }
        
        //테이블 선택 시 회색 해제
        tableView.deselectRow(at: indexPath, animated: false)
        
        /* 푸시 누르면 웹 링크로 접속 */
        if (dic?.imgUrl != "") {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let child = mainStoryboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
            child.urlStr = dic?.link
            self.navigationController?.pushViewController(child, animated: true)
        }
    }
    
    // MARK: - 인앱푸시 초기화
    @objc func clearInAppPush(){
        UserDefaults.standard.removeObject(forKey: "finger_saved_inAppPush")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notice", for: indexPath)
        
        cell.prepareForReuse()
        
        // Configure the cell...
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let item = contents?[indexPath.row]

        cell.textLabel?.text = String(format: "MESSAGE : %@", arguments: [(item?.content ?? "") as String])
        cell.detailTextLabel?.text = String(format: "Open : %@\nImgUrl : %@\nWebLink : %@", arguments: [(item?.opened ?? "") as String, (item?.imgUrl ?? "") as String, (item?.imgUrl ?? "") as String])
    
        /* 이미지 그리기 */
        if(item?.imgUrl != "") {
            let url = URL(string: (item?.imgUrl)!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)

                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data!)
                }
            }
        } else {
            cell.imageView?.image = nil
        }

        return cell
    }
    
    // MARK: - 인앱푸시
    @objc func showInAppPush() {
        finger.sharedData().show(inAppPush: self) { posts, event, error in

            if posts != nil {
                print("posts : \(posts ?? [:])")
            }
            if error != nil {
                print("error : \(error.debugDescription)")
            }

            // 인앱푸시 close event
            switch event.rawValue {
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

    //MARK: - 리프레시
    func refreshControl(){
        refreshController.addTarget(self, action: #selector(requestPushList), for: .valueChanged)
        self.tableView.refreshControl = refreshController
    }
    
    //MARK: - 푸시 오픈 체크
    func checkPush(UserInfo : NSDictionary){
        finger.sharedData().requestPushCheck(withBlock: UserInfo as? [AnyHashable : Any] , { (posts, error) -> Void in
            if posts != nil {
                print("posts = \(posts!)")
            }
            if error != nil {
                print("error = \(error.debugDescription)")
            }
        })
    }
    
    // MARK: - configure
    func configureNavigation(){
//        let rightButtonItem = UIBarButtonItem(title: "InAppPush", style: .plain, target: self, action: #selector(self.showInAppPush))
        let leftButtonItem = UIBarButtonItem(title: "ClearInAppPush", style: .plain, target: self, action: #selector(self.clearInAppPush))
//        self.navigationItem.rightBarButtonItem = rightButtonItem
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
    }
}
