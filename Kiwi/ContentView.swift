//
//  ContentView.swift
//  Kiwi
//
//  Created by Charel Felten on 30/06/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    private var notes: FetchedResults<Note>
    @State private var noteContent: String = ""

    var body: some View {
        NavigationView {
            VStack {
                
                List {
                    ForEach(notes) { note in
                        VStack(alignment: .leading) {
                            Text("\(note.content ?? "/")")
                            Text("\(note.timestamp!, formatter: noteFormatter)")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                        }
                        
                    }
                    .onDelete(perform: deleteNotes)
                
                    HStack {
                        TextField(
                            "New Note",
                            text: $noteContent,
                            onCommit:addNote
                        )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                    
//                .navigationBarItems(
//                    leading: EditButton(),
//                    trailing: Button(action: addNote) {
//                        Image(systemName: "plus")
//                    }
//                )
                
            
            }
        }
    }

    private func addNote() {
        withAnimation {
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
