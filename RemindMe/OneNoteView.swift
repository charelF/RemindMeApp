//
//  OneNoteView.swift
//  RemindMe
//
//  Created by Charel Felten on 21/11/2021.
//

import SwiftUI

struct OneNoteView: View {
  // on having a childview update when parent changes:
  // - https://stackoverflow.com/q/57614564/9439097
  // - https://developer.apple.com/forums/thread/123920
  
  @ObservedObject var config: Config
  @ObservedObject var note: Note
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("\(note.content ?? "")")
          .fontWeight(.medium)
          .padding(.vertical, 0.2)
          .fixedSize(horizontal: false, vertical: true)
        Spacer()
      }
      DetailView(config: config, note: note)
    }
    // to make the entire area clickable
    .contentShape(Rectangle())
    // changing the foreground color
    .foregroundColor(note.getPrimaryColor())
    // if we tap once on the note, we update its priority
    .onTapGesture {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      note.updatePriority(optionalDate: nil)
    }
  }
}

struct DetailView: View {
  // why @OO instead of @Binding? Idk, but maybe this helps
  // - https://jaredsinclair.com/2020/05/07/swiftui-cheat-sheet.html
  
  @ObservedObject var config: Config
  @ObservedObject var note: Note
  
  var body: some View {
    if (config.showCreationTime || config.showNotificationTime) {
      HStack {
        if (config.showCreationTime) {
          Image(systemName: "calendar")
          Text("\(note.timestamp ?? Date.now, formatter: Note.dateFormatter)")
        }
        if (config.showNotificationTime || note.priority.isCustom()) {
          Image(systemName: "bell")
          Text(note.priority.getIntervalDescription())
        }
        Spacer()
      }
      .font(.footnote)
      .foregroundColor(note.getSecondaryColor())
      .padding(.bottom, 0.2)
    }
  }
}

struct OneNoteView_Previews: PreviewProvider {
  static var previews: some View {
    OneNoteView(config: Config(), note: Note.previewNotes.first!)
      .previewLayout(PreviewLayout.sizeThatFits)
      .padding()
  }
}
