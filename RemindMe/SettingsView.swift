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
    
    var body: some View {
        NavigationView {
            Form {
                // we loop to priorityCount-1 not included because the last priority (the one at index priorityCount-1 since
                // we index by 0) is reserved for custom date priority
                ForEach(0..<(Note.priorityCount-1)) { i in
                    Section(header: Text(config.priorityDescriptions[i]).foregroundColor(Color.secondary)) {
                        Picker(selection: $config.priorityIntervals[i], label: Text("Notification interval")) {
                            ForEach(Interval.allCases, id: \.self) { value in
                                Text(value.rawValue).tag(value)
                            }
                        }
//                        .pickerStyle(.menu)
                        
                        switch config.priorityIntervals[i] {
                        case .ten_minutes, .never:
                            EmptyView()
                        default:
                            DatePicker("First reminder per day at", selection: $config.priorityDates[i], displayedComponents: [.hourAndMinute])
                        }
                        
                    }
                    .foregroundColor(Colors.getColor(for: i, in: .primary))
                    .listRowBackground(
                        ZStack {
                            colorScheme == .dark ? Color.black : Color.white
                            Colors.getColor(for: i, in: .background)
                        }
                        
                    )
                } // end ForEach
                
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            config.save()
        }
        .onDisappear { updateAllNotes() }
    }
    
    private func updateAllNotes() {
        for note in notes {
            guard note.priority != Note.datePriorityNumber else {
                continue
            }
            note.deleteNotifications()
            note.addNotifications()
            PersistenceController.shared.save()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            config: Config()
        )
    }
}
