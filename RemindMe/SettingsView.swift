//
//  SettingsView.swift
//  RemindMe
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI

struct SettingsView: View {
  
  @ObservedObject var config: Config
  
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
    animation: .default)
  private var notes: FetchedResults<Note>
  
  // dark mode
  @Environment(\.colorScheme) var colorScheme
  
  func updateAllNotes() {
    for note in notes {
      switch note.priority {
      case .custom(_):
        continue
      default:
        note.deleteNotifications()
        note.addNotifications()
      }
      PersistenceController.shared.save()
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        ForEach(Priority.allRegularCases) { priority in
          PriorityView(config: config, priority: priority)
        }
        
        Section(header: Text("Theme")) {
          Picker(selection: $config.colorTheme, label: Text("Theme")) {
            ForEach(ColorTheme.allCases, id: \.self) { value in
              Text(value.rawValue).tag(value)
            }
          }
        }
        
        Section(header: Text("Additional Info"), footer: Text("Toggle which additional information to show below each note in the list.")) {
          Toggle(isOn: $config.showNotificationTime) {
            Text("Show reminders")
          }
          Toggle(isOn: $config.showCreationTime) {
            Text("Show date")
          }
        }
      }
      .navigationTitle("Settings")
    }
    // save the settings if we leave the app (goes away from foreground)
    .onReceive(
      NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
      perform: { _ in config.save() }
    )
    .onDisappear(perform: updateAllNotes)
  }
}

struct PriorityView: View {
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var config: Config
  var priority: Priority
  
  var body: some View {
    Section(header: Text(priority.getDescription()).foregroundColor(Color.secondary)) {
      Picker(selection: $config.priorityIntervals[priority.getIndex()], label: Text("Notification interval")) {
        ForEach(Interval.allCases, id: \.self) { value in
          Text(value.rawValue).tag(value)
        }
      }
      
      switch config.priorityIntervals[priority.getIndex()] {
      case .ten_minutes, .never:
        EmptyView()
      default:
        DatePicker("Reminders at", selection: $config.priorityDates[priority.getIndex()], displayedComponents: [.hourAndMinute])
      }
      
    }
    .foregroundColor(Colors.getColor(for: priority, in: .primary))
    .listRowBackground(
      ZStack {
        colorScheme == .dark ? Color.black : Color.white
        Colors.getColor(for: priority, in: .background)
      }
      
    )
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(
      config: Config()
    )
  }
}
