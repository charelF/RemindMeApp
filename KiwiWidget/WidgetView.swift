//
//  WidgetView.swift
//  Kiwi
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI

struct WidgetView: View {
    
    var notes: [Note]
    
    @Environment(\.colorScheme) var colorScheme
    
    // Notes
    // - List not supported, so we have to use Vstack
    
    var body: some View {
        Color.secondary.opacity(0.2).overlay(
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Divider()
                ForEach(notes, id: \.self) { note in
                    LazyVStack(alignment: .leading) {
                        Text("\(note.content ?? "empty")")
                            .lineLimit(2)
                            .foregroundColor(Note.priorityToColor(priority: Int(note.priority)))
                            .padding(.horizontal, 8)
                            .padding(.top, 5)
                            .padding([.bottom], -1)
                            .font(.subheadline)

                            
                        Divider()
                    }
                    .background(Note.priorityToColor(priority: Int(note.priority)).opacity(0.05))
                    .background(getBackgroundColor()).opacity(1)
                }
            }
        })
    }
    
    private func getBackgroundColor() -> Color {
        let darkBG = Color(red: 0.1, green: 0.1, blue: 0.1)
        if colorScheme == .dark {
            return darkBG
        } else {
            return Color.white
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(
            notes: {
                let newItem = Note(context:
                    PersistenceController.preview.container.viewContext)
                newItem.timestamp = Date()
                newItem.content = "Note content"
                newItem.priority = Int16(0)
                newItem.id = UUID()
                return [newItem]
            }()
        ).previewLayout(.fixed(width: 160, height: 160))
    }
}
