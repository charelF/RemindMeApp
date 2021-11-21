//
//  NoteView.swift
//  RemindMe
//
//  Created by Charel Felten on 21/11/2021.
//

import SwiftUI

struct NoteView: View {
    
    @ObservedObject var config: Config
    
    // on having a childview update when parent changes:
    // - https://stackoverflow.com/q/57614564/9439097
    // - https://developer.apple.com/forums/thread/123920
    @ObservedObject var note: Note
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(note.content ?? "")")
                    .padding(.vertical, 0.2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            
            if (config.showCreationTime || config.showNotificationTime) {
                HStack {
                    if (config.showCreationTime) {
                        Image(systemName: "calendar")
                        Text("\(note.timestamp ?? Date.now, formatter: Note.dateFormatter)")
                    }
                    if (config.showNotificationTime || (note.priority == Note.datePriorityNumber)) {
                        Image(systemName: "bell")
                        Text("\(note.describePriority())")
                    }
                    Spacer()
                }
                .font(.footnote)
                .foregroundColor(note.getSecondaryColor())
                .padding(.bottom, 0.2)
            }
        }
        
        // to make the entire area clickable
        .contentShape(Rectangle())
        
        // changing the foreground color
        .foregroundColor(note.getPrimaryColor())
        
        // if we tap once on the note, we update its priority
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            note.updatePriority()
        }
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(config: Config(), note: Note.previewNotes.first!)
    }
}
