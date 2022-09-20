//
//  TabBarController.swift
//  FingerPushExample
//
//  Copyright (c) 2015년 kissoft. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "PopUpSegue"){
            let navi = segue.destination as! UINavigationController
            let child = navi.viewControllers.first as! PopUpTableViewController
            child.dicData = (sender as! [AnyHashable: Any] as [NSObject : AnyObject]?)
        }
        
    }
    
    // MARK: - 팝업
    func showPopUp(_ param:[AnyHashable: Any]){
        performSegue(withIdentifier: "PopUpSegue", sender:param)
    }
    
}
