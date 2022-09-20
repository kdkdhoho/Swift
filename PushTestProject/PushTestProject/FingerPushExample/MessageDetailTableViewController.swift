//
//  MessageDetailTableViewController.swift
//  FingerPushExample
//
//  Created by naka98-kis on 2016. 1. 26..
//  Copyright © 2016년 kissoft. All rights reserved.
//

import UIKit

class MessageDetailTableViewController: UITableViewController {
    
    var myTitle: String = ""
    
    private let fingerManager = finger.sharedData()
    
    private var arrData = [AnyObject]()
    private var callPage:Int32 = 0
    private var totalPage:Int32 = 0
    
    private var imageDownloadsInProgress = NSMutableDictionary()
    
    private var isRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.title = myTitle
        self.tableView.tableFooterView = UIView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.reflesh), forControlEvents: .ValueChanged)
     
        //커스텀 셀
        self.tableView.registerNib(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageCellIdentifier")

        reflesh()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        terminateAllDownloads()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return arrData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let appRecord = arrData[section] as! AppRecord
        let strImgYn = appRecord.dicItem["image_yn"] as! String
        if strImgYn == "Y" {
            return 2
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            return 100.0
        }
     
        return Constants.TABLE_CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let appRecord = arrData[section] as! AppRecord
        let strTitle = appRecord.dicItem["title"] as! String

        return "TITLE : " + strTitle
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageDetailCellIdentifier", forIndexPath: indexPath)
            
            // Configure the cell...
            let appRecord = arrData[indexPath.section] as! AppRecord
            let dicItem = appRecord.dicItem
            let strMsg = dicItem["content"] as! String
            let strMode = dicItem["mode"] as! String
            let strDate = dicItem["date"] as! String
            let strOpened = dicItem["opened"] as! String
            
            cell.textLabel?.text = "MESSAGE : " + strMsg
            cell.detailTextLabel?.text = "MODE : " + strMode + "\n" + "DATE : " + strDate
            cell.detailTextLabel?.numberOfLines = 0
            
            if strOpened == "Y" {
                cell.accessoryType = .Checkmark
            }else{
                cell.accessoryType = .None
            }

            return cell
            
        }else{

            let cell = tableView.dequeueReusableCellWithIdentifier("imageCellIdentifier", forIndexPath: indexPath) as! ImageTableViewCell
            
            // Configure the cell...
            
            let appRecord = arrData[indexPath.section] as! AppRecord

            if appRecord.appIcon == nil {
                
                if tableView.dragging == false && tableView.decelerating == false{
                    startIconDownload(appRecord, indexPath: indexPath)
                }
                // if a download is deferred or in progress, return a placeholder image
                cell.imgPush.image = UIImage(named: "Icon_1024")
                
            }else{
                
                cell.imgPush.image = appRecord.appIcon
            }
            
            return cell

        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        print("self.tableView.numberOfSections : \(self.tableView.numberOfSections)")
        print("callPage : \(callPage)")
        
        if myTitle == Constants.TITLE_PAGING_MESSAGE {
            
            if arrData.count > 0 {
                if indexPath.section == arrData.count - 1 {
                    
                    if callPage > totalPage{
                        return
                    }
                    
                    if isRequest == false {
                        isRequest = true
                        self .getMessagePagingList(callPage + 1)
                    }
                    
                }
            }
            
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 오픈 체크 및 팝업
        checkPushAndShowPopUp(indexPath)
        
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if (arrData.count == 0) {
            return Constants.TABLE_FOOTER_HEIGHT
        }
        
        return 0.1
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), Constants.TABLE_FOOTER_HEIGHT))
        view.backgroundColor = .whiteColor()
        
        let lableNodata = UILabel(frame: view.bounds)
        lableNodata.backgroundColor = .clearColor()
        lableNodata.textColor = .darkGrayColor()
        lableNodata.font = .systemFontOfSize(16)
        lableNodata.textAlignment = .Center
        view.addSubview(lableNodata)
        
        if arrData.count == 0 {
            lableNodata.text = "표시할 내역이 없습니다."
        }else{
            lableNodata.text = ""
        }
        
        return view
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func reflesh(){
        if myTitle == Constants.TITLE_ALL_MESSAGE {
            arrData.removeAll()
            getMessageAllList()
        }else if myTitle == Constants.TITLE_PAGING_MESSAGE {
            callPage = 0
            arrData.removeAll()
            getMessagePagingList(callPage + 1)
        }
    }
    
    // MARK: - finger
    /** 최근 메세지 100건 가져오기*/
    func getMessageAllList(){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.navigationItem.title = myTitle.stringByAppendingString(" 확인 중")
        
        fingerManager.requestPushListWithBlock { (posts, error) -> Void in
            
            print("posts : \(posts) error : \(error)")
            
            if posts != nil{
                
                for i in 0..<posts.count {
                    
                    let dic = posts[i] as! [NSObject : AnyObject]
                    
                    let appRecord = AppRecord()
                    appRecord.dicItem = dic
                    appRecord.imageURLString = dic["imgUrl"] as! String
                    self.arrData.append(appRecord)
                    
                }
                
                self.tableView.reloadData()

            }
            
            self.refreshControl?.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle.stringByAppendingString(" ( \(self.arrData.count) )")
        }
        
    }
    
    /** 페이지 방식으로 메세지 가져오기*/
    func getMessagePagingList(page: Int32){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.navigationItem.title = myTitle.stringByAppendingString(" 확인 중")
        
        fingerManager.requestPushListPageWithBlock(page, cnt: 10) { (posts, error) -> Void in
            
            print("posts : \(posts) error : \(error)")
            
            self.isRequest = false
            
            if posts != nil{
                
                self.totalPage = (posts["totalpage"]?.intValue)!
                
                let arr = posts["pushList"] as! [AnyObject]
                
                for i in 0..<arr.count{
                
                    let dic = arr[i]
                    
                    let appRecord = AppRecord()
                    appRecord.dicItem = dic as! [NSObject : AnyObject]
                    appRecord.imageURLString = dic["imgUrl"] as! String
                    self.arrData.append(appRecord)
                    
                }
                
                self.tableView.reloadData()

                /*
                self.tableView.beginUpdates()
                let range = NSMakeRange(self.tableView.numberOfSections, self.arrData.count - self.tableView.numberOfSections)
                let indexSet = NSIndexSet(indexesInRange: range)
                self.tableView.insertSections(indexSet, withRowAnimation: .Fade)
                self.tableView.endUpdates()
                */
                
                self.callPage = self.callPage + 1

            }
            
            self.refreshControl?.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.navigationItem.title = self.myTitle.stringByAppendingString(" ( \(self.arrData.count) )")
        }
        
    }
    
    /**푸시 오픈 체크하기, 팝업*/
    func checkPushAndShowPopUp(indexPath: NSIndexPath){
        
        let appRecord = arrData[indexPath.section] as! AppRecord
        var dicItem = appRecord.dicItem
        
        //팝업
        let tabBar = self.tabBarController as! TabBarController
        tabBar.showPopUp(dicItem)
        
        //푸시 오픈 체크
        if dicItem["opened"] as! String == "N"{
            
            fingerManager.requestPushCheckWithBlock(dicItem) { (posts, error) -> Void in
                
                print("posts : \(posts) error : \(error)")
                
                if posts != nil{
                    
                    dicItem["opened"] = "Y"
                    appRecord.dicItem = dicItem
                    
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
                
            }
            
        }
        
    }
    
    // MARK: - Table cell image support
    
    // -------------------------------------------------------------------------------
    //	startIconDownload:forIndexPath:
    // -------------------------------------------------------------------------------
    func startIconDownload(appRecord: AppRecord, indexPath: NSIndexPath){
        
        if indexPath.row == 0 {
            return
        }
        
        var iconDownloader = self.imageDownloadsInProgress[indexPath] as? IconDownloader
        
        if iconDownloader == nil{
            iconDownloader = IconDownloader()
            iconDownloader?.appRecord = appRecord
            iconDownloader?.completionHandler = {() -> Void in

                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ImageTableViewCell
                
                if cell == nil {
                    return
                }
                
                cell!.imgPush.image = appRecord.appIcon
                
                self.imageDownloadsInProgress.removeObjectForKey(indexPath)
                
            }
            
            self.imageDownloadsInProgress[indexPath] = iconDownloader
            iconDownloader?.startDownload()
            
        }
        
    }
    
    // -------------------------------------------------------------------------------
    //	loadImagesForOnscreenRows
    //  This method is used in case the user scrolled into a set of cells that don't
    //  have their app icons yet.
    // -------------------------------------------------------------------------------
    
    func loadImagesForOnscreenRows() {
        if arrData.count > 0 {
            let visiblePaths = self.tableView.indexPathsForVisibleRows!
            for indexPath: NSIndexPath in visiblePaths {
                let appRecord = arrData[indexPath.section] as! AppRecord
                if (appRecord.appIcon == nil) {
                    startIconDownload(appRecord, indexPath: indexPath)
                }
            }
        }
    }
    
    
    // -------------------------------------------------------------------------------
    //	scrollViewDidEndDragging:willDecelerate:
    //  Load images for all onscreen rows when scrolling is finished.
    // -------------------------------------------------------------------------------
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenRows()
        }
    }
    // -------------------------------------------------------------------------------
    //	scrollViewDidEndDecelerating:scrollView
    //  When scrolling stops, proceed to load the app icons that are on screen.
    // -------------------------------------------------------------------------------
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadImagesForOnscreenRows()
    }
    
    
    // -------------------------------------------------------------------------------
    //	terminateAllDownloads
    // -------------------------------------------------------------------------------
    
    func terminateAllDownloads() {
        // terminate all pending download connections
        
        let allDownloads = self.imageDownloadsInProgress.allValues as NSArray
        
        for i in 0..<allDownloads.count{
            
            let iconDownloader = allDownloads[i] as! IconDownloader
            iconDownloader.cancelDownload()
            
        }
        
        self.imageDownloadsInProgress.removeAllObjects()
            
    }
    
}
