//
//  KiwiApp.swift
//  Kiwi
//
//  Created by Charel Felten on 30/06/2021.
//

import SwiftUI
import UserNotifications



@main
struct KiwiApp: App {
    let persistenceController = PersistenceController.shared
    
    @ObservedObject var config = Config.shared
    
    init() {
        
        // request notification access
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
            if let error = error {
                // Handle the error here.
                print(error.localizedDescription)
            }
            // Enable or disable features based on the authorization.
        })
    }

    var body: some Scene {
        WindowGroup {
            ContentView(config: config)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
