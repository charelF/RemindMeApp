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
    sortDescriptors: [
      NSSortDescriptor(keyPath: \Note.int16priority, ascending: false),
      NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)
    ],
    animation: .default
  ) private var notes: FetchedResults<Note>
  
  // new note
  @State private var newNoteContent: String = ""
  @FocusState private var newNoteIsFocused: Bool
  
  // edit note
  @State private var editNote: Note? = nil
  @State private var editNoteContent: String = ""
  @FocusState private var editNoteIsFocused: Bool
  
  // custom date note
  @State private var customDateNote: Note? = nil
  @State private var showCustomDateSheet = false
  @State private var customDate: Date = Date()
  
  // dark mode
  @Environment(\.colorScheme) var colorScheme
  
  func submitNewNote() {
    Note.add(content: newNoteContent)
    newNoteContent = ""
    newNoteIsFocused = false
  }
  
  func editExistingNote(note: Note?) {
    guard let note else { return }
    note.content = editNoteContent
    PersistenceController.shared.save()
    editNoteContent = ""
    editNoteIsFocused = false
    editNote = nil
  }
  
  func createCustomReminder(_ note: Note) {
    customDateNote = note
    showCustomDateSheet = true
  }
  
  func switchToEditNote(_ note: Note) {
    editNote = note
    editNoteContent = note.content ?? ""
    editNoteIsFocused = true
  }
  
  var body: some View {
    List {
      ForEach(notes) { note in
        if (note != editNote) {
          OneNoteView(config: config, note: note)
            .contextMenu {
              NoteContextMenu(
                note: note,
                createCustomReminder: createCustomReminder,
                switchToEditNote: switchToEditNote
              )
            }
            .listRowBackground(
              ZStack {
                colorScheme == .dark ? Color.black : Color.white
                note.getBackgroundColor()
              }
            )
            .swipeActions(edge: .trailing) {
              Button(role: .destructive) {
                note.delete()
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
        } else {
          EditNoteView(
            noteContent: $editNoteContent,
            isNoteFocused: _editNoteIsFocused,
            onsubmit: {editExistingNote(note: editNote)},
            placeholder: editNoteContent
          )
        }
      }
      if editNote == nil {
        EditNoteView(
          noteContent: $newNoteContent,
          isNoteFocused: _newNoteIsFocused,
          onsubmit: submitNewNote,
          placeholder: "New Note"
        )
      }
    }
    .listStyle(InsetGroupedListStyle())
    .sheet(isPresented: $showCustomDateSheet) {
      CustomDateSheet(
        customDateNote: $customDateNote,
        showCustomDateSheet: $showCustomDateSheet,
        customDate: $customDate
      )
    }
  }
}

struct EditNoteView: View {
  @Binding var noteContent: String
  @FocusState var isNoteFocused: Bool
  var onsubmit: () -> ()
  var placeholder: String
  
  var body: some View {
    HStack {
      TextField(placeholder, text: $noteContent)
        .onSubmit(onsubmit)
        .focused($isNoteFocused)
      if (!noteContent.isEmpty) {
        Button(action: onsubmit) {
          Image(systemName: "checkmark")
        }
      }
    }
  }
}

struct NoteContextMenu: View {
  var note: Note
  var createCustomReminder: (Note) -> ()
  var switchToEditNote: (Note) -> ()

  var body: some View {
    VStack {
      Label("Created on: \(note.timestamp ?? Date(), formatter: Note.dateFormatter)", systemImage: "calendar")
      Label("Reminders: \(note.priority.getIntervalDescription())", systemImage: "bell")
      Button(
        action: { createCustomReminder(note) },
        label: { Label("Create Custom Reminder", systemImage: "calendar.badge.plus") }
      )
      Button(
        action: { switchToEditNote(note) },
        label: { Label("Edit Note", systemImage: "pencil") }
      )
    }
  }
}

struct CustomDateSheet: View {
  @Binding var customDateNote: Note?
  @Binding var showCustomDateSheet: Bool
  @Binding var customDate: Date
  
  func cancelButtonAction() {
    showCustomDateSheet.toggle()
  }
  
  func addButtonAction() {
    if let note = customDateNote {
      note.updatePriority(optionalDate: customDate)
    }
    customDateNote = nil
    showCustomDateSheet.toggle()
  }
  
  var body: some View {
    NavigationView{
      VStack {
        DatePicker("Reminder on", selection: $customDate)
      }
      .padding()
      .navigationBarItems(
        leading: Button("Cancel", action: cancelButtonAction),
        trailing: Button("Add", action: addButtonAction)
      )
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
