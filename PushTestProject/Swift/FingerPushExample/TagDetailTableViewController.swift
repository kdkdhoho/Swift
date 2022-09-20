//
//  TagDetailTableViewController.swift
//  FingerPushExample
//
//  Copyright (c) 2015년 kissoft. All rights reserved.
//

import UIKit

struct MyTagDevices: Codable {
    let tag: String
    let date: String
}

class TagDetailTableViewController: UITableViewController {
    
    var myTitle: String = ""
    private let fingerManager = finger.sharedData()
        
    @IBOutlet var btnTagAllDelete: UIButton!
    
    var myTagContents: Array<MyTagDevices>?
    var arr = [MyTagDevices]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.title = myTitle
        
        self.refreshControl = UIRefreshControl()
        
        if (myTitle == Constants.TITLE_MY_TAG) {
            //내 태그
            self.refreshControl?.addTarget(self, action: #selector(getMyTagList), for: .valueChanged)
            getMyTagList()
            
            let buttonItemAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddTagAlert))
            self.navigationItem.rightBarButtonItems = [self.editButtonItem,buttonItemAdd]
            self.editButtonItem.isEnabled = false
            
            btnTagAllDelete.setTitle("모두 삭제", for: .normal);
            btnTagAllDelete.addTarget(self, action: #selector(showRemoveAllTagAlert), for: .touchUpInside)
            
        }else if(myTitle == Constants.TITLE_ALL_TAG){
            //모든 태그
            self.refreshControl?.addTarget(self, action: #selector(getAllTagList), for: .valueChanged)
            
            self.tableView.tableHeaderView = UIView()
            self.tableView.tableFooterView = UIView()
            
            getAllTagList()
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - table
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath){
        
        let dic = myTagContents?[indexPath.row]
        cell.textLabel?.text = dic?.tag
        cell.detailTextLabel?.text = dic?.date

        if myTagContents?.count ?? 0 > 0 {
            self.editButtonItem.isEnabled = true
        }else{
            self.editButtonItem.isEnabled = false
        }
        
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 2
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.

        return myTagContents?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagDetailCellIdentifier", for: indexPath)
        
        // Configure the cell...
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing , animated: animated)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        
        if myTitle == Constants.TITLE_MY_TAG {

            if indexPath.row == myTagContents?.count {
                return false
            }else{
                return true
            }
        }
        
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            let dic = myTagContents?[indexPath.row]
            removeMyTag(dic?.tag ?? "")
            
        }
    }
  
    
    // MARK: - alert
    @objc func showAddTagAlert(){

        let alert = UIAlertController(title: "태그 추가", message: "", preferredStyle: .alert)
        alert.addTextField { (textfield) in }
        let actionClose = UIAlertAction(title: "닫기", style: .cancel, handler:nil)
        alert.addAction(actionClose)
        let actionAdd = UIAlertAction(title: "추가", style: .default, handler: { (action:UIAlertAction!) -> Void in
            
            let strText = alert.textFields?.first?.text!
            
            if strText?.count ?? 0 > 0 {
                self.addMyTag(strText ?? "")
            }
            
        })
        alert.addAction(actionAdd)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func showRemoveAllTagAlert(){
        
        let alert = UIAlertController(title: "모두 삭제", message: "", preferredStyle: .alert)
        let actionClose = UIAlertAction(title: "닫기", style: .cancel, handler:nil)
        alert.addAction(actionClose)
        let actionDelete = UIAlertAction(title: "삭제", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
            self.removeAllMyTag()
        })
        alert.addAction(actionDelete)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - finger
    /** 기기 태그 호출*/
    @objc func getMyTagList(){
        self.navigationItem.title = myTitle + " 확인 중"
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestGetDeviceTagList { (posts, error) -> Void in
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }

            self.setEditing(false, animated: false)

            self.myTagContents?.removeAll()

            if posts != nil {
                print("posts : \(posts!)")
                print("\(posts!)")
                
                do {
                    
                    //Convert to Data
                    let jsonData = try JSONSerialization.data(withJSONObject: posts as Any, options: JSONSerialization.WritingOptions.prettyPrinted)

                    //Json decode
                    do {
                        
                        self.myTagContents = try JSONDecoder().decode(Array<MyTagDevices>.self, from: jsonData )
                        print("\(String(describing: self.myTagContents))")
                        
                        DispatchQueue.main.async {
                            if self.myTagContents != nil {
                                self.arr.append(contentsOf: self.myTagContents!)
                                self.editButtonItem.isEnabled = true
                            }
                          
                        }
                        print("posts:\(posts!)" )
                        
                    } catch let jsonErr {
                        
                        print("\(jsonErr)" )
                    }
                } catch {
                    print("\(error.localizedDescription)")
                }
                
            }else{
                self.editButtonItem.isEnabled = false
            }
            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle + " ( \(self.myTagContents?.count ?? 0) )"
        }
    }
    
    /** 모든 태그 호출*/
    @objc func getAllTagList(){
        
        self.navigationItem.title = myTitle + " 확인 중"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestGetAllTagList { (posts, error) -> Void in
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }

            self.myTagContents?.removeAll()
            if posts != nil {
                print("posts : \(posts!)")
                do {
                    
                    //Convert to Data
                    let jsonData = try JSONSerialization.data(withJSONObject: posts as Any, options: JSONSerialization.WritingOptions.prettyPrinted)

                    //Json decode
                    do {
                        
                        self.myTagContents = try JSONDecoder().decode(Array<MyTagDevices>.self, from: jsonData )
                        print("\(String(describing: self.myTagContents))")
                        
                        DispatchQueue.main.async {
                            if self.myTagContents != nil{
                                self.arr.append(contentsOf: self.myTagContents!)
                            }
                        }
                        print("posts:\(posts!)" )
                        
                    } catch let jsonErr {
                        
                        print("\(jsonErr)" )
                    }
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle + " ( \(self.myTagContents?.count ?? 0) )"
            
        }
    }
    
    /** 기기 태그 추가*/
    func addMyTag(_ strTag: String){
        
        if strTag.count > 0 {
            
            self.navigationItem.title = "태그 추가 중"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let arrParam:Array = [strTag]
            
            fingerManager?.requestRegTag(withBlock: arrParam, { (posts, error) -> Void in
                
                if error != nil {
                    print("error : \(error.debugDescription)")
                }
                
                if posts != nil {
                    print("posts : \(posts!)")
                }
                self.getMyTagList()
            })
        }
    }
    
    /** 기기 태그 삭제 */
    func removeMyTag(_ strTag: String){
        
        print(strTag)
        
        if strTag.count > 0 {
            
            self.navigationItem.title = "태그 삭제 중"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let arrParam:Array = [strTag]
            
            fingerManager?.requestRemoveTag(withBlock: arrParam, { (posts, error) -> Void in
                
                if error != nil {
                    print("error : \(error.debugDescription)")
                }
                
                if posts != nil{
                    print("posts : \(posts!)")
                }

                self.getMyTagList()

            })
        }
    }
    
    /** 기기 모든 태그 삭제 */
    func removeAllMyTag() {
        
        self.navigationItem.title = "태그 삭제 중"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        fingerManager?.requestRemoveAllTag({ (posts, error) in
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }
            
            if posts != nil{
                print("posts : \(posts!)")
            }
            self.getMyTagList()
        })
    }
}
