//
//  AppDelegate.swift
//  PushTestProject2
//
//  Created by 김동호 on 2022/09/16.
//

import UIKit
import UserNotifications
import finger

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    private let fingerManager = finger.sharedData()
    let appKey = "ENNGQZ8C4FAJ"
    let appSecret = "evZhtSXPKXDpPg9zwpEb0N3Rf9riGluX"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("SdkVer : \(String(describing: finger.getSdkVer()))")
        
        #if DEBUG
        fingerManager?.setAppKey(appKey)
        fingerManager?.setAppScrete(appSecret)
        #else
        fingerManager?.setAppKey(appKey)
        fingerManager?.setAppScrete(appSecret)
        #endif
        
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
                
                print("granted : \(granted) / error : \(String(describing: error))")
                
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
                
            })

        }
                
        #endif
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("DeviceToken: \(deviceToken.description)")
        
        fingerManager?.registerUser(withBlock: deviceToken, { (posts, error) -> Void in
            
            print("finger token : " + ((self.fingerManager?.getToken()) ?? "없음"))
            print("finger DeviceIdx : " + ((self.fingerManager?.getDeviceIdx()) ?? "없음"))
            
            print("posts: \(String(describing: posts)) error: \(String(describing: error))")
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            
        if let dicAps = userInfo["aps"] as? Dictionary<String,Any> {
            
            if let ca = dicAps["content-available"] {
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
        print("\(error)")
    }
    
    //MARK: - 푸시 얼럿
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("\(userInfo)")
        
        /*핑거푸시 읽음처리*/
        checkPush(userInfo)

        let strAction = response.actionIdentifier
        print(strAction)
        if strAction.contains("yes") || strAction.contains("UNNotificationDefaultActionIdentifier") {
            showPopUp(userInfo: userInfo)
        }

        completionHandler()
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
            
            print("posts: \(String(describing: posts)) error: \(String(describing: error))")
            
        })
    }

    //MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

