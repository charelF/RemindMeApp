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
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    private var notes: FetchedResults<Note>
    @State private var noteContent: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(notes) { note in
                    VStack(alignment: .leading) {
                        Text("\(note.content ?? "")")
                            .padding(.vertical, 0.2)
                        HStack {
                            Text("Time: \(note.timestamp!, formatter: noteFormatter) - Reminder: \(describePriority(note))")
                                .font(.footnote)
                                .foregroundColor(Color.gray.opacity(0.6))
                            Spacer() // (1)
                        }
                        .padding(.bottom, 0.2)
                    }
                    .contentShape(Rectangle()) // This together with (1) makes whole area clickable
                    .foregroundColor(priorityToColor(note))
                    .onTapGesture{
                        changePriority(note)
                        updateNotifications(note)
                    }
                    .listRowBackground(priorityToColor(note).opacity(0.1))
                }
                .onDelete(perform: deleteNotes)

            TextField(
                "New Note",
                text: $noteContent,
                onCommit:addNote
            )
            }
            .listStyle(GroupedListStyle())
            
//            Spacer()
//
//            VStack {
//                TextField(
//                    "New Note",
//                    text: $noteContent,
//                    onCommit:addNote
//                )
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//            .padding(.all)
//            .cornerRadius(20)

        }
    }
    
    func priorityToColor(_ note: Note) -> Color? {
        switch note.priority {
        case 1:
            return Color.green
        case 2:
            return Color.yellow
        case 3:
            return Color.red
        case 4:
            return Color.purple
        default:
            return Color.gray
        }
    }
    
    func describePriority(_ note: Note) -> String {
        switch note.priority {
        case 1:
            return "Weekly"
        case 2:
            return "Daily"
        case 3:
            return "Hourly"
        case 4:
            return "Every 5 Minutes"
        case 5:
            return "DEBUG"
        default:
            return "Never"
        }
    }
    
    private func updateNotifications(_ note: Note) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        // first remove the current Notifications
        if let noteUUID = note.id { // unwrap optional
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [noteUUID.uuidString])
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [noteUUID.uuidString])
            
            let content = UNMutableNotificationContent()
            content.title = note.content ?? "Empty Note"
            content.sound = UNNotificationSound.default
            
            let trigger: UNTimeIntervalNotificationTrigger
            switch note.priority {
            case 1:
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*24*5, repeats: true)
            case 2:
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*24, repeats: true)
            case 3:
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60, repeats: true)
            case 4:
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*5, repeats: true)
            case 5:
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            case 0:
                return
            default:
                return
            }
            
            let request = UNNotificationRequest(identifier: noteUUID.uuidString, content: content, trigger: trigger)
            
            notificationCenter.add(request) { (error) in
                if error != nil {
                    // TODO: handle error
                }
            }
        } else {
            print("Note has no id")
            return
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
                newNote.id = UUID()
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
    
    private func changePriority(_ note: Note) {
        note.priority += 1
        note.priority %= 6
        
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

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            print(offsets)
            
            // delete delivered and scheduled notifications for these notes
            for i in offsets {
                print(i)
                if let noteUUID = notes[i].id {
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [noteUUID.uuidString])
                    notificationCenter.removeDeliveredNotifications(withIdentifiers: [noteUUID.uuidString])
                }
            }

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
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
