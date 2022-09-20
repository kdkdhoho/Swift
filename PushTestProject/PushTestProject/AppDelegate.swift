//
//  AppDelegate.swift
//  PushTestProject
//
//  Created by 김동호 on 2022/09/16.
//

import UIKit
import finger

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let fingerManager: finger = finger.sharedData()
    let appKey: String = "ENNGQZ8C4FAJ"
    let appSecretKey: String = "evZhtSXPKXDpPg9zwpEb0N3Rf9riGluX"

    // 1. 핑거푸시 APP KEY 설정
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
        fingerManager.setAppKey(appKey)
        fingerManager.setAppScrete(appSecretKey)
        #else
        fingerManager.setAppKey(appKey)
        fingerManager.setAppScrete(appSecretKey)
        #endif
        
        fingerManager.setAppKey(appKey)
        fingerManager.setAppScrete(appSecretKey)
        
        print("1")
        
        return true
    }
    
    // 2. 핑거푸시에 기기 등록
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("2")
        
        fingerManager.registerUser(withBlock: deviceToken, { (posts: String?, error: Error?) -> Void in
            if error != nil {
                print("기기등록 \(String(describing: posts))")
            } else {
                print("기기등록 error \(String(describing: error))")
            }
        })
    }
    
    // 3. 메시지 오픈 및 읽음 처리
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("3")
        
        // 참고: 메세지 정보 확인
//        let dicCode: Dictionary = finger.receviveCode(userInfo)
//        let strPT = dicCode["PT"]
//        let strIM = dicCode["IM"]
//        let strWL = dicCode["WL"]
        
        // 메시지 읽음 처리
        fingerManager.requestPushCheck(withBlock: userInfo, { (posts, error) in
            if error != nil {
                print("check \(String(describing: posts))")
            } else {
                print("check error: \(String(describing: error))")
            }
        })
    }

    // MARK: UISceneSession Lifecycle

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

