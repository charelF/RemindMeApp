////
////  NotesView.swift
////  RemindMe
////
////  Created by Charel Felten on 02/07/2021.
////
//
//import SwiftUI
//import WidgetKit
//import Combine
//
//struct NotesView: View {
//
//  @Environment(\.managedObjectContext) private var viewContext
//
//  @ObservedObject var config: Config
//  
//  @FetchRequest(
//    sortDescriptors: [
////      NSSortDescriptor(keyPath: \Note.int16priority, ascending: false),
//      NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)
//    ],
//    animation: .default
//  ) private var notes: FetchedResults<Note>
//
//  // new note
//  @State private var newNoteContent: String = ""
//  @FocusState private var newNoteIsFocused: Bool
//
//  // edit note
//  @State private var editNote: Note? = nil
//  @State private var editNoteContent: String = ""
//  @FocusState private var editNoteIsFocused: Bool
//
//  // custom date note
//  @State private var customDateNote: Note? = nil
//  @State private var showCustomDateSheet = false
//  @State private var customDate: Date = Date()
//
//  // dark mode
//  @Environment(\.colorScheme) var colorScheme
//
//  func submitNewNote() {
//    Note.add(content: newNoteContent)
//    newNoteContent = ""
//    newNoteIsFocused = false
//  }
//
//  func editExistingNote(note: Note?) {
//    guard let note else { return }
//    note.content = editNoteContent
//    PersistenceController.shared.save()
//    editNoteContent = ""
//    editNoteIsFocused = false
//    editNote = nil
//  }
//
//  func createCustomReminder(_ note: Note) {
//    customDateNote = note
//    showCustomDateSheet = true
//  }
//
//  func switchToEditNote(_ note: Note) {
//    editNote = note
//    editNoteContent = note.content ?? ""
//    editNoteIsFocused = true
//  }
//
//  var body: some View {
//    ScrollView(showsIndicators: false) {
//      VStack(spacing: 0) {
//        ForEach(notes, id: \.self) { note in
//          if (note != editNote) {
//            VStack {
//              OneNoteView(config: config, note: note)
//                .fontWeight(.medium)
//                .frame(maxWidth:.infinity, maxHeight: 100, alignment: .leading)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 20)
//                .background(
//                  ZStack {
//                    colorScheme == .dark ? Color.black : Color.white
//                    note.getWidgetBackgroundColor()
//                  }
//                )
//                .cornerRadius(5)
//                .contentShape(Rectangle())
//            }
//            .contextMenu {
//              NoteContextMenu(
//                note: note,
//                createCustomReminder: createCustomReminder,
//                switchToEditNote: switchToEditNote
//              )
//            }
//            .onTapGesture {
//              UIImpactFeedbackGenerator(style: .light).impactOccurred()
//              note.updatePriority(optionalDate: nil)
//            }
//            .padding(.init(top: 5, leading: 10, bottom: 0, trailing: 10))
//          } else {
//            VStack {
//              EditNoteView(
//                noteContent: $editNoteContent,
//                isNoteFocused: _editNoteIsFocused,
//                onsubmit: {editExistingNote(note: editNote)},
//                placeholder: editNoteContent
//              )
//                .fontWeight(.medium)
//                .font(.callout)
//                .frame(maxWidth:.infinity, maxHeight: 100, alignment: .leading)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 20)
//                .background(Color(UIColor.systemGroupedBackground))
//                .cornerRadius(5)
//                .contentShape(Rectangle())
//            }
//            .padding(.init(top: 5, leading: 10, bottom: 0, trailing: 10))
//          }
//        }
//        if editNote == nil {
//          VStack {
//            EditNoteView(
//              noteContent: $newNoteContent,
//              isNoteFocused: _newNoteIsFocused,
//              onsubmit: submitNewNote,
//              placeholder: "New Note"
//            )
//              .fontWeight(.medium)
//              .font(.callout)
//              .frame(maxWidth:.infinity, maxHeight: 100, alignment: .leading)
//              .padding(.vertical, 10)
//              .padding(.horizontal, 20)
//              .background(Color(UIColor.systemGroupedBackground))
//              .cornerRadius(5)
//              .contentShape(Rectangle())
//          }
//          .padding(.init(top: 5, leading: 10, bottom: 0, trailing: 10))
//
//        }
//      }
//      .cornerRadius(15)
////      .padding(10)
//    }
//    .background(colorScheme == .dark ? Color.black : Color.white)
//  }
//
//
//
////  var yyy: some View {
////    ZStack {
////      colorScheme == .dark ? Color.black : Color.white
////      Rectangle()
////        .fill(colorScheme == .dark ? Color.black : Color.white)
////        .overlay {
////          ScrollView {
////            VStack(alignment: .leading, spacing: 5) {
////              ForEach(notes, id: \.self) { note in
////                Text(note.content!)
////                  .fontWeight(.medium)
////                  .font(.callout)
////                  .foregroundColor(note.getPrimaryColor())
////                  .frame(maxWidth:.infinity, maxHeight: 30, alignment: .leading)
////                  .padding(.vertical, 10)
////                  .padding(.horizontal, 20)
////                  .background(note.getWidgetBackgroundColor())
////                  .cornerRadius(5)
////              }
////            }
////            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)          }
////        }
////        .cornerRadius(15)
////        .padding(10)
////    }
////  }
//
////  var xxx: some View {
////    List {
////      ForEach(notes) { note in
////        if (note != editNote) {
////          OneNoteView(config: config, note: note)
////            .contextMenu {
////              NoteContextMenu(
////                note: note,
////                createCustomReminder: createCustomReminder,
////                switchToEditNote: switchToEditNote
////              )
////            }
////            .listRowBackground(
////              ZStack {
////                colorScheme == .dark ? Color.black : Color.white
////                note.getBackgroundColor()
////              }
////            )
////            .swipeActions(edge: .trailing) {
////              Button(role: .destructive) {
////                note.delete()
////              } label: {
////                Label("Delete", systemImage: "trash")
////              }
////            }
////        } else {
////          EditNoteView(
////            noteContent: $editNoteContent,
////            isNoteFocused: _editNoteIsFocused,
////            onsubmit: {editExistingNote(note: editNote)},
////            placeholder: editNoteContent
////          )
////        }
////      }
////      if editNote == nil {
////        EditNoteView(
////          noteContent: $newNoteContent,
////          isNoteFocused: _newNoteIsFocused,
////          onsubmit: submitNewNote,
////          placeholder: "New Note"
////        )
////      }
////    }
////    .listStyle(InsetGroupedListStyle())
////    .sheet(isPresented: $showCustomDateSheet) {
////      CustomDateSheet(
////        customDateNote: $customDateNote,
////        showCustomDateSheet: $showCustomDateSheet,
////        customDate: $customDate
////      )
////    }
////  }
//}
//
//struct EditNoteView: View {
//  @Binding var noteContent: String
//  @FocusState var isNoteFocused: Bool
//  var onsubmit: () -> ()
//  var placeholder: String
//
//  var body: some View {
//    HStack {
//      TextField(placeholder, text: $noteContent)
//        .onSubmit(onsubmit)
//        .focused($isNoteFocused)
//      if (!noteContent.isEmpty) {
//        Button(action: onsubmit) {
//          Image(systemName: "checkmark")
//        }
//      }
//    }
//  }
//}
//
//struct NoteContextMenu: View {
//  var note: Note
//  var createCustomReminder: (Note) -> ()
//  var switchToEditNote: (Note) -> ()
//
//  var body: some View {
//    VStack {
//      Label("Created on: \(note.timestamp ?? Date(), formatter: Note.dateFormatter)", systemImage: "calendar")
//      Label("Reminders: \(note.priority.getIntervalDescription())", systemImage: "bell")
//      Button(
//        action: { createCustomReminder(note) },
//        label: { Label("Create Custom Reminder", systemImage: "calendar.badge.plus") }
//      )
//      Button(
//        action: { switchToEditNote(note) },
//        label: { Label("Edit Note", systemImage: "pencil") }
//      )
//      Button(
//        role: .destructive,
//        action: note.delete,
//        label: { Label("Delete", systemImage: "trash") }
//      )
//    }
//  }
//}
//
//struct CustomDateSheet: View {
//  @Binding var customDateNote: Note?
//  @Binding var showCustomDateSheet: Bool
//  @Binding var customDate: Date
//
//  func cancelButtonAction() {
//    showCustomDateSheet.toggle()
//  }
//
//  func addButtonAction() {
//    if let note = customDateNote {
//      note.updatePriority(optionalDate: customDate)
//    }
//    customDateNote = nil
//    showCustomDateSheet.toggle()
//  }
//
//  var body: some View {
//    NavigationView{
//      VStack {
//        DatePicker("Reminder on", selection: $customDate)
//      }
//      .padding()
//      .navigationBarItems(
//        leading: Button("Cancel", action: cancelButtonAction),
//        trailing: Button("Add", action: addButtonAction)
//      )
//    }
//  }
//}
//
//struct NotesView_Previews: PreviewProvider {
//  static var previews: some View {
//    NotesView(
//      config: Config()
//    )
//    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//  }
//}
