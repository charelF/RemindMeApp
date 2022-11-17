//
//  WidgetView.swift
//  RemindMe
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI

struct WidgetView: View {
  
  var notes: [Note]
  var displayNotes: [Note] {
    get {
      let sortedPriorityNotes = notes.sorted(by: { $0.priority.getIndex() > $1.priority.getIndex() })
      switch family {
        
      case .systemLarge:
        guard notes.count > 10 else {
          return notes
        }
        return sortedPriorityNotes[0...9].sorted(by: { $0.timestamp!.timeIntervalSince1970 < $1.timestamp!.timeIntervalSince1970 })
        
      case .systemSmall, .systemMedium:
        fallthrough
        
      case .systemExtraLarge:
        fallthrough
        
      case .accessoryCircular:
        fallthrough
      case .accessoryRectangular:
        fallthrough
      case .accessoryInline:
        fallthrough
        
      @unknown default:
        guard notes.count > 4 else {
          return notes
        }
        return sortedPriorityNotes[0...3].sorted(by: { $0.timestamp!.timeIntervalSince1970 < $1.timestamp!.timeIntervalSince1970 })
      }
    }
  }
  
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.widgetFamily) var family
  
  var body: some View {
    switch family {
    case .systemSmall, .systemLarge, .systemMedium, .systemExtraLarge:
      NormalWidgetView(displayNotes: displayNotes)
    default:
      VStack{
        Text("123")
      }
    }
  }
}

struct NormalWidgetView: View {
  
  var displayNotes: [Note]
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    Color.secondary.opacity(0.2).overlay(
      ZStack(alignment: .top) {
        VStack(spacing: 0) {
          Divider()
          ForEach(displayNotes, id: \.self) { note in
            VStack(alignment: .leading) {
              Text("\(note.content ?? "empty")")
                .lineLimit(
                  displayNotes.count > 2 ? 1 : 2
                )
                .foregroundColor(note.getPrimaryColor())
                .padding(.horizontal, 8)
                .padding(.top, 4.5)
                .padding([.bottom], -1.5)
                .font(.subheadline)
              Divider()
            }
            .background(
              ZStack {
                colorScheme == .dark ? Color.black : Color.white
                note.getWidgetBackgroundColor()
              }
            )
          }
        }
      }
    )
  }
}
  
  struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
      WidgetView(
        notes: Note.previewNotes
      ).previewLayout(.fixed(width: 160, height: 160))
    }
  }
