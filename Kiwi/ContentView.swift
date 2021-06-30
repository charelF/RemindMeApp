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
                            Text("\(note.timestamp!, formatter: noteFormatter) - Priority: \(describePriority(note))")
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

            }
            .listStyle(GroupedListStyle())
            
            Spacer()
            
            VStack {
                TextField(
                    "New Note",
                    text: $noteContent,
                    onCommit:addNote
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.all)
            .cornerRadius(20)

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
            return Color.blue
        default:
            return nil
        }
    }
    
    func describePriority(_ note: Note) -> String {
        switch note.priority {
        case 1:
            return "low"
        case 2:
            return "medium"
        case 3:
            return "high"
        case 4:
            return "--debug--"
        default:
            return "none"
        }
    }
    
    private func updateNotifications(_ note: Note) {
        print(note.content ?? "no string")
        print(note.id?.uuidString ?? "no id")
        print("----")
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        // first remove the current Notifications
        if let noteUUID = note.id { // unwrap optional
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
        note.priority %= 5
        
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
