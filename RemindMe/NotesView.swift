//
//  NotesView.swift
//  RemindMe
//
//  Created by Charel Felten on 02/07/2021.
//

import SwiftUI
import WidgetKit
import Combine

struct NotesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var config: Config

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    private var notes: FetchedResults<Note>
    
    // new note
    @State private var newNoteContent: String = ""
    @FocusState private var editNoteIsFocused: Bool
    
    // edit note
    @State private var editNote: Note? = nil
    @State private var editNoteContent: String = ""
    @FocusState private var newNoteIsFocused: Bool
    
    // custom date note
    @State private var customDateNote: Note? = nil
    @State private var showCustomDateSheet = false
    @State private var customDate: Date = Date()
    
    // dark mode
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        List {
            ForEach(notes) { note in
                if (note != editNote) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(note.content ?? "")")
                                .padding(.vertical, 0.2)
                            Spacer() // (1
                        }
                        
                        if (config.showCreationTime || config.showNotificationTime) {
                            HStack {
                                if (config.showCreationTime) {
                                    Image(systemName: "calendar")
                                    Text("\(note.timestamp!, formatter: Note.dateFormatter)")
                                }
                                if (config.showNotificationTime) {
                                    Image(systemName: "bell")
                                    Text("\(note.describePriority())")
                                }
                                Spacer() // (1)
                            }
                            .font(.footnote)
                            .foregroundColor(note.getSecondaryColor())
                            .padding(.bottom, 0.2)
                        }
                    }
                    .contentShape(Rectangle()) // This together with (1) makes whole area clickable
                    .foregroundColor(note.getPrimaryColor())
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        updateNotePriority(note)
                    }
                    .contextMenu {
                        VStack {
                            Label("Created on: \(note.timestamp!, formatter: Note.dateFormatter)", systemImage: "calendar")
                            Label("Reminders: \(note.describePriority())", systemImage: "bell")
                            
                            Button {
                                customDateNote = note
                                showCustomDateSheet = true
                            } label: {
                                Label("Custom Reminder", systemImage: "bell")
                            }
                            
                            Button {
                                editNote = note
                                editNoteContent = note.content ?? newNoteContent
                                editNoteIsFocused = true
                            } label: {
                                Label("Edit Note", systemImage: "bell")
                            }
                        }
                    }
                    .listRowBackground(
                        ZStack {
                            // to get rid of the ugly gray backgroud (which is visible as background color is semi
                            // transparent) we use Zstack and first put a white/black background
                            colorScheme == .dark ? Color.black : Color.white
                            note.getBackgroundColor()
                        }
                    ) // has to come after the context menu
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                } else { // in the case the note is to be edited
                    HStack {
                        TextField(
                            "\(editNoteContent)",
                            text: $editNoteContent,
                            onCommit:{
                                editNote = nil
                                note.content = editNoteContent
                                PersistenceController.shared.save()
                                editNoteContent = ""
                                editNoteIsFocused = false
                            }
                        )
                        .focused($editNoteIsFocused)

                        if (!editNoteContent.isEmpty) {
                            Button(action: {
                                editNote = nil
                                note.content = editNoteContent
                                PersistenceController.shared.save()
                                editNoteContent = ""
                                editNoteIsFocused = false
                                }) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } // close edit note if-else
            } // close for-each note
            
            HStack {
                TextField(
                    "New Note \(String(describing: editNoteIsFocused))",
                    text: $newNoteContent,
                    onCommit:{
                        addNote()
                        newNoteContent = ""
                        newNoteIsFocused = false
                    }
                )
                .focused($newNoteIsFocused)
                if (!newNoteContent.isEmpty) {
                    Button(action: {
                        addNote()
                        newNoteContent = ""
                        newNoteIsFocused = false
                        }) {
                        Image(systemName: "checkmark")
                    }
                }
            } // close new note cell
        } // close list
        .listStyle(InsetGroupedListStyle())
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
        } // close custom note sheet
    } // close body
    
    private func addNote() {
        withAnimation {
            guard !newNoteContent.isEmpty else {
                return
            }
            _ = Note(
                context: viewContext,
                content: newNoteContent
            )
            PersistenceController.shared.save()
            
            newNoteContent = ""
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
    
    private func deleteNote(_ optionalNote: Note?) {
        withAnimation {
            if let note = optionalNote {
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
