//
//  SettingsView.swift
//  Kiwi
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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    
                    Toggle(isOn: $config.showNotificationTime) {
                        Text("Show note description")
                    }
                    
                    Toggle(isOn: $config.showCreationTime) {
                        Text("Show note creation date")
                    }
                }
                
                ForEach(0..<3) { i in
                
                    Section(header: Text(config.priorityDescriptions[i]).foregroundColor(Color.secondary)) {

                        Picker(selection: $config.priorityIntervals[i], label: Text("Notification interval")) {
                            ForEach(Interval.allCases, id: \.self) { value in
                                Text(value.rawValue).tag(value)
                            }
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                            
                        }
                        
                        switch config.priorityIntervals[i] {
                        case .ten_minutes, .never:
                            EmptyView()
                        default:
                            DatePicker("First reminder per day at", selection: $config.priorityDates[i], displayedComponents: [.hourAndMinute])
                        }
                    }
                    .foregroundColor(Note.priorityToColor(priority: i))
                    .listRowBackground(Note.priorityToColor(priority: i).opacity(0.05))
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        // save the settings if we leave the app (goes away from foreground)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            config.save()
        }
        .onDisappear { updateAllNotes() }
    }
    
    private func updateAllNotes() {
        for note in notes {
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
