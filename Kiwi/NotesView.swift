//
//  NotesView.swift
//  Kiwi
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
    
    @State private var customNotificationPopover = false
    @State private var customNoteRow = false
    @State private var customNoteRowID: UUID? = nil
    @State private var customNotificationDate: Date = Date()
    
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
                    
                        if note.id == customNoteRowID && customNoteRow {
                            DatePicker(selection: $customNotificationDate, label: { Text("Reminder at") })
//                            .padding(.bottom, 0.2)
////                            .onChange(of: customNotificationDate) { _ in
//////                                updateNotePriority(note)
//////                                customNoteRow = false
//////                                print(1)
////                            }
                        }
                }
                .contentShape(Rectangle()) // This together with (1) makes whole area clickable
                .foregroundColor(getColor(for: note))
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    updateNotePriority(note)
                    customNoteRow = false
                }
                .listRowBackground(getColor(for: note).opacity(0.05))
                .onLongPressGesture() {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                    customNoteRow = true
//                    customNoteRowID = note.id
                    customNotificationPopover = true
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
        .sheet(isPresented: $customNotificationPopover) {
            NavigationView {
                DatePicker(selection: $customNotificationDate, label: { Text("Date") })
                    .padding()
                Text("List of notifications")
                .navigationBarTitle(Text("Notifications"), displayMode: .inline)
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

    private func updateNotePriority(_ note: Note) {
        withAnimation {
            note.deleteNotifications()
            note.changePriority()
            note.addNotifications()
            PersistenceController.shared.save()
        }
    }
    
    private func getColor(for note: Note) -> Color {
        if note.id == customNoteRowID && customNoteRow {
            return Color.blue
        } else {
            return note.getColor()
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
