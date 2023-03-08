//
//  SettingsView.swift
//  RemindMe
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
  
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var config: Config
  
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
          Button("Reload Widget") {
            print("calling widgetcenter")
            WidgetCenter.shared.reloadAllTimelines()
            WidgetCenter.shared.getCurrentConfigurations({result in print(result)})
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
    .onDisappear(perform: Note.updateAllNotes)
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
    .foregroundColor(Config.shared.colorTheme.getColors().getColor(for: priority, in: .primary))
    .listRowBackground(
      ZStack {
        colorScheme == .dark ? Color.black : Color.white
        Config.shared.colorTheme.getColors().getColor(for: priority, in: .background)
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
