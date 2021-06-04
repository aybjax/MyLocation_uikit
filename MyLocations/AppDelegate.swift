//
//  AppDelegate.swift
//  MyLocations
//
//  Created by aybjax on 6/1/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "DataModel")
//        container.loadPersistentStores { (storeDescription, error)
//            in
//            if let error = error {
//                fatalError("Could not load data store: \(error)")
//            }
//        }
//
//        return container
//    }()
//
//    lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        let tabController = window!.rootViewController as! UITabBarController
//        
//        if let tabViewControllers = tabController.viewControllers {
//            let navController = tabViewControllers[0] as! UINavigationController
//            let controller = navController.viewControllers.first as! CurrentLocationViewController
//            controller.managedObjectContext = managedObjectContext
//        }
        
//        listenForFatalCoreDataNotifications()
        
        return true
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

//    // MARK: -Helper
//    func listenForFatalCoreDataNotifications() {
//        NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification,
//                                               object: nil,
//                                               queue: OperationQueue.main,
//                                               using: { notification in
//                                                let message = """
//                                                There was a fatal error in the app and it cannot continue.
//                                                Press OK to terminate the app. Sorry for the inconvinience.
//                                                """
//                                                
//                                                let alert = UIAlertController(title: "Internal Error",
//                                                                              message: message,
//                                                                              preferredStyle: .alert)
//                                                
//                                                let action = UIAlertAction(title: "OK", style: .default) { _ in 
//                                                    let exception = NSException(
//                                                        name: NSExceptionName.internalInconsistencyException,
//                                                        reason: "Fatal Core Data Error",
//                                                        userInfo: nil)
//                                                    
//                                                    exception.raise()
//                                                }
//                                                alert.addAction(action)
//                                                
//                                                let tabController = self.window!.rootViewController!
//                                                tabController.present(alert, animated: true, completion: nil)
//                                               })
//    }
}

