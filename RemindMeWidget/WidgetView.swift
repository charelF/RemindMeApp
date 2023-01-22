//
//  WidgetView.swift
//  RemindMe
//
//  Created by Charel Felten on 06/07/2021.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
  
  var notes: [Note]
  
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.widgetFamily) var family
  var realFamily: WidgetFamily
  
  var body: some View {
    switch realFamily {
    case .systemSmall, .systemMedium:
      CleanWidgetView(displayNotes: Array(notes[..<4]))
    case .systemLarge, .systemExtraLarge:
      CleanWidgetView(displayNotes: Array(notes[..<8]))
    case .accessoryCircular:
      Text(String(notes.count))
    default:
      CleanWidgetView(displayNotes: Array(notes[..<2]))
    }
  }
}

struct CleanWidgetView: View {
  var displayNotes: [Note]
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    ZStack {
      colorScheme == .dark ? Color.black : Color.white
      
      Rectangle()
        .fill(colorScheme == .dark ? Color.black : Color.white)
        .overlay {
          VStack(alignment: .leading, spacing: 5) {
            ForEach(displayNotes, id: \.self) { note in
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
  // FIX: the membership of this class must be only the widgeet target, no other target
  
  static var previews: some View {
    WidgetView(notes: Array(Note.previewNotes), realFamily: .systemSmall)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
      .environment(\.widgetFamily, .systemSmall)
  }
}

extension WidgetFamily: EnvironmentKey {
    public static var defaultValue: WidgetFamily = .systemMedium
}

extension EnvironmentValues {
  var widgetFamily: WidgetFamily {
    get { self[WidgetFamily.self] }
    set { self[WidgetFamily.self] = newValue }
  }
}
