//
//  AppDelegate.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 4/14/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import QuadratTouch
import RealmSwift

@UIApplicationMain
class MHAppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    var cacheLocation: URL?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        // Override point for customization after application launch.
        let APIKeys = NSDictionary(contentsOf: Bundle.main.url(forResource: "APIKeys", withExtension: "plist")!)!
        let foursquareClient = QuadratTouch.Client(clientID: APIKeys["clientID"] as! String, clientSecret: APIKeys["clientSecret"] as! String, redirectURL: "dinnerroll://foursquare")
        var config = QuadratTouch.Configuration(client: foursquareClient)
        config.mode = "foursquare"
        config.shouldControlNetworkActivityIndicator = true
        QuadratTouch.Session.setupSharedSessionWithConfiguration(config)
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else{
            return true
        }
        Realm.Configuration.defaultConfiguration.fileURL = cacheDirectory.appendingPathComponent("fsqcache.realm", isDirectory: false)
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) -> Void{
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(_ application: UIApplication) -> Void{
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) -> Void{
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    func applicationDidBecomeActive(_ application: UIApplication) -> Void{
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func applicationWillTerminate(_ application: UIApplication) -> Void{
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        return QuadratTouch.Session.sharedSession().handleURL(URL: url as NSURL)
    }
    func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) -> Void{
        (window?.rootViewController as? MHViewController)?.layoutFrames()
    }
}

//extension UIView{
//    var firstResponder: UIView?{
//        get{
//            guard !isFirstResponder else{
//                return self
//            }
//            for view in subviews{
//                guard let responder = view.firstResponder else{
//                    continue
//                }
//                return responder
//            }
//            return nil
//        }
//    }
//}

