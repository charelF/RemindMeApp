//
//  NotesView.swift
//  Kiwi
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI

struct NotesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var config: Config

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
                            Text("Time: \(note.timestamp!, formatter: noteDateFormatter) - Reminder: \(describePriority(note))")
                                .font(.footnote)
                                .foregroundColor(Color.gray.opacity(0.6))
                            Spacer() // (1)
                        }
                        .padding(.bottom, 0.2)
                    }
                    .contentShape(Rectangle()) // This together with (1) makes whole area clickable
                    .foregroundColor(priorityToColor(note: note))
                    .onTapGesture{
                        changePriority(note)
                        updateNotifications(note)
                    }
                    .listRowBackground(priorityToColor(note: note).opacity(0.05))
                }
                .onDelete(perform: deleteNotes)

            TextField(
                "New Note",
                text: $noteContent,
                onCommit:addNote
            )
            }
            .listStyle(GroupedListStyle())

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
        note.priority %= 4
        
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

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView(
            config: Config()
        ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
