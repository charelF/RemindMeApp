//
//  ContentView.swift
//  Kiwi
//
//  Created by Charel Felten on 30/06/2021.
//

import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    
    var body: some View {
        TabView {
            
            NotesView()
            .tabItem {
                Image(systemName: "note")
                Text("Notes")
            }
            
            SettingsView()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
