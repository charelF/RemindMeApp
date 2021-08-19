//
//  NotesView.swift
//  RemindMe
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI
import WidgetKit

struct NotesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var config: Config

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    private var notes: FetchedResults<Note>
    @State private var noteContent: String = ""
    
    @State private var customDateNote: Note? = nil
    @State private var showCustomDateSheet = false
    @State private var customDate: Date = Date()
    
    var body: some View {
        List {
            ForEach(notes) { note in
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(note.content ?? "")")
                            .padding(.vertical, 0.2)
                        Spacer() // (1)
                    }
                    
                    if config.showCreationTime || config.showNotificationTime {
                        HStack {
                            if config.showCreationTime {
                                Image(systemName: "calendar")
                                Text("\(note.timestamp!, formatter: Note.dateFormatter)")
                            }
                            if config.showNotificationTime {
                                Image(systemName: "bell")
                                Text("\(note.describePriority())")
                            }
                            Spacer() // (1)
                        }
                        .font(.footnote)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(.bottom, 0.2)
                    }
                }
                .contentShape(Rectangle()) // This together with (1) makes whole area clickable
                .foregroundColor(note.getColor())
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    updateNotePriority(note)
                }
                .listRowBackground(note.getColor().opacity(0.05))
                .onLongPressGesture() {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    customDateNote = note
                    showCustomDateSheet = true
                }
            }
            .onDelete(perform: deleteNotes)

        TextField(
            "New Note",
            text: $noteContent,
            onCommit:addNote
        )}
        .listStyle(InsetGroupedListStyle())
        .animation(.default)
        .sheet(isPresented: $showCustomDateSheet) {
            NavigationView{
                VStack {
                    DatePicker("Reminder on", selection: $customDate)
                }
                .padding()
                .navigationBarItems(leading: Button(action: {
                    showCustomDateSheet.toggle()
                    }) {
                        Text("Cancel")
                    }, trailing: Button(action: {
                        createCustomNotePriority(customDateNote)
                        customDateNote = nil
                        showCustomDateSheet.toggle()
                    }) {
                        Text("Add")
                    }
                )
            }
    }
    }
    
    private func addNote() {
        withAnimation {
            guard !noteContent.isEmpty else {
                return
            }
            _ = Note(
                context: viewContext,
                content: noteContent
            )
            PersistenceController.shared.save()
            
            noteContent = ""
        }
    }
    
    private func createCustomNotePriority(_ optionalNote: Note?) {
        withAnimation {
            if let note = optionalNote {
                note.deleteNotifications()
                note.changePriority(notifyOn: customDate)
                note.addNotifications(notifyOn: customDate)
                PersistenceController.shared.save()
            }
        }
    }

    private func updateNotePriority(_ note: Note) {
        withAnimation {
            note.deleteNotifications()
            note.changePriority()
            note.addNotifications()
            PersistenceController.shared.save()
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            var note: Note
            for i in offsets {
                note = notes[i]
                note.deleteNotifications()
                viewContext.delete(note)
            }
            PersistenceController.shared.save()
        }
    }
}



struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView(
            config: Config()
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
