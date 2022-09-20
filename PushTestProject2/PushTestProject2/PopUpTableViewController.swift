//
//  PopUpTableViewController.swift
//  FingerPushExample
//
//  Copyright © 2016년 kissoft. All rights reserved.
//

import UIKit
import finger

class PopUpTableViewController: UITableViewController ,UITextViewDelegate{

    var dicData:[AnyHashable: Any]?
    
    private var myTitle: String = "푸시 컨텐츠"

    private let fingerManager = finger.sharedData()
    private var dicPushContents = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.navigationItem.title = myTitle
        self.tableView.tableFooterView = UIView()
        
        let buttonItemDicData = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.showDicData))
        self.navigationItem.rightBarButtonItem = buttonItemDicData
        
        let buttonItemFlex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonItemClose = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeSelf))
        self.setToolbarItems([buttonItemFlex, buttonItemClose, buttonItemFlex], animated: false)
        
        self.navigationController!.setToolbarHidden(false, animated: false)
        self.navigationController?.toolbar.tintColor = .black
        
        getPushContents()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return dicPushContents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpCellIdentifier", for: indexPath)
        // Configure the cell...
        
        let strKey = dicPushContents.keys.sorted()[indexPath.row]
        cell.textLabel?.text = strKey
        cell.detailTextLabel?.text = dicPushContents[strKey]
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
        
    }
        
    // MARK: -
    @objc func closeSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showDicData(){
        //
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.dicData as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                print("\(json)")
                
                //내용 얼럿
                let alert = UIAlertController(title: "", message: "\(json)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true)
                            
            } catch let jsonErr {
                print("\(jsonErr)")
            }
            
        } catch let error {
            print("\(error)")
        }
        
    }
    
    // MARK: - finger
    
    /**푸시 정보 가져오기*/
    func getPushContents(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.navigationItem.title = myTitle + " 확인 중"
        
        fingerManager?.requestPushContent(withBlock: self.dicData) { (posts, error) -> Void in
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }
            
            if posts != nil{
                print("posts : \(posts!)")

                for (key, value) in posts ?? [:] {
                    self.dicPushContents[key as! String] = (value as! String)
                }
                
                self.tableView.reloadData()
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle
            
        }
        
    }
    
}
