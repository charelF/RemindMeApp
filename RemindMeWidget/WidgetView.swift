//
//  WidgetView.swift
//  RemindMe
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
  var entry: MyWidgetProvider.Entry
  
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.widgetFamily) var widgetFamily
  
  var body: some View {
    switch widgetFamily {
    case .systemSmall, .systemMedium:
      SystemWidgetView(notes: Array(entry.notes.prefix(4)))
    case .systemLarge, .systemExtraLarge:
      SystemWidgetView(notes: Array(entry.notes.prefix(4)))
    default:
      Text(String(entry.notes.count))
    }
  }
}

struct SystemWidgetView: View {
  var notes: [Note]
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    ZStack {
      colorScheme == .dark ? Color.black : Color.white
      Rectangle()
        .fill(colorScheme == .dark ? Color.black : Color.white)
        .overlay {
          VStack(alignment: .leading, spacing: 5) {
            ForEach(notes, id: \.self) { note in
              Text(note.content!)
                .fontWeight(.medium)
                .font(.callout)
                .foregroundColor(note.getPrimaryColor())
                .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(note.getWidgetBackgroundColor())
                .cornerRadius(5)
            }
          }
        }
        .cornerRadius(15)
        .padding(5)
    }
  }
}

struct WidgetView_Previews: PreviewProvider {
  // NOTE: if it crahes its this bug: https://www.appsloveworld.com/coding/xcode/66/fail-to-preview-widget-in-xcode-with-swiftui-preview
  // FIX: the membership of this class must
  // be only the widgeet target, no other target
  static var previews: some View {
    WidgetView(
      entry: MyWidgetEntry(
        date: Date(),
        notes: Note.previewNotes
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
