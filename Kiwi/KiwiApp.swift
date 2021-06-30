//
//  KiwiApp.swift
//  Kiwi
//
//  Created by Charel Felten on 30/06/2021.
//

import SwiftUI

@main
struct KiwiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
