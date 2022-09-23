//
//  TabBarController.swift
//  TableViewProject
//
//  Created by 김동호 on 2022/09/16.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "PopUpSegue"){
//            let navi = segue.destination as! UINavigationController
//            let child = navi.viewControllers.first as! PopUpTableViewController
//            child.dicData = (sender as! [AnyHashable: Any] as [NSObject : AnyObject]?)
//        }
//    }

    // MARK: - 팝업
//    func showPopUp(_ param:[AnyHashable: Any]){
//        performSegue(withIdentifier: "PopUpSegue", sender:param)
//    }

}
