//
//  AppDelegate.swift
//  FingerPushExample
//
//  Copyright (c) 2015년 kissoft. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    private let fingerManager = finger.sharedData()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //핑거 푸시 sdk 버전
        log("SdkVer : " + finger.getSdkVer())
        
        /*핑거 푸시*/
        forBuildStyle(debug: {
            //디버그일 경우
            fingerManager?.setAppKey("ENNGQZ8C4FAJ")
            fingerManager?.setAppScrete("evZhtSXPKXDpPg9zwpEb0N3Rf9riGluX")
            
        }) {
            fingerManager?.setAppKey("ENNGQZ8C4FAJ")
            fingerManager?.setAppScrete("evZhtSXPKXDpPg9zwpEb0N3Rf9riGluX")
        }
      
        /*apns 등록*/
        registeredForRemoteNotifications(application: application)
        
        return true
    }
    
    //MARK: - 푸시 등록
    func registeredForRemoteNotifications(application: UIApplication) {
                
        #if !targetEnvironment(simulator)
        
        if #available(iOS 10.0, *) {
        
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            // 카테고리를 이용한 NotificationAction
            //payload category 는 fp (이미지가 있을 경우 fp가 자동으로 함께 전송됩니다.)
            /*
            let acceptAction = UNNotificationAction(identifier: "com.kissoft.yes", title: "확인", options: .foreground)
            let declineAction = UNNotificationAction(identifier: "com.kissoft.no", title: "닫기", options: .destructive)
            let category = UNNotificationCategory(identifier: "fp", actions: [acceptAction,declineAction], intentIdentifiers: [], options: .customDismissAction)
            center.setNotificationCategories([category])
             */
            center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted, error) in
                
                log("granted : \(granted) / error : \(String(describing: error))")
                
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
                
            })

        }
                
        #endif
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        log("DeviceToken: \(deviceToken.description)")
        
        fingerManager?.registerUser(withBlock: deviceToken, { (posts, error) -> Void in
            
            log("finger token : " + ((self.fingerManager?.getToken()) ?? "없음"))
            log("finger DeviceIdx : " + ((self.fingerManager?.getDeviceIdx()) ?? "없음"))
            
            log("posts: \(String(describing: posts)) error: \(String(describing: error))")
            
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            
        if let dicAps = userInfo["aps"] as? Dictionary<String,Any> {
            
            if let ca = dicAps["content-available"] {
                //
                if ca as! Int == 1 {
                    //사일런트 푸시일 경우 처리
                    completionHandler(UIBackgroundFetchResult.newData)
                    return
                }
                
            }
            
        }
    
        /*핑거푸시 읽음처리*/
        checkPush(userInfo)

        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("\(error)")
    }
    
    //MARK: - 푸시 얼럿
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        log("\(userInfo)")
        
        /*핑거푸시 읽음처리*/
        checkPush(userInfo)

        let strAction = response.actionIdentifier
        log(strAction)
        if strAction.contains("yes") || strAction.contains("UNNotificationDefaultActionIdentifier") {
            showPopUp(userInfo: userInfo)
        }

        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: -
    func showPopUp(userInfo:[AnyHashable: Any]){
        
        var topRootViewController = UIApplication.shared.keyWindow!.rootViewController
        
        while topRootViewController!.presentedViewController != nil
        {
            topRootViewController = topRootViewController!.presentedViewController
        }
        
        if topRootViewController!.isKind(of: UINavigationController.self){
            
            let root = (topRootViewController as! UINavigationController).viewControllers.first
            
            if root!.isKind(of: PopUpTableViewController.self){
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let child = mainStoryboard.instantiateViewController(withIdentifier: "PopUpTableViewController") as! PopUpTableViewController
                child.dicData = userInfo as [NSObject : AnyObject]?
                (topRootViewController as! UINavigationController).pushViewController(child, animated: false)
                
            }
            
        }else if topRootViewController!.isKind(of: TabBarController.self){
            
            (topRootViewController as! TabBarController).showPopUp(userInfo)
            
        }
        
    }
    
    //MARK: - 푸시 오픈 체크
    func checkPush(_ UserInfo : [AnyHashable : Any]){
        
        finger.sharedData().requestPushCheck(withBlock: UserInfo , { (posts, error) -> Void in
            
            log("posts: \(String(describing: posts)) error: \(String(describing: error))")
            
        })
    }
    
}

