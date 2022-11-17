//
//  ContentView.swift
//  RemindMe
//
//  Created by Charel Felten on 30/06/2021.
//

import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
  
  @ObservedObject var config: Config
  
  var body: some View {
    TabView {
      
      NotesView(config: config)
        .tabItem {
          Image(systemName: "note")
          Text("Notes")
        }
      
      SettingsView(config: config)
        .tabItem {
          Image(systemName: "gear")
          Text("Settings")
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      config: Config()
    )
  }
}
