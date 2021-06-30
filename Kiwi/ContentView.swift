//
//  ContentView.swift
//  Kiwi
//
//  Created by Charel Felten on 30/06/2021.
//

import SwiftUI
import CoreData
import UserNotifications

enum NotificationInterval: String, Equatable, CaseIterable {
    case high  = "Hourly"
    case medium = "Daily"
    case low  = "Weekly"
    case off = "Never"
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    private var notes: FetchedResults<Note>
    @State private var noteContent: String = ""
    @State var interval: NotificationInterval = .high
    
    var body: some View {
        VStack {
            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading) {
                        Text("\(note.content ?? "___")")
                        Text("\(note.timestamp!, formatter: noteFormatter)")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                    }
                    .listRowBackground(Color.green)
                }
                .onDelete(perform: deleteNotes)

                HStack {
                    TextField(
                        "New Note",
                        text: $noteContent,
                        onCommit:addNote
                    )
                        .textFieldStyle(DefaultTextFieldStyle())
                }
            }
            .listStyle(GroupedListStyle())
            
            Spacer()
            
            VStack {
                Button(action: sendNotification) {
                    Text("send notification")
                }

                Picker(selection: $interval, label: Text("Picker")) {
                    ForEach(NotificationInterval.allCases, id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .padding(.all)
                .pickerStyle(SegmentedPickerStyle())
            }

        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Feed the cat"
        content.subtitle = "It looks hungry"
        content.sound = UNNotificationSound.default
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                // TODO: handle error
           }
        }
    }

    private func addNote() {
        withAnimation {
            if noteContent == "" {
                return
            } else {
                let newNote = Note(context: viewContext)
                newNote.timestamp = Date()
                newNote.content = noteContent
                noteContent = ""

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                return
            }
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let noteFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
