//
//  AppDelegate.swift
//  Networking
//
//  Created by Ivan Maslov on 24.07.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var bgSessionCompletionHandler: (() -> ())?
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        bgSessionCompletionHandler = completionHandler
    }
}

